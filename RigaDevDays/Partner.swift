//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import Firebase

class Partner: DataObject {

    var identifier: String?
    var logoUrl: String?
    var name: String?
    var url: String?

    override init(snapshot: DataSnapshot) {

        let snapshotValue = snapshot.value as! [String: AnyObject]

        identifier = snapshotValue["id"] as? String
        logoUrl = snapshotValue["logoUrl"] as? String
        name = snapshotValue["name"] as? String
        url = snapshotValue["url"] as? String

        super.init(snapshot: snapshot)
    }
}
