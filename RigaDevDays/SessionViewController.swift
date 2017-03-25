//
//  SessionViewController.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 29/01/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import EventKitUI

class SessionViewController: UIViewController {

    let footerHeight: CGFloat = 20.0

    fileprivate enum Section: Int {
        case actions = 2
    }

    @IBOutlet weak var sessionDetailsTableView: UITableView!

    var day: Day?
    var session: Session?

    var showFullSessionDescription = false

    fileprivate var cellHeights: [IndexPath: CGFloat?] = [:]
    var expandedIndexPaths: [IndexPath] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        sessionDetailsTableView.estimatedRowHeight = sessionDetailsTableView.rowHeight
        sessionDetailsTableView.rowHeight = UITableViewAutomaticDimension

        updateNavigationButtons()

        NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationButtons), name: .UserDidSignIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationButtons), name: .UserDidSignOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(favouritesChanged), name: .FavouritesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .FeedbacksUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .SpeakersUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .SessionsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .TagsUpdated, object: nil)
    }

    func updateNavigationButtons() {

        var rightBarButtonItems: [UIBarButtonItem] = []
        let shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(shareSession))
        rightBarButtonItems.append(shareButton)

        navigationItem.rightBarButtonItems = rightBarButtonItems
    }

    func shareSession() {
        if let text = session?.title, let url = URL.init(string: (session?.sessionURL)!) {
            let dataToShare = ["dataToShare": [ text, url ] ]
            NotificationCenter.default.post(name: .ShareItem, object: nil, userInfo: dataToShare)
        }
    }

    func toggleFavourite() {
        session?.toggleFavourite(completionBlock: { (error, reference) in
            // do nothing here
        })
    }

    func dataChanged() {
        sessionDetailsTableView.reloadData()
    }

    func favouritesChanged(_ notification: Notification) {
        sessionDetailsTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "leaveFeedback" {
            if let wrapper = segue.destination as? UINavigationController,
                let feedbackController = wrapper.topViewController as? FeedbackController {
                feedbackController.session = self.session
            }
        }
    }

    //MARK: -

    override var previewActionItems: [UIPreviewActionItem] {
        var actions: [UIPreviewActionItem] = []
        let shareAction = UIPreviewAction(title: "Share", style: .default) { (action: UIPreviewAction, viewController: UIViewController) -> Void in
            self.shareSession()
        }
        actions.append(shareAction)

        if FIRAuth.auth()?.currentUser?.uid != nil {
            if (session?.isFavourite)! {

                let removeFromFavourites = UIPreviewAction(title: "Remove from Favourites", style: .default) { (action: UIPreviewAction, viewController: UIViewController) -> Void in
                    self.toggleFavourite()
                }
                actions.append(removeFromFavourites)
            } else {
                let addToFavourites = UIPreviewAction(title: "Add to Favourites", style: .default) { (action: UIPreviewAction, viewController: UIViewController) -> Void in
                    self.toggleFavourite()
                }
                actions.append(addToFavourites)
            }
        }
        return actions
    }
}

