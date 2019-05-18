//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import Firebase

class Session: DataObject {

    let sessionID: Int?
    let title: String?
    let description: String?
    let image: String?
    var speakersIDs: [Int] = []
    var videosIDs: [Int] = []
    var tags: [String] = []
    var auditorium: String?
    var sessionURL: String?
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

    var videos: [Video] {
        var temp: [Video] = []
        for vID in self.videosIDs {
            if let v = DataManager.sharedInstance.getVideo(by: vID) {
                temp.append(v)
            }
        }
        return temp
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

    var sessionShareURL: String {
        get {
            return sessionURL ?? ""
//            guard let dayIndex = DataManager.sharedInstance.days.index(where: { $0.date == day?.date }),
//                let sessionIndex = sessionID else {
//                    return ""
//            }
//            return "\(Config.sharedInstance.baseURLPrefix)/schedule/day\(dayIndex+1)?sessionId=\(sessionIndex)"
        }
    }

    var isFavourite: Bool {
        guard let sessionID = sessionID else { return false }
        return DataManager.sharedInstance.favourites.contains(sessionID)
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

    init(id: Int, snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]

        title = snapshotValue["title"] as? String
        description = snapshotValue["description"] as? String
        image = snapshotValue["image"] as? String
        sessionID = id
        speakersIDs = snapshotValue["speakers"] as? [Int] ?? []
        videosIDs = snapshotValue["videos"] as? [Int] ?? []
        auditorium = snapshotValue["auditorium"] as? String
        sessionURL = snapshotValue["sessionUrl"] as? String

        for tag in snapshot.childSnapshot(forPath: "tags").children {
            if let currentTag = (tag as! DataSnapshot).value as? String {
                tags.append(currentTag)
            }
        }

        super.init(snapshot: snapshot)
    }
}

extension Session {

    func toggleFavourite(completionBlock block: @escaping (Error?, DatabaseReference) -> Void) {

        guard let userID = Auth.auth().currentUser?.uid,
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
