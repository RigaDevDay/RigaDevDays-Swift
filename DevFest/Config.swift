//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import UIKit

class Config {

    let baseURLPrefix = "https://devfest.gdg.lv"
    
    let themePrimaryColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1) // 5130f2
    let themesecondaryColor = #colorLiteral(red: 0.6332716942, green: 0.4842528701, blue: 1, alpha: 1) // 8f5fff

    let searchProposals: [String] = ["Mobile", "Kotlin", "Swift", "Firebase", "John Doe"]

    let numberOfSectionsInSessionScreen = 6 // see TableSections enum

    static let sharedInstance = Config()
    fileprivate init() {
        //This prevents others from using the default '()' initializer
    }
}
