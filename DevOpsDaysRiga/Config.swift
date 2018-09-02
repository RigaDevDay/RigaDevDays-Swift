//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import UIKit

class Config {

    let baseURLPrefix = "https://www.devopsdays.org/events/2018-riga/"

    let themePrimaryColor = #colorLiteral(red: 0.03529411765, green: 0.2862745098, blue: 0.4588235294, alpha: 1) // 094975
    let themeSecondaryColor = #colorLiteral(red: 0.3843137255, green: 0.6117647059, blue: 0.737254902, alpha: 1) // 629CBC

    let searchProposals: [String] = ["TeamCity", "AWS", "GDPR", "John Doe"]

    let numberOfSectionsInSessionScreen = 6 // see TableSections enum

    static let sharedInstance = Config()
    fileprivate init() {
        //This prevents others from using the default '()' initializer
    }
}
