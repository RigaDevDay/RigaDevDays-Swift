//
//  Feedback.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 04/03/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import Foundation
import Firebase

class Feedback: DataObject {

    var sessionID: Int?

    var qualityOfContent: Int?
    var speakerPerformance: Int?
    var comment: String?

    override init(snapshot: DataSnapshot) {

        let snapshotValue = snapshot.value as! [String: AnyObject]

        qualityOfContent = snapshotValue["qualityOfContent"] as? Int
        speakerPerformance = snapshotValue["speakerPerformance"] as? Int
        comment = snapshotValue["comment"] as? String

        super.init(snapshot: snapshot)
    }

}

