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
    static let initialDataReceivedNotification = Notification.Name("initialDataReceivedNotification")
    static let userDidSignInNotification = Notification.Name("UserDidSignIn")
    static let userDidSignOutNotification = Notification.Name("UserDidSignOut")
    static let favouritesUpdatedNotification = Notification.Name("FavouritesUpdated")
    static let feebdacksUpdatedNotification = Notification.Name("FeedbacksUpdated")
    static let shareItemsNotification = Notification.Name("ShareItems")
}

extension UIColor {
    public class var rddDefaultColor: UIColor {
        return #colorLiteral(red: 0, green: 0.6509803922, blue: 0.9254901961, alpha: 1) // 00a6ec
    }

    public class var rddDarkBlue: UIColor {
        return #colorLiteral(red: 0.09019607843, green: 0.2274509804, blue: 0.337254902, alpha: 1) // 173a56
    }

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
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue],
            documentAttributes: nil)

        self.attributedText = attrStr
    }
}

extension UIViewController {

    func displaySessionButton(_ visible: Bool) {
        var sessionButton: UIBarButtonItem
        if FIRAuth.auth()?.currentUser != nil {
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

    func signInButtonPressed() {
        GIDSignIn.sharedInstance().signIn()
    }

    func signOutButtonPressed() {

        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()

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
                    singleTagWithColor.setAttributes([NSForegroundColorAttributeName : resultColor], range: NSRange(location:0, length:tagTitle.characters.count + offset))
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
                        singleTagWithColor.setAttributes([NSForegroundColorAttributeName : resultColor], range: NSRange(location:0, length:tagTitle.characters.count + 2))
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

    func update(_ event: inout EKEvent, on day: Day?, with session: Session) {
        event.title = session.title!
        event.startDate = session.duration(on: day).startDate
        event.endDate = session.duration(on: day).endDate
        var notes = ""
        if let speakerName = session.speakers.first?.name {
            notes.append(speakerName)
        }

        let attrStr = try! NSAttributedString(
            data: (session.description?.data(using: .unicode, allowLossyConversion: true)!)!,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        notes.append("\n\n" + attrStr.string)
        notes.append("\n\n" + session.sessionURL)
        event.notes = notes
        event.location = session.track?.title
    }

    func getEventDialogFor(_ session: Session, on day: Day?, completion: @escaping (EKEventEditViewController?) -> Swift.Void) {

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
                print("error \(error)")
                print("failed to save event with error : \(error) or access not granted")
                completion(nil)
            }
        }
    }

    func addToCalendar(session: Session, on day: Day?) {

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
                print("error \(error)")
                print("failed to save event with error : \(error) or access not granted")
            }
        }
    }

    func calendarEvent(for session: Session, on day: Day?) -> EKEvent? {

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
