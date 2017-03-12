//
//  Social.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 31/01/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import Foundation
import Firebase

class Social: DataObject {

    let icon: String?
    let link: String?
    let name: String?

    override init(snapshot: FIRDataSnapshot) {

        let snapshotValue = snapshot.value as! [String: AnyObject]

        icon = snapshotValue["icon"] as? String
        link = snapshotValue["link"] as? String
        name = snapshotValue["name"] as? String

        super.init(snapshot: snapshot)
    }
}
