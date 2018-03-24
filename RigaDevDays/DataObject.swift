//  Copyright © 2017 RigaDevDays. All rights reserved.

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
