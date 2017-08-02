//
//  Video.swift
//  RigaDevDays
//
//  Created by Dmitrijs Beloborodovs on 02/04/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import Foundation
import Firebase

class Video: DataObject {

    let videoID: Int?
    let speakers: String?
    let thumbnail: String?
    let title: String?
    let youtubeID: String?

    override init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]

        videoID = Int(snapshot.key)

        speakers = snapshotValue["speakers"] as? String
        thumbnail = snapshotValue["thumbnail"] as? String
        title = snapshotValue["title"] as? String
        youtubeID = snapshotValue["youtubeId"] as? String

        super.init(snapshot: snapshot)
    }
}