extension SessionViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 0
        case Section.actions.rawValue:
            //actions
            var actionsCount = 1 // add to calendar

            if FIRAuth.auth()?.currentUser?.uid != nil {
                actionsCount += 1 // add to favourites
                if (session?.speakers.count)! > 0
                    && DataManager.sharedInstance.getFeeback(by: (session?.sessionID)!) == nil
                    && DataManager.sharedInstance.remoteConfig["allow_leave_feedback"].boolValue
                {
                    actionsCount += 1 // leave feedback
                }
            }

            return actionsCount
        case 3:
            return (DataManager.sharedInstance.getFeeback(by: (session?.sessionID)!) != nil) ? 1 : 0
        case 4:
            return 1 // map
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 4 { return "Floor plan" }
        else {return nil }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            var cellIdentifier = "SessionCell"
            if session?.image != nil {
                cellIdentifier = "SessionCellWithImage"
            }
            let cell: SessionCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SessionCell
            cell.day = self.day
            cell.session = self.session
            return cell
        case 1:
            let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ReadMoreActionCell", for: indexPath) as! ActionCell
            cell.actionTitle.text = "Show more"
            return cell
        case Section.actions.rawValue:

            switch indexPath.row {
            case 0:
                let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
                let properDay = (self.day != nil) ? self.day : session?.day

                if SwissKnife.sharedInstance.calendarEvent(for: self.session!, on: properDay!) != nil {
                    cell.actionTitle.text = "Remove from Calendar"
                } else {
                    cell.actionTitle.text = "Add to Calendar"
                }
                return cell
            case 1:
                let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
                if (session?.isFavourite)! {
                    cell.actionTitle.text = "Remove from Favourites"
                } else {
                    cell.actionTitle.text = "Add to Favourites"
                }
                return cell
            case 2:
                let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
                cell.actionTitle.text = "Leave Feedback"
                return cell
            default:
                let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
                return cell
            }

        case 3:
            let cell: FeedbackCell = tableView.dequeueReusableCell(withIdentifier: "FeedbackCell", for: indexPath) as! FeedbackCell
            cell.feedback = DataManager.sharedInstance.getFeeback(by: (session?.sessionID)!)
            return cell

        case 4:
            let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell_Map", for: indexPath) as! ActionCell
            if let imageName = session?.track?.title,
                let image = UIImage.init(named: imageName) {
                cell.actionImage.image = image
            }
            return cell
        default:
            let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
            return cell
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        if indexPath.section == 3
            && DataManager.sharedInstance.remoteConfig["allow_delete_feedback"].boolValue {
            return true
        } else {
            return false
        }
    }
}

extension SessionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = cellHeights[indexPath] {
            return height ?? UITableViewAutomaticDimension
        }
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

       let feedbackAvailable = (DataManager.sharedInstance.getFeeback(by: (session?.sessionID)!) != nil)

        switch section {
        case 2:
            return feedbackAvailable ? 0.0 : footerHeight
        case 3:
            return feedbackAvailable ? footerHeight : 0.0
        default:
            return 0
        }

    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let feedbackAvailable = (DataManager.sharedInstance.getFeeback(by: (session?.sessionID)!) != nil)
        let footerView = UIView.init()
        footerView.backgroundColor = UIColor.clear
        switch section {
        case 2:
            return feedbackAvailable ? nil : footerView
        case 3:
            return feedbackAvailable ? footerView : nil
        default:
            return nil
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
        case 1:
            showFullSessionDescription = true
            tableView.reloadData()
        case Section.actions.rawValue:
            switch indexPath.row {
            case 0:
                let properDay = (self.day != nil) ? self.day : session?.day
                if SwissKnife.sharedInstance.calendarEvent(for: self.session!, on: properDay!) != nil {
                    SwissKnife.sharedInstance.removeFromCalendar(session: self.session!, on: properDay!)
                } else {
                    SwissKnife.sharedInstance.getEventDialogFor(self.session!, on: properDay!, completion: { [weak self] (controller) in
                        if let addEventController = controller {
                            addEventController.editViewDelegate = self
                            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                self?.present(addEventController, animated: true, completion: nil)
                            })
                        }
                    })
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    tableView.reloadData()
                })

            case 1:
                self.toggleFavourite()
            case 2:
                performSegue(withIdentifier: "leaveFeedback", sender: self)
            default:
                break
            }
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }


    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {

        let removeFeedback = UITableViewRowAction(style: .normal, title: "Remove") { action, index in

            guard let userID = FIRAuth.auth()?.currentUser?.uid,
                let sessionID = self.session?.sessionID?.description else {
                    return
            }

            DataManager.sharedInstance.rootRef
                .child(Endpoint.feedbacks.rawValue)
                .child(userID)
                .child(sessionID)
                .removeValue(completionBlock: { (error, reference) in
                    if (error != nil) {
                        print("failed to remove \(String(describing: error))")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        tableView.reloadData()
                    })
                })
        }
        removeFeedback.backgroundColor = .red
        
        return [removeFeedback]
    }
}

extension SessionViewController: EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        self.dismiss(animated: true) { 
            self.sessionDetailsTableView.reloadData()
        }
    }
}

