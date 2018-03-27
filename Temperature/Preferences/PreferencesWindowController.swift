//
//  PreferencesWindowController.swift
//  Temperature
//
//  Created by Gondnat on 27/03/2018.
//  Copyright © 2018 Gondnat. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, NSToolbarDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    var preferenceViewControllers:[PreferenceViewController]? {
        didSet {
            if window?.toolbar == nil {
                let toolbar = NSToolbar(identifier: NSToolbar.Identifier("Preferences.ToolBar"))
                toolbar.displayMode = .iconAndLabel
                toolbar.delegate = self
                toolbar.autosavesConfiguration = false
                self.window?.toolbar = toolbar
            }
            if let toolbar = window?.toolbar {
                var count = toolbar.items.count
                while count > 0  {
                    toolbar.removeItem(at: count-1)
                    count -= 1
                }
                for viewController in preferenceViewControllers! {
                    toolbar.insertItem(withItemIdentifier: viewController.toolbarIdentifier, at: toolbar.items.count)
                }

                // select first view
                selectedViewController = preferenceViewControllers?[0]
            }



        }
    }

    private var selectedViewController:PreferenceViewController? {
        willSet {
            selectedViewController?.view.removeFromSuperview()
        }
        didSet {
            if let view = selectedViewController?.view {
                if var newWindowFrame = window?.frameRect(forContentRect: view.frame) {
                    if let oldframe = window?.frame {
                        newWindowFrame.origin = oldframe.origin
                        newWindowFrame.origin.y -= newWindowFrame.size.height - oldframe.size.height
                    }
                    window?.setFrame(newWindowFrame, display: true)
                    window?.toolbar?.selectedItemIdentifier = selectedViewController?.toolbarIdentifier
                    window?.title = selectedViewController?.title ?? ""
                }
                window?.contentView?.addSubview((selectedViewController?.view)!)
            }

        }
    }

    override init(window: NSWindow?) {
        var localWindow = window
        if localWindow == nil {
            localWindow = NSWindow(contentRect: NSMakeRect(0, 0, 200*1.85, 200),
                                   styleMask: [.titled, .closable],
                                   backing: .buffered,
                                   defer: true)
        }
        localWindow?.showsToolbarButton = false
        super.init(window: localWindow)
    }

    required init?(coder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }

    // MARK: - NSToolbarDelegate
    fileprivate func toolbarIdentifiers() -> [NSToolbarItem.Identifier] {
        var array = [NSToolbarItem.Identifier]()
        for viewController in preferenceViewControllers ?? [] {
            array.append(viewController.toolbarIdentifier)
        }
        return array
    }

    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarIdentifiers()
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [preferenceViewControllers?[0].toolbarIdentifier ?? NSToolbarItem.Identifier.space]
    }

    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarIdentifiers()
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let prefItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        for vc in preferenceViewControllers! {
            if vc.toolbarIdentifier == itemIdentifier {
                prefItem.label = vc.title ?? ""
                prefItem.image = vc.image
                prefItem.target = self
                prefItem.action = #selector(toolbarItemDidClick(item:))
            }
        }
        return prefItem
    }

    @objc func toolbarItemDidClick(item:NSToolbarItem) {
        for vc in preferenceViewControllers! {
            if vc.toolbarIdentifier == item.itemIdentifier {
                selectedViewController = vc
            }
        }
    }
}
