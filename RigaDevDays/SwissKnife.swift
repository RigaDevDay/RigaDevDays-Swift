//
//  SwissKnife.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 30/01/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn
import EventKit
import EventKitUI

enum UserDefaultsKeys: String {
    case loggedInOnce = "LoggedInOnce"
}

enum CustomError: Error {
    case noUser
}

extension Notification.Name {
    static let AllDataReceived = Notification.Name("rdd.all.data.received")
    static let UserDidSignIn = Notification.Name("rdd.user.did.sign.in")
    static let UserDidSignOut = Notification.Name("rdd.user.did.sign.out")

    static let ShareItem = Notification.Name("rdd.user.share.item")

    static let FavouritesUpdated = Notification.Name("rdd.favourites.ppdated")
    static let FeedbacksUpdated = Notification.Name("rdd.feedbacks.updated")
    static let SpeakersUpdated = Notification.Name("rdd.speakers.updated")
    static let SessionsUpdated = Notification.Name("rdd.sessions.updated")
    static let ScheduleUpdated = Notification.Name("rdd.schedule.updated")
    static let TagsUpdated = Notification.Name("rdd.tags.updated")
    static let PartnerUpdated = Notification.Name("rdd.partners.updated")
    static let TeamUpdated = Notification.Name("rdd.team.updated")
    static let VenuesUpdated = Notification.Name("rdd.venues.updated")
    static let ResourcesUpdated = Notification.Name("rdd.resources.updated")
    static let VideosUpdated = Notification.Name("rdd.videos.updated")
}

extension UIColor {

    static public func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UILabel {
    func setHTMLFromString(htmlText: String) {

        guard htmlText.isEmpty == false else {
            return
        }

        let modifiedFont = NSString(format:"<span style=\"font-family: '-apple-system', '\(self.font.fontName)'; font-size: \(self.font!.pointSize)\">%@</span>" as NSString, htmlText) as String

        let attrStr = try! NSAttributedString(
            data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)

        self.attributedText = attrStr
    }
}

extension UIViewController {

