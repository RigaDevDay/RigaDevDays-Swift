//
//  Config.swift
//  RigaDevDays
//
//  Created by Dmitrijs Beloborodovs on 17/08/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import Foundation
import UIKit

class Config {

    let baseURLPrefix = "https://rigadevdays.lv"

    let themePrimaryColor = #colorLiteral(red: 0, green: 0.6509803922, blue: 0.9254901961, alpha: 1) // 00a6ec
    let themesecondaryColor = #colorLiteral(red: 0.09019607843, green: 0.2274509804, blue: 0.337254902, alpha: 1) // 173a56

    let searchProposals: [String] = ["Oracle", "Kotlin", "Mobile", "Internet of Things", "UI", "Big Data", "John Doe"]

    let numberOfSectionsInSessionScreen = 7 // see TableSections enum

    static let sharedInstance = Config()
    fileprivate init() {
        //This prevents others from using the default '()' initializer
    }
}
