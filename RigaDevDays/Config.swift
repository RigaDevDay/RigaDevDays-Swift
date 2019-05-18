//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import UIKit

class Config {

    let baseURLPrefix = "https://2019.rigadevdays.lv"

    let themePrimaryColor = #colorLiteral(red: 0, green: 0.4823529412, blue: 1, alpha: 1) // 007bff
    let themeSecondaryColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1) // 212121

    let searchProposals: [String] = ["Java", ".NET", "DevOps", "Cloud", "Software architecture", "John Doe"]

    let numberOfSectionsInSessionScreen = 7 // see TableSections enum

    static let sharedInstance = Config()
    fileprivate init() {
        //This prevents others from using the default '()' initializer
    }
}
