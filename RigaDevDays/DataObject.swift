//
//  DataObject.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 28/01/2017.
//  Copyright © 2017 RigaDevDay. All rights reserved.
//

import Foundation
import Firebase

class DataObject {
    let ref: DatabaseReference?
    let key: String

    init(snapshot: DataSnapshot) {
        ref = snapshot.ref
        key = snapshot.key
    }
}
