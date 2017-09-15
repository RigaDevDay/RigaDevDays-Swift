//
//  Speaker.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 26/01/2017.
//  Copyright © 2017 RigaDevDay. All rights reserved.
//

import Foundation
import Firebase

class Speaker: DataObject {

    var badges: [Badge] = []
    let speakerID: Int?
    let name: String?
    let title: String?
    let bio: String?
    let featured: Bool?
    let company: String?
    let country: String?
    let photoURL: String?
    let shortBio: String?
    var socials: [Social] = []
    var tags: [String] = []

    var speakerURL: String {
        get {

            return "\(Config.sharedInstance.baseURLPrefix)/speakers/\(String(describing: speakerID))"
        }
    }

    override init(snapshot: DataSnapshot) {

        let snapshotValue = snapshot.value as! [String: AnyObject]

        for badgeSnapshot in snapshot.childSnapshot(forPath: "badges").children {
            let currentBadge = Badge(snapshot: badgeSnapshot as! DataSnapshot)
            badges.append(currentBadge)
        }
        bio = snapshotValue["bio"] as? String
        company = snapshotValue["company"] as? String
        country = snapshotValue["country"] as? String
        featured = snapshotValue["featured"] as? Bool
        speakerID = snapshotValue["id"] as? Int
        name = snapshotValue["name"] as? String
        photoURL = snapshotValue["photoUrl"] as? String
        shortBio = snapshotValue["shortBio"] as? String

        for socialSnapshot in snapshot.childSnapshot(forPath: "socials").children {
            let currentSocial = Social(snapshot: socialSnapshot as! DataSnapshot)
            socials.append(currentSocial)
        }

        for tag in snapshot.childSnapshot(forPath: "tags").children {
            if let currentTag = (tag as! DataSnapshot).value as? String {
                tags.append(currentTag)
            }
        }

        title = snapshotValue["title"] as? String

        super.init(snapshot: snapshot)
    }
}
