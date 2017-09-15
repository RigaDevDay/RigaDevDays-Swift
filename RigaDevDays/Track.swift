//
//  Track.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 29/01/2017.
//  Copyright © 2017 RigaDevDay. All rights reserved.
//

import Foundation
import Firebase

class Track: DataObject {

    let title: String?

    override init(snapshot: DataSnapshot) {

        let snapshotValue = snapshot.value as! [String: AnyObject]

        title = snapshotValue["title"] as? String

        super.init(snapshot: snapshot)
    }
}
