//
//  Day.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 27/01/2017.
//  Copyright © 2017 RigaDevDay. All rights reserved.
//

import Foundation
import Firebase

class Day: DataObject {

    let date: String?
    let dateReadable: String?
    let dateMobileApp: String?

    var timeslots: [Timeslot] = []
    var tracks: [Track] = []

    var allSessions: [Session] {
        get {
            var temp: [Session] = []
            for currentTimeslot in self.timeslots {
                for currentSessionID in currentTimeslot.sessionIDs {
                    if let s = DataManager.sharedInstance.getSession(by: currentSessionID) {
                        temp.append(s)
                    }
                }
            }
            return temp
        }
    }

    override init(snapshot: FIRDataSnapshot) {

        let snapshotValue = snapshot.value as! [String: AnyObject]

        date = snapshotValue["date"] as? String
        dateReadable = snapshotValue["dateReadable"] as? String
        dateMobileApp = snapshotValue["dateMobileApp"] as? String

        var tmpTracks: [Track] = []
        for trackSnapshot in snapshot.childSnapshot(forPath: "tracks").children {
            let currentTrack = Track(snapshot: trackSnapshot as! FIRDataSnapshot)
            tmpTracks.append(currentTrack)
        }
        tracks = tmpTracks

        var tmpTimeslots: [Timeslot] = []
        for timeslotSnapshot in snapshot.childSnapshot(forPath: "timeslots").children {
            let currentTimeslot = Timeslot(snapshot: timeslotSnapshot as! FIRDataSnapshot, dayTracks: tmpTracks)
            tmpTimeslots.append(currentTimeslot)
        }
        timeslots = tmpTimeslots

        super.init(snapshot: snapshot)
    }
}
