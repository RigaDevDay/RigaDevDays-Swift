//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import UIKit

class Config {

    let baseURLPrefix = "https://www.devopsdays.org/events/2018-riga/"

    let themePrimaryColor = #colorLiteral(red: 0.007843137255, green: 0.4588235294, blue: 0.8470588235, alpha: 1) // 0275d8
    let themeSecondaryColor = #colorLiteral(red: 0, green: 0.5098039216, blue: 0.6705882353, alpha: 1) // #0082AB

    let searchProposals: [String] = ["TeamCity", "AWS", "GDPR", "John Doe"]

    let numberOfSectionsInSessionScreen = 6 // see TableSections enum

    static let sharedInstance = Config()
    fileprivate init() {
        //This prevents others from using the default '()' initializer
    }
}
