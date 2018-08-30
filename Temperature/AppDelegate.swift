//
//  AppDelegate.swift
//  Temperature
//
//  Created by Gondnat on 26/03/2018.
//  Copyright © 2018 Gondnat. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.


import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    lazy var statusMenu: NSStatusItem = {
        let _statusMenu = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        return _statusMenu
    }()

    lazy var smcReadQueue: DispatchQueue = {
        return DispatchQueue(label: "com.thnuth.temperature.smc.read",
                             qos: DispatchQoS.background,
                             attributes: DispatchQueue.Attributes())
    }()

    lazy var PreferencesWC: PreferencesWindowController = {
        return PreferencesWindowController()
    }()

    var quitMenuItem: NSMenuItem {
        return NSMenuItem(title: NSLocalizedString("Quit", comment: "Quit App"), action: #selector(quit), keyEquivalent: "q")
    }

    var preferenceMenuItem:NSMenuItem {
        return NSMenuItem(title: NSLocalizedString("Preferences...", comment: "button will show preferences"), action: #selector(preference), keyEquivalent: ",")
    }

    private var refreshTimer:Timer?

    fileprivate func fanMenuItem(title string: String) -> NSMenuItem {
        let fanMenuItem = NSMenuItem()
        fanMenuItem.isEnabled = false
        fanMenuItem.attributedTitle = NSAttributedString(string: string,
                                                         attributes: [NSAttributedStringKey.font: NSFont.systemFont(ofSize: 12)])
        return fanMenuItem
    }
    @objc fileprivate func quit() {
        NSApp.terminate(nil)
    }

    @objc fileprivate func preference() {
        PreferencesWC.preferenceViewControllers = [ GeneralPreferenceViewController()
        ]
        PreferencesWC.window?.center()
        PreferencesWC.window?.makeKeyAndOrderFront(self)
        PreferencesWC.window?.orderedIndex = 0
        NSApp .activate(ignoringOtherApps: true)
    }

    @objc fileprivate func refreshStatus() {
        var menu = NSMenu()
        if statusMenu.menu != nil {
            menu = statusMenu.menu!
        }
        menu.removeAllItems()
        var temper = SMCWrapper.shared().float(forKey: "TC0P")
        var format = "%.01f℃";
        if let temperatureScale = UserDefaults.standard.value(forKey: temperatureScaleID) as? Int {
            if temperatureScale == 1 {
                format = "%.01f℉"
                temper = temper*9/5 + 32
            }
        }
        self.statusMenu.button?.title = String(format: format, temper)


        let fansCount = SMCWrapper.shared().float(forKey: "FNum")
        var i = 0;
        while i < Int(fansCount) {
            var fmt = NSLocalizedString("Fan  #%d", comment: "Fan number")
            let fanNameItem = NSMenuItem(title: String(format: fmt, arguments:[i+1]), action: nil, keyEquivalent: "")
            fanNameItem.isEnabled = false
            menu.addItem(fanNameItem)

            // actual RPM
            let fanRPM = SMCWrapper.shared().float(forKey: "F\(i)Ac")
            let targetRPM = SMCWrapper.shared().float(forKey: "F\(i)Tg")
            fmt = NSLocalizedString("Current Speed: %.0f RPM %@", comment: "Current fan speed")
            let diff = targetRPM - fanRPM ;
            var addSignal = "➖"
            if fabs(diff) > 2 {
               addSignal = diff > 0 ? "△" : "▽"
            }
            menu.addItem(self.fanMenuItem(title: String(format: fmt, fanRPM, addSignal)))

            // MIN RPM
            let miniRPM = SMCWrapper.shared().float(forKey: "F\(i)Mn")
            fmt = NSLocalizedString("Min Speed: %.0f RPM", comment: "Fan  min speed")
            menu.addItem(self.fanMenuItem(title: String(format: fmt, miniRPM)))

            // MAX RPM
            let maxRPM = SMCWrapper.shared().float(forKey: "F\(i)Mx")
            fmt = NSLocalizedString("Max Speed: %.0f RPM", comment: "Fan max speed")
            menu.addItem(self.fanMenuItem(title: String(format: fmt, maxRPM)))

            menu.addItem(NSMenuItem.separator())
            i += 1
        }

        menu.addItem(preferenceMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitMenuItem)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let menu = NSMenu()
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitMenuItem)
        self.statusMenu.menu = menu
        createRefreshTimer()
        UserDefaults.standard.addObserver(self, forKeyPath: refreshSecondID, options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: temperatureScaleID, options: .new, context: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func createRefreshTimer() {
        var interval = UserDefaults.standard.value(forKey: refreshSecondID) as? TimeInterval
        if interval == nil {
            UserDefaults.standard.setValue(1, forKey: refreshSecondID)
            interval = 1
        }
        if #available(OSX 10.12, *) {
            refreshTimer = Timer(fire: Date(timeIntervalSinceNow: 0), interval: interval!, repeats: true) { timer in
                self.refreshStatus()
            }
            RunLoop.current.add(refreshTimer!, forMode: .commonModes)
        } else {
            refreshTimer = Timer(fireAt: Date(timeIntervalSinceNow: 0), interval: interval!, target: self, selector: #selector(refreshStatus), userInfo: nil, repeats: true)
            RunLoop.current.add(refreshTimer!, forMode: .commonModes)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case refreshSecondID:
            refreshTimer?.invalidate()
            createRefreshTimer()
        case temperatureScaleID:
            refreshTimer?.fire()
        default:
            break
        }
    }


}

