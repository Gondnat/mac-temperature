//
//  GeneralPreferenceViewController.swift
//  Temperature
//
//  Created by Gondnat on 27/03/2018.
//  Copyright © 2018 Gondnat. All rights reserved.
//

import Cocoa

let refreshSecondID = "refreshSecond"

class GeneralPreferenceViewController: NSViewController, PreferenceViewController {
    private let id = "general.preference.view.controller"
    var toolbarIdentifier: NSToolbarItem.Identifier {
        return NSToolbarItem.Identifier((identifier?.rawValue) ?? id)
    }
    var image: NSImage {
        return NSImage(named: NSImage.Name.preferencesGeneral)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: NSNib.Name(rawValue: GeneralPreferenceViewController.className()), bundle: nil)
        title = NSLocalizedString("General", comment: "General preference title")
        identifier = NSUserInterfaceItemIdentifier(id)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
