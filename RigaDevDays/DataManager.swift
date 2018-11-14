//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import Firebase

enum Endpoint: String {
    case favourites = "userSessions"
    case feedbacks = "userFeedbacks"
    case lotteryPartners = "lotteryPartners"
    case lottery = "lottery"
}

class DataManager {
    static let sharedInstance = DataManager()

    let rootRef: DatabaseReference!
    var handle: AuthStateDidChangeListenerHandle?
    let remoteConfig: RemoteConfig!
    let storage: Storage!
    let storageRef: StorageReference!

    var days: [Day] = []
    var sessions: [Session] = []
    var speakers: [Speaker] = []
    var tags: [Tag] = []
    var partnerGroups: [PartnerGroup] = []
    var favourites: [Int] = []
    var feedbacks: [Feedback] = []
    var team: [Team] = []
    var venues: [Venue] = []
    var resources: [String: String] = [:]
    var videos: [Video] = []
    var lotteryPartners: [Partner] = []
    var lotteryParticipantsRecords: [String : [String: String]] = [:]

    var speakersReceived = false
    var sessionsReceived = false
    var scheduleReceived = false
    var tagsReceived = false
    var partnerGroupsReceived = false
    var teamReceived = false
    var venuesReceived = false
    var resourcesReceived = false
    var videosReceived = false
    var lotteryPartnersReceived = false
    var allDataReceivedNotificationSent = false

    fileprivate init() {
        //This prevents others from using the default '()' initializer
        rootRef = Database.database().reference()
        remoteConfig = RemoteConfig.remoteConfig()
        storage = Storage.storage()
        storageRef = storage.reference()

        activeRemoteConfiguration()
    }

    func activeRemoteConfiguration() {

        var developerMode = false
        #if DEBUG
            developerMode = true
        #endif

        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: developerMode)
        remoteConfig.configSettings = remoteConfigSettings
        remoteConfig.setDefaults(fromPlist: "c")

