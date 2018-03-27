//
//  AppDelegate.swift
//  Temperature
//
//  Created by Gondnat on 26/03/2018.
//  Copyright © 2018 Destiny. All rights reserved.
//

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
        return NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
    }

    var preferenceMenuItem:NSMenuItem {
        return NSMenuItem(title: "Preference", action: #selector(preference), keyEquivalent: ",")
    }


    fileprivate func fanMenuItem(title string: String) -> NSMenuItem {
        let fanMenuItem = NSMenuItem()
        fanMenuItem.isEnabled = false
        fanMenuItem.attributedTitle = NSAttributedString(string: string,
                                                         attributes: [NSAttributedStringKey.font: NSFont.messageFont(ofSize: 12)])
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

    fileprivate func refreshStatus() {
        let menu = NSMenu()
        SMCWrapper.shared().readFloat(withKey: "TC0P".cString(using: .ascii)) { (temperature) in
            let title = String(format: "%.01f℃", arguments: [temperature])
            self.statusMenu.button?.title = title
            self.statusMenu.button?.font = NSFont(name: "system", size: 10)
        }

        SMCWrapper.shared().readFloat(withKey: "FNum".cString(using: .ascii)) { fansCount in
            var i = 0;
            while i < Int(fansCount) {
                let fanNameItem = NSMenuItem(title: "Fan #\(i+1)", action: nil, keyEquivalent: "")
                fanNameItem.isEnabled = false
                menu.addItem(fanNameItem)

                // actual RPM
                SMCWrapper.shared().readFloat(withKey: "F\(i)Ac".cString(using: .ascii),
                                              withComplation: { fanRPM in
                                                menu.addItem(self.fanMenuItem(title: "Current Speed: \(Int(fanRPM)) RPM"))
                })


                // target RPM
                SMCWrapper.shared().readFloat(withKey: "F\(i)Tg".cString(using: .ascii),
                                              withComplation: { fanRPM in
                                                menu.addItem(self.fanMenuItem(title: "Target Speed: \(Int(fanRPM)) RPM"))
                })

                // MIN RPM
                SMCWrapper.shared().readFloat(withKey: "F\(i)Mn",
                                              withComplation: { fanRPM in
                                                menu.addItem(self.fanMenuItem(title: "Min Speed: \(Int(fanRPM)) RPM"))
                })
                // MAX RPM
                SMCWrapper.shared().readFloat(withKey: "F\(i)Mx",
                    withComplation: { (fanRPM) in
                        menu.addItem(self.fanMenuItem(title: "Mac Speed: \(Int(fanRPM)) RPM"))

                })

                menu.addItem(NSMenuItem.separator())
                i += 1
            }
        }

        menu.addItem(preferenceMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitMenuItem)
        self.statusMenu.menu = menu
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let menu = NSMenu()
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitMenuItem)
        self.statusMenu.menu = menu
//        let timer = Timer(timeInterval: 6, repeats: true) { timer in
        let timer = Timer(fire: Date.init(timeIntervalSinceNow: 0), interval: 3, repeats: true) { timer in
            self.refreshStatus()
        }
        RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

