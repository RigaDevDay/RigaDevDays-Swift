//
//  Tag.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 01/02/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import Foundation
import Firebase

class Tag: DataObject {

    let title: String?
    let colorCode: String?

    override init(snapshot: FIRDataSnapshot) {

        let snapshotValue = snapshot.value as! [String: AnyObject]
        title = snapshotValue.keys.first
        if title?.isEmpty == false {
            colorCode = snapshotValue[title!] as? String
        } else {
            colorCode = "#000000"
        }

        super.init(snapshot: snapshot)
    }
}
