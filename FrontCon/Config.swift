//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import UIKit

class Config {

    let baseURLPrefix = "https://frontcon.lv"
    
    let themePrimaryColor = #colorLiteral(red: 0.1960784314, green: 0.4901960784, blue: 0.1960784314, alpha: 1) // 327d32
    let themeSecondaryColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // #000000

    let searchProposals: [String] = ["JavaScript", "GraphQL", "Virtual Reality", "John Doe"]

    let numberOfSectionsInSessionScreen = 6 // see TableSections enum

    static let sharedInstance = Config()
    fileprivate init() {
        //This prevents others from using the default '()' initializer
    }
}