    func displaySessionButton(_ visible: Bool) {
        var sessionButton: UIBarButtonItem
        if Auth.auth().currentUser != nil {
            sessionButton = UIBarButtonItem.init(title: "Sign Out", style: .plain, target: self, action: #selector(signOutButtonPressed))
        } else {
            sessionButton = UIBarButtonItem.init(title: "Sign In", style: .plain, target: self, action: #selector(signInButtonPressed))
        }
        if visible {
            self.navigationItem.rightBarButtonItem = sessionButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    @objc func signInButtonPressed() {
        GIDSignIn.sharedInstance().signIn()
    }

    @objc func signOutButtonPressed() {

        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()

            GIDSignIn.sharedInstance().signOut()

            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: UserDefaultsKeys.loggedInOnce.rawValue)

        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

class TagColorManager {
    static let sharedInstance = TagColorManager()
    var speakerTagsWithColor: [String : NSMutableAttributedString] = [:]
    var speakerTagsWithColorWithDot: [String : NSMutableAttributedString] = [:]
    var sessionTagsWithColor: [Int : NSMutableAttributedString] = [:]

    fileprivate init() {
        //This prevents others from using the default '()' initializer
    }

    func getTags(for speaker: Speaker, withDots: Bool = false) -> NSAttributedString {

        let key = withDots ? "\(speaker.name!)+dot" : "\(speaker.name!)"
        if let resultValue = speakerTagsWithColor[key] {
            return resultValue
        } else {

            let allTags = NSMutableAttributedString()
            for tagTitle in speaker.tags {
                if let tagColor = DataManager.sharedInstance.getTag(by: tagTitle)?.colorCode {
                    let resultColor = UIColor.hexStringToUIColor(hex: tagColor)
                    let singleTagWithColor = withDots ? NSMutableAttributedString(string: "● \(tagTitle)") : NSMutableAttributedString(string: tagTitle)
                    let offset = withDots ? 2 : 0
                    singleTagWithColor.setAttributes([NSAttributedStringKey.foregroundColor : resultColor], range: NSRange(location:0, length:tagTitle.characters.count + offset))
                    allTags.append(singleTagWithColor)
                    allTags.append(NSMutableAttributedString(string: " "))

                }
            }
            speakerTagsWithColor[key] = allTags
            return allTags
        }
    }

    func getTags(for session: Session) -> NSAttributedString {

        if let resultValue = sessionTagsWithColor[session.sessionID!] {
            return resultValue
        } else {

            let allTags = NSMutableAttributedString()

            for speaker in session.speakers {
                for tagTitle in speaker.tags {
                    if let tagColor = DataManager.sharedInstance.getTag(by: tagTitle)?.colorCode {
                        let resultColor = UIColor.hexStringToUIColor(hex: tagColor)
                        let singleTagWithColor = NSMutableAttributedString(string: "● \(tagTitle)")
                        singleTagWithColor.setAttributes([NSAttributedStringKey.foregroundColor : resultColor], range: NSRange(location:0, length:tagTitle.characters.count + 2))
                        allTags.append(singleTagWithColor)
                        allTags.append(NSMutableAttributedString(string: "  "))
                    }
                }
            }
            sessionTagsWithColor[session.sessionID!] = allTags
            return allTags
        }
    }
}

class SwissKnife {

    static let sharedInstance = SwissKnife()

    static let sessionShortDescriptionLinesCount = 7

    fileprivate init() {
        //This prevents others from using the default '()' initializer
    }

    func update(_ event: inout EKEvent, on day: Day, with session: Session) {
        event.title = session.title!
        event.startDate = session.duration(on: day).startDate
        event.endDate = session.duration(on: day).endDate
        var notes = ""
        if let speakerName = session.speakers.first?.name {
            notes.append(speakerName)
        }

        let attrStr = try! NSAttributedString(
            data: (session.description?.data(using: .unicode, allowLossyConversion: true)!)!,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        notes.append("\n\n" + attrStr.string)
        notes.append("\n\n" + session.sessionURL)
        event.notes = notes
        event.location = session.track?.title
    }

    func getEventDialogFor(_ session: Session, on day: Day, completion: @escaping (EKEventEditViewController?) -> Swift.Void) {

        let eventStore: EKEventStore = EKEventStore()

        eventStore.requestAccess(to: .event) { (granted, error) in

            if (granted) && (error == nil) {
                var event: EKEvent = EKEvent(eventStore: eventStore)
                self.update(&event, on: day, with: session)
                let controller = EKEventEditViewController.init()
                controller.eventStore = eventStore
                controller.event = event
                completion(controller)
            }
            else{
                print("granted \(granted)")
                print("error \(String(describing: error))")
                print("failed to save event with error : \(String(describing: error)) or access not granted")
                completion(nil)
            }
        }
    }

    func addToCalendar(session: Session, on day: Day) {

        let eventStore: EKEventStore = EKEventStore()

        eventStore.requestAccess(to: .event) { (granted, error) in

            if (granted) && (error == nil) {
                var event: EKEvent = EKEvent(eventStore: eventStore)
                self.update(&event, on: day, with: session)
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
            }
            else{
                print("granted \(granted)")
                print("error \(String(describing: error))")
                print("failed to save event with error : \(String(describing: error)) or access not granted")
            }
        }
    }

    func calendarEvent(for session: Session, on day: Day) -> EKEvent? {

        var event: EKEvent? = nil

        guard EKEventStore.authorizationStatus(for: .event) == .authorized else {
            return event
        }

        let eventStore: EKEventStore = EKEventStore()

        let startDate = session.duration(on: day).startDate
        let endDate = session.duration(on: day).endDate
        let title = session.title
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)
        for singleEvent in existingEvents {
            if singleEvent.title == title
                && singleEvent.startDate == startDate
                && singleEvent.endDate == endDate
            {
                event = singleEvent
            }
        }
        return event
    }

    func removeFromCalendar(session: Session, on day: Day) {

        guard EKEventStore.authorizationStatus(for: .event) == .authorized else {
            return
        }

        let eventStore: EKEventStore = EKEventStore()

        eventStore.requestAccess(to: .event) { (granted, error) in
            let startDate = session.duration(on: day).startDate
            let endDate = session.duration(on: day).endDate
            let title = session.title
            let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
            let existingEvents = eventStore.events(matching: predicate)
            for singleEvent in existingEvents {
                if singleEvent.title == title
                    && singleEvent.startDate == startDate
                    && singleEvent.endDate == endDate
                {
                    do {
                        try eventStore.remove(singleEvent, span: .thisEvent)
                    } catch let error as NSError {
                        print("failed to save event with error : \(error)")
                    }
                }
            }
        }
    }
}

extension EKEventEditViewController {

    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
}

extension UINavigationController {

    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
