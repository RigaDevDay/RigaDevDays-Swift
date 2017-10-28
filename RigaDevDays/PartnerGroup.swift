//
//  PartnerGroup.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 12/02/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import Foundation
import Firebase

class PartnerGroup: DataObject {

    var partners: [Partner] = []
    let title: String?

    override init(snapshot: DataSnapshot) {

        let snapshotValue = snapshot.value as! [String: AnyObject]

        title = snapshotValue["title"] as? String
        
        for partnerSnapshot in snapshot.childSnapshot(forPath: "logos").children {
            let currentPartner = Partner(snapshot: partnerSnapshot as! DataSnapshot)
            partners.append(currentPartner)
        }

        super.init(snapshot: snapshot)
    }
}
