//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import Firebase

class Timeslot: DataObject {

    let startTime: String?
    let endTime: String?
    var sessionIDs: [Int] = []
    var tracks: [Track] = []

    var sessions: [Session] {
        get {
            var temp: [Session] = []
            for index in 0..<self.sessionIDs.count {
                let sID = self.sessionIDs[index]
                if let s = DataManager.sharedInstance.getSession(by: sID) {
                    s.track = self.tracks[index]
                    s.timeslot = self
                    temp.append(s)
                }
            }
            return temp
        }
    }

    init(snapshot: DataSnapshot, dayTracks: [Track]) {

        let snapshotValue = snapshot.value as! [String: AnyObject]

        startTime = snapshotValue["startTime"] as? String
        endTime = snapshotValue["endTime"] as? String
        tracks = dayTracks

        switch SwissKnife.app {
        case .rdd:
            for timeslotSnapshot in snapshot.childSnapshot(forPath: "sessions").children {
                for tempEnum in (timeslotSnapshot as! DataSnapshot).childSnapshot(forPath: "items").children {
                    let firstItem = (tempEnum as! DataSnapshot).value as! Int
                    sessionIDs.append(firstItem)
                }
            }
        case .devfest:
            for timeslotSnapshot in snapshot.childSnapshot(forPath: "sessions").children {
                let tmpsessionIDs = (timeslotSnapshot as! DataSnapshot).value as! [Int]
                if let firstItem = tmpsessionIDs.first {
                    sessionIDs.append(firstItem)
                }
            }
        }

        super.init(snapshot: snapshot)
    }
}
