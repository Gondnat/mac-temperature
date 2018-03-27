//
//  PreferenceViewController.swift
//  Temperature
//
//  Created by Gondnat on 27/03/2018.
//  Copyright © 2018 Destiny. All rights reserved.
//

import Cocoa

public protocol PreferenceViewController {

    var title:String? { get }
    var image:NSImage { get }
    var view:NSView { get }
    var toolbarIdentifier:NSToolbarItem.Identifier { get }

//    var identifier:String { get }
}
