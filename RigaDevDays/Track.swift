//  Copyright © 2017 RigaDevDays. All rights reserved.

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
