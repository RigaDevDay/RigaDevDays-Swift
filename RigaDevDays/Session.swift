//
//  Session.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 27/01/2017.
//  Copyright © 2017 RigaDevDay. All rights reserved.
//

import Foundation
import Firebase

class Session: DataObject {

    let sessionID: Int?
    let title: String?
    let description: String?
    let image: String?
    var speakersIDs: [Int] = []
    var tags: [String] = []
    weak var track: Track?
    weak var timeslot: Timeslot?

    var speakers: [Speaker] {
        get {
            var temp: [Speaker] = []
            for sID in self.speakersIDs {
                if let s = DataManager.sharedInstance.getSpeaker(by: sID) {
                    temp.append(s)
                }
            }
            return temp
        }
    }

    var assignedDay: Day?

    var day: Day? {
        get {
            if assignedDay != nil { return assignedDay }
            var tempDay = DataManager.sharedInstance.days.first
            for day in DataManager.sharedInstance.days {
                for session in day.allSessions {
                    if sessionID == session.sessionID {
                        tempDay = day
                    }
                }
            }
            return tempDay
        }
    }

    var sessionURL: String {
        get {
            guard let dayIndex = DataManager.sharedInstance.days.index(where: { $0.date == day?.date }),
                let sessionIndex = sessionID else {
                    return ""
            }
            return "https://rigadevdays.lv/schedule/day\(dayIndex+1)?sessionId=\(sessionIndex)"
        }
    }

    var isFavourite: Bool {
        get {
            return DataManager.sharedInstance.favourites.contains(self.sessionID!)
        }
    }

    func duration(on day: Day?) -> (startDate: Date, endDate: Date) {

        guard let properDay = (day != nil) ? day : self.day,
            let startDateString = properDay.date,
            let startTimeString = timeslot?.startTime,
            let endTimeString = timeslot?.endTime else {
                return (Date(), Date())
        }
        let startDateAsString = startDateString + " " + startTimeString
        let endDateAsString = startDateString + " " + endTimeString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "EEST")
        let startDate = dateFormatter.date(from: startDateAsString)
        let endDate = dateFormatter.date(from: endDateAsString)

        return (startDate!, endDate!)
    }

    var color: UIColor {
        get {

            guard let tagTitle = speakers.first?.tags.first else {
                return UIColor.clear;
            }

            guard let colorCode = DataManager.sharedInstance.getTag(by: tagTitle)?.colorCode else {
                return UIColor.clear;
            }

            let resultColor = UIColor.hexStringToUIColor(hex: colorCode)
            return resultColor
        }
    }

    override init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]

        title = snapshotValue["title"] as? String
        description = snapshotValue["description"] as? String
        image = snapshotValue["image"] as? String
        sessionID = snapshotValue["id"] as? Int
        speakersIDs = snapshotValue["speakers"] as? [Int] ?? []

        for tag in snapshot.childSnapshot(forPath: "tags").children {
            if let currentTag = (tag as! FIRDataSnapshot).value as? String {
                tags.append(currentTag)
            }
        }

        super.init(snapshot: snapshot)
    }
}

extension Session {

    func toggleFavourite(completionBlock block: @escaping (Error?, FIRDatabaseReference) -> Void) {

        guard let userID = FIRAuth.auth()?.currentUser?.uid,
            let sessionID = self.sessionID else {
                block(CustomError.noUser, self.ref!)
                return
        }

        if self.isFavourite {
            DataManager.sharedInstance.rootRef.child(Endpoint.favourites.rawValue).child(userID).child(sessionID.description).removeValue(completionBlock: { (error, reference) in
                block(error, reference)
            })
        } else {
            DataManager.sharedInstance.rootRef.child(Endpoint.favourites.rawValue).child(userID).updateChildValues([sessionID.description: true], withCompletionBlock: { (error, reference) in
                block(error, reference)
            })
        }
    }
}
