//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import UIKit

class Config {

    let baseURLPrefix = "https://rigadevdays.lv"

    let themePrimaryColor = #colorLiteral(red: 0, green: 0.6196078431, blue: 0.8588235294, alpha: 1) // 009edb
    let themesecondaryColor = #colorLiteral(red: 0.1098039216, green: 0.06274509804, blue: 0.3058823529, alpha: 1) // 1c104e

    let searchProposals: [String] = ["Java", ".NET", "DevOps", "Cloud", "Software architecture", "John Doe"]

    let numberOfSectionsInSessionScreen = 7 // see TableSections enum

    static let sharedInstance = Config()
    fileprivate init() {
        //This prevents others from using the default '()' initializer
    }
}
