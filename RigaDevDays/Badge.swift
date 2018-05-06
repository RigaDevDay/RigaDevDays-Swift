//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import Firebase

class Badge: DataObject {

    let description: String?
    let link: String?
    let name: String?

    override init(snapshot: DataSnapshot) {

        let snapshotValue = snapshot.value as! [String: AnyObject]

        description = snapshotValue["description"] as? String
        link = snapshotValue["link"] as? String
        name = snapshotValue["name"] as? String

        super.init(snapshot: snapshot)
    }
}
