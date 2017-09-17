//
//  DataManager+DevFest.swift
//  RigaDevDays
//
//  Created by Dmitrijs Beloborodovs on 17/08/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import Foundation
import UIKit

class Config {

    let baseURLPrefix = "https://devfest.gdg.lv"
    
    let themePrimaryColor = #colorLiteral(red: 0.3960784314, green: 0.1215686275, blue: 1, alpha: 1) // 651fff
    let themesecondaryColor = #colorLiteral(red: 1, green: 0.5411764706, blue: 0.5019607843, alpha: 1) // ff8a80

    let searchProposals: [String] = ["Mobile", "Kotlin", "Swift", "Firebase", "John Doe"]

    let numberOfSectionsInSessionScreen = 6 // see TableSections enum

    static let sharedInstance = Config()
    fileprivate init() {
        //This prevents others from using the default '()' initializer
    }
}
