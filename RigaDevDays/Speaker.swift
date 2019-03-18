//  Copyright © 2017 RigaDevDays. All rights reserved.

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
    let profileURL: String?
    var socials: [Social] = []
    var tags: [String] = []

    var speakerURL: String {
        switch SwissKnife.app {
        case .frontcon:
            return profileURL ?? ""
        default:
            return "\(Config.sharedInstance.baseURLPrefix)/speakers/\(speakerID ?? 0)"
        }
    }

    var speakerPhotoReference: StorageReference {
        switch SwissKnife.app {
        case .devopsdaysriga:
            return DataManager.sharedInstance.storageRef.child(photoURL ?? "")
        case .devfest, .frontcon, .rdd:
            let imageName = URL(fileURLWithPath: photoURL ?? "").lastPathComponent
            return DataManager.sharedInstance.storageRef.child("people").child(imageName)
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
        profileURL = snapshotValue["profileUrl"] as? String
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
