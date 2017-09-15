//
//  Team.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 05/03/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import Foundation
import Firebase

class Team: DataObject {

    let title: String?
    var members: [Speaker] = []

    override init(snapshot: DataSnapshot) {

        let snapshotValue = snapshot.value as! [String: AnyObject]

        title = snapshotValue["title"] as? String

        var tmpMembers: [Speaker] = []
        for memberSnapshot in snapshot.childSnapshot(forPath: "members").children {
            let currentMember = Speaker(snapshot: memberSnapshot as! DataSnapshot)
            tmpMembers.append(currentMember)
        }
        members = tmpMembers

        super.init(snapshot: snapshot)
    }
}