        var expirationDuration = 3600 // 1 hour
        #if DEBUG
            expirationDuration = 0
        #endif

        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { [weak self] (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self?.remoteConfig.activateFetched()
            } else {
                print("Config not fetched")
                print("Error \(error!.localizedDescription)")
            }
        }
    }

    func notifyInitialDataReceived() {

        if speakersReceived
            && sessionsReceived
            && scheduleReceived
            && tagsReceived
            && teamReceived
            && venuesReceived
            && resourcesReceived
        {
            // initiate all session's data
            for day in self.days {
                for timeslot in day.timeslots {
                    _ = timeslot.sessions.count
                }
            }

            if allDataReceivedNotificationSent { return }

            NotificationCenter.default.post(name: .AllDataReceived, object: nil)
            allDataReceivedNotificationSent = true
        }
    }

    func startObservingPublicData() {

        rootRef.child("speakers").observe(.value, with: { snapshot in
            self.speakers = []
            self.speakers = snapshot.children.map{ Speaker(snapshot: $0 as! DataSnapshot) }
            self.speakersReceived = true
            self.notifyInitialDataReceived()
            if self.allDataReceivedNotificationSent { NotificationCenter.default.post(name: .SpeakersUpdated, object: nil) }
        })

        rootRef.child("sessions").observe(.value, with: { snapshot in
            self.sessions = []
            for sessionSnapshot in snapshot.children {
                let key = Int((sessionSnapshot as! DataSnapshot).key)
                self.sessions.append(Session(id: key!, snapshot: (sessionSnapshot as! DataSnapshot)))
            }
            self.sessionsReceived = true
            self.notifyInitialDataReceived()
            if self.allDataReceivedNotificationSent { NotificationCenter.default.post(name: .SessionsUpdated, object: nil) }
        })

        rootRef.child("schedule").observe(.value, with: { snapshot in
            self.days = snapshot.children.map{ Day(snapshot: $0 as! DataSnapshot) }
            self.scheduleReceived = true
            self.notifyInitialDataReceived()
            if self.allDataReceivedNotificationSent { NotificationCenter.default.post(name: .ScheduleUpdated, object: nil) }
        })

        rootRef.child("tags").observe(.value, with: { snapshot in
            self.tags = snapshot.children.map{ Tag(snapshot: $0 as! DataSnapshot) }
            self.tagsReceived = true
            self.notifyInitialDataReceived()
            if self.allDataReceivedNotificationSent { NotificationCenter.default.post(name: .TagsUpdated, object: nil) }
        })

        rootRef.child("partners").observe(.value, with: { snapshot in
            self.partnerGroups = snapshot.children.map{ PartnerGroup(snapshot: $0 as! DataSnapshot) }
            self.partnerGroupsReceived = true
            self.notifyInitialDataReceived()
            if self.allDataReceivedNotificationSent { NotificationCenter.default.post(name: .PartnerUpdated, object: nil) }
        })

        rootRef.child("team").observe(.value, with: { snapshot in
            self.team = snapshot.children.map{ Team(snapshot: $0 as! DataSnapshot) }
            self.teamReceived = true
            self.notifyInitialDataReceived()
            if self.allDataReceivedNotificationSent { NotificationCenter.default.post(name: .TeamUpdated, object: nil) }
        })

        rootRef.child("venues").observe(.value, with: { snapshot in
            self.venues = snapshot.children.map{ Venue(snapshot: $0 as! DataSnapshot) }
            self.venuesReceived = true
            self.notifyInitialDataReceived()
            if self.allDataReceivedNotificationSent { NotificationCenter.default.post(name: .VenuesUpdated, object: nil) }
        })

        rootRef.child("resources").observe(.value, with: { snapshot in
            var newItems: [String: String] = [:]
            for resourceSnapshot in snapshot.children {
                newItems[(resourceSnapshot as! DataSnapshot).key] = (resourceSnapshot as! DataSnapshot).value as! String?
            }
            self.resources = newItems
            self.resourcesReceived = true
            self.notifyInitialDataReceived()
            if self.allDataReceivedNotificationSent { NotificationCenter.default.post(name: .ResourcesUpdated, object: nil) }
        })

        rootRef.child("videos").observe(.value, with: { snapshot in
            self.videos = snapshot.children.map{ Video(snapshot: $0 as! DataSnapshot) }
            self.videosReceived = true
            self.notifyInitialDataReceived()
            if self.allDataReceivedNotificationSent { NotificationCenter.default.post(name: .VideosUpdated, object: nil) }
        })

        rootRef.child(Endpoint.lotteryPartners.rawValue).observe(.value, with: { snapshot in
            self.lotteryPartners = snapshot.children.map{ Partner(snapshot: $0 as! DataSnapshot) }
            self.lotteryPartnersReceived = true
            self.notifyInitialDataReceived()
            if self.allDataReceivedNotificationSent { NotificationCenter.default.post(name: .LotteryPartnersUpdated, object: nil) }
        })
    }

    func startMonitoringUser() {
        handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            if (user != nil) {
                NotificationCenter.default.post(name: .UserDidSignIn, object: nil)
                DataManager.sharedInstance.startObservingUserData()
            }
            else {
                NotificationCenter.default.post(name: .UserDidSignOut, object: nil)
                self.favourites = []
                self.feedbacks = []
            }
        }
    }

    func startObservingUserData() {

        guard let userID = Auth.auth().currentUser?.uid else { return }

        rootRef.child(Endpoint.favourites.rawValue).child(userID).observe(.value, with: { snapshot in
            self.favourites = snapshot.children.map{ Int(($0 as! DataSnapshot).key)! }
            NotificationCenter.default.post(name: .FavouritesUpdated, object: nil)
        })

        rootRef.child(Endpoint.feedbacks.rawValue).child(userID).observe(.value, with: { snapshot in
            var newItems: [Feedback] = []
            for feedbackSnapshot in snapshot.children {
                let currentFeedback = Feedback(snapshot: feedbackSnapshot as! DataSnapshot)
                currentFeedback.sessionID = Int((feedbackSnapshot as! DataSnapshot).key)
                newItems.append(currentFeedback)
            }
            self.feedbacks = newItems
            NotificationCenter.default.post(name: .FeedbacksUpdated, object: nil)
        })

        rootRef.child(Endpoint.lottery.rawValue).observe(.value, with: { snapshot in
            var newItems: [String : [String: String]] = [:]

            for lotteryParticipantsRecord in snapshot.children {
                let lotteryPartnerRecordDataSnapshot = lotteryParticipantsRecord as! DataSnapshot

                var participants = [String: String]()
                for participantsRecord in lotteryPartnerRecordDataSnapshot.children {
                    guard let snapshot = participantsRecord as? DataSnapshot else { return }
                    guard let participantEmail = snapshot.value as? String else { return }
                    participants[snapshot.key] = participantEmail
                }
                newItems[lotteryPartnerRecordDataSnapshot.key] = participants
            }
            self.lotteryParticipantsRecords = newItems
            NotificationCenter.default.post(name: .LotteryParticipantsUpdated, object: nil)
        })

    }

    func getSpeaker(by speakerID: Int) -> Speaker? {
        return self.speakers.filter{ $0.speakerID == speakerID }.first ?? nil
    }

    func getSession(by sessionID: Int) -> Session? {
        return self.sessions.filter{ $0.sessionID == sessionID }.first ?? nil
    }

    func getTag(by tagTitle: String) -> Tag? {
        return self.tags.filter{ $0.title?.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "").caseInsensitiveCompare(tagTitle.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "")) == .orderedSame }.first ?? nil
    }

    func getSessionsForSpeaker(withID speakerID: Int) -> [Session] {
        return self.sessions.filter{ $0.speakersIDs.contains(speakerID) }
    }

    func getFeeback(by sessionID: Int) -> Feedback? {
        return self.feedbacks.filter{ $0.sessionID == sessionID }.first ?? nil
    }

    func searchSpeakers(_ search: String) -> [Speaker] {
        return self.speakers.filter { speaker in
            var include = false
            var searchSources: [String] = [speaker.name ?? ""]
            searchSources.append(contentsOf: speaker.tags)
            for searchSource in searchSources {
                if searchSource.range(of: search, options: .caseInsensitive, range: nil, locale: nil) != nil {
                    include = true
                }
            }
            return include
        }
    }

    func searchSessions(_ search: String) -> [Session] {
        return self.sessions.filter { session in
            var include = false
            var searchSources: [String] = [session.title ?? ""]
            searchSources.append(contentsOf: session.tags)
            for searchSource in searchSources {
                if searchSource.range(of: search, options: .caseInsensitive, range: nil, locale: nil) != nil {
                    include = true
                }
            }
            return include
        }
    }

    func getVideo(by videoID: Int) -> Video? {
        return self.videos.filter{ $0.videoID == videoID }.first ?? nil
    }

    func isCheckedAtPartner(withID identifier: String) -> Bool {
        guard let userID = Auth.auth().currentUser?.uid else { return false }
        if lotteryParticipantsRecords[identifier]?[userID] != nil {
            return true
        } else {
            return false
        }
    }

}
