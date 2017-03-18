//
//  DataManager.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 27/01/2017.
//  Copyright © 2017 RigaDevDay. All rights reserved.
//

import Foundation
import Firebase

enum Endpoint: String {
    case favourites = "userSessions"
    case feedbacks = "userFeedbacks"
}

class DataManager {
    static let sharedInstance = DataManager()

    let customImageURLPrefix = "http://rigadevdays.lv"

    let rootRef: FIRDatabaseReference!
    var handle: FIRAuthStateDidChangeListenerHandle?
    let remoteConfig: FIRRemoteConfig!
    let storage: FIRStorage!
    let storageRef: FIRStorageReference!

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

    var speakersReceived = false
    var sessionsReceived = false
    var schedueReceived = false
    var tagsReceived = false
    var partnerGroupsReceived = false
    var teamReceived = false
    var venuesReceived = false
    var resourcesReceived = false
    var allDataReceivedNotificationSent = false

    fileprivate init() {
        //This prevents others from using the default '()' initializer
        rootRef = FIRDatabase.database().reference()
        remoteConfig = FIRRemoteConfig.remoteConfig()
        storage = FIRStorage.storage()
        storageRef = storage.reference()

        activeRemoteConfiguration()
    }

    func activeRemoteConfiguration() {

        var developerMode = false
        #if DEBUG
            developerMode = true
        #endif

        let remoteConfigSettings = FIRRemoteConfigSettings(developerModeEnabled: developerMode)
        remoteConfig.configSettings = remoteConfigSettings!
        remoteConfig.setDefaultsFromPlistFileName("c")

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
        if allDataReceivedNotificationSent { return }

        if speakersReceived
            && sessionsReceived
            && schedueReceived
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

            NotificationCenter.default.post(name: .initialDataReceivedNotification, object: nil)
            allDataReceivedNotificationSent = true
        }
    }

    func startObservingPublicData() {

        rootRef.child("speakers").observe(.value, with: { snapshot in
            var newItems: [Speaker] = []
            for speakerSnapshot in snapshot.children {
                let currentItem = Speaker(snapshot: speakerSnapshot as! FIRDataSnapshot)
                newItems.append(currentItem)
            }
            self.speakers = newItems
            self.speakersReceived = true
            self.notifyInitialDataReceived()
        })

        rootRef.child("sessions").observe(.value, with: { snapshot in
            var newItems: [Session] = []
            for sessionSnapshot in snapshot.children {
                let currentSession = Session(snapshot: sessionSnapshot as! FIRDataSnapshot)
                newItems.append(currentSession)
            }
            self.sessions = newItems
            self.sessionsReceived = true
            self.notifyInitialDataReceived()
        })

        rootRef.child("schedule").observe(.value, with: { snapshot in
            var newItems: [Day] = []
            for daySnapshot in snapshot.children {
                let currentDay = Day(snapshot: daySnapshot as! FIRDataSnapshot)
                newItems.append(currentDay)
            }
            self.days = newItems
            self.schedueReceived = true
            self.notifyInitialDataReceived()
        })

        rootRef.child("tags").observe(.value, with: { snapshot in
            var newItems: [Tag] = []
            for tagSnapshot in snapshot.children {
                let currentTag = Tag(snapshot: tagSnapshot as! FIRDataSnapshot)
                newItems.append(currentTag)
            }
            self.tags = newItems
            self.tagsReceived = true
            self.notifyInitialDataReceived()
        })

        rootRef.child("partners").observe(.value, with: { snapshot in
            var newItems: [PartnerGroup] = []
            for partnerGroupSnapshot in snapshot.children {
                let currentPartnerGroup = PartnerGroup(snapshot: partnerGroupSnapshot as! FIRDataSnapshot)
                newItems.append(currentPartnerGroup)
            }
            self.partnerGroups = newItems
            self.partnerGroupsReceived = true
            self.notifyInitialDataReceived()
        })

        rootRef.child("team").observe(.value, with: { snapshot in
            var newItems: [Team] = []
            for teamSnapshot in snapshot.children {
                let currentTeam = Team(snapshot: teamSnapshot as! FIRDataSnapshot)
                newItems.append(currentTeam)
            }
            self.team = newItems
            self.teamReceived = true
            self.notifyInitialDataReceived()
        })

        rootRef.child("venues").observe(.value, with: { snapshot in
            var newItems: [Venue] = []
            for venueSnapshot in snapshot.children {
                let currentVenue = Venue(snapshot: venueSnapshot as! FIRDataSnapshot)
                newItems.append(currentVenue)
            }
            self.venues = newItems
            self.venuesReceived = true
            self.notifyInitialDataReceived()
        })

        rootRef.child("resources").observe(.value, with: { snapshot in
            var newItems: [String: String] = [:]
            for resourceSnapshot in snapshot.children {
                newItems[(resourceSnapshot as! FIRDataSnapshot).key] = (resourceSnapshot as! FIRDataSnapshot).value as! String?
            }
            self.resources = newItems
            self.resourcesReceived = true
            self.notifyInitialDataReceived()
        })
    }

    func startMonitoringUser() {
        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if (user != nil) {
                NotificationCenter.default.post(name: .userDidSignInNotification, object: nil)
                DataManager.sharedInstance.startObservingUserData()
            }
            else {
                NotificationCenter.default.post(name: .userDidSignOutNotification, object: nil)
                self.favourites = []
                self.feedbacks = []
            }
        }
    }

    func startObservingUserData() {

        let userID = FIRAuth.auth()?.currentUser?.uid
        rootRef.child(Endpoint.favourites.rawValue).child(userID!).observe(.value, with: { snapshot in
            var newItems: [Int] = []
            for favouriteSnapshot in snapshot.children {
                if let currentFavourite = Int((favouriteSnapshot as! FIRDataSnapshot).key) {
                    newItems.append(currentFavourite)
                }
            }
            self.favourites = newItems
            NotificationCenter.default.post(name: .favouritesUpdatedNotification, object: nil)
        })

        rootRef.child(Endpoint.feedbacks.rawValue).child(userID!).observe(.value, with: { snapshot in
            var newItems: [Feedback] = []
            for feedbackSnapshot in snapshot.children {
                let currentFeedback = Feedback(snapshot: feedbackSnapshot as! FIRDataSnapshot)
                currentFeedback.sessionID = Int((feedbackSnapshot as! FIRDataSnapshot).key)
                newItems.append(currentFeedback)
            }
            self.feedbacks = newItems
            NotificationCenter.default.post(name: .feebdacksUpdatedNotification, object: nil)
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
            var searchSources: [String] = [speaker.name!]
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
            var searchSources: [String] = [session.title!]
            searchSources.append(contentsOf: session.tags)
            for searchSource in searchSources {
                if searchSource.range(of: search, options: .caseInsensitive, range: nil, locale: nil) != nil {
                    include = true
                }
            }
            return include
        }
    }
}
