//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import UIKit
import Firebase
import EventKitUI
import GoogleSignIn

class SessionViewController: UIViewController {

    let footerHeight: CGFloat = 20.0

    fileprivate enum TableSections: Int {
        case MainInfo
        case ShowMore
        case WatchVideo
        case AddToCalendar
        case UserActions
        case Feedback
        case Map
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

    @objc func updateNavigationButtons() {

        var rightBarButtonItems: [UIBarButtonItem] = []
        let shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(shareSession))
        rightBarButtonItems.append(shareButton)

        navigationItem.rightBarButtonItems = rightBarButtonItems
    }

    @objc func shareSession() {
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

    @objc func dataChanged() {
        sessionDetailsTableView.reloadData()
    }

    @objc func favouritesChanged(_ notification: Notification) {
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

        if Auth.auth().currentUser?.uid != nil {
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
        switch SwissKnife.app {
        case .rdd: return Config.sharedInstance.numberOfSectionsInSessionScreen - 1
        case .devfest, .frontcon: return Config.sharedInstance.numberOfSectionsInSessionScreen // -> amount of Section enum
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TableSections.MainInfo.rawValue:
            return 1
        case TableSections.ShowMore.rawValue:
            return 0
        case TableSections.WatchVideo.rawValue:
            return (session?.videos.count)! > 0 ? 1 : 0
        case TableSections.AddToCalendar.rawValue:
            return 1
        case TableSections.UserActions.rawValue:
            var actionsCount = 0

            actionsCount += 1 // add to favourites
            if (session?.speakers.count)! > 0
                && DataManager.sharedInstance.getFeeback(by: (session?.sessionID)!) == nil
                && DataManager.sharedInstance.remoteConfig["allow_leave_feedback"].boolValue
            {
                actionsCount += 1 // leave feedback
            }

            return actionsCount
        case TableSections.Feedback.rawValue:
            return (DataManager.sharedInstance.getFeeback(by: (session?.sessionID)!) != nil) ? 1 : 0
        case TableSections.Map.rawValue:
            switch SwissKnife.app {
            case .rdd, .frontcon: return 0
            case .devfest: return 1
            }
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == TableSections.Map.rawValue { return "Floor plan" }
        else {return nil }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case TableSections.MainInfo.rawValue:
            var cellIdentifier = "SessionCell"
            if session?.image != nil {
                cellIdentifier = "SessionCellWithImage"
            }
            let cell: SessionCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SessionCell
            cell.day = self.day
            cell.session = self.session
            return cell
        case TableSections.ShowMore.rawValue:
            let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ReadMoreActionCell", for: indexPath) as! ActionCell
            cell.actionTitle.text = "Show more"
            return cell
        case TableSections.WatchVideo.rawValue:
            let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
            cell.actionTitle.text = "Watch Video"
            return cell
        case TableSections.AddToCalendar.rawValue:
            let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
            let properDay = (self.day != nil) ? self.day : session?.day

            if SwissKnife.sharedInstance.calendarEvent(for: self.session!, on: properDay!) != nil {
                cell.actionTitle.text = "Remove from Calendar"
            } else {
                cell.actionTitle.text = "Add to Calendar"
            }
            return cell
        case TableSections.UserActions.rawValue:
            switch indexPath.row {
            case 0:
                let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
                if (session?.isFavourite)! {
                    cell.actionTitle.text = "Remove from Favourites"
                } else {
                    cell.actionTitle.text = "Add to Favourites"
                }
                return cell
            case 1:
                let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
                cell.actionTitle.text = "Leave Feedback"
                return cell
            default:
                let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
                return cell
            }

        case TableSections.Feedback.rawValue:
            let cell: FeedbackCell = tableView.dequeueReusableCell(withIdentifier: "FeedbackCell", for: indexPath) as! FeedbackCell
            cell.feedback = DataManager.sharedInstance.getFeeback(by: (session?.sessionID)!)
            return cell

        case TableSections.Map.rawValue:
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
        if indexPath.section == TableSections.Feedback.rawValue
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

        let feedbackAvailable: Bool
        if let sessionID = session?.sessionID {
            feedbackAvailable = DataManager.sharedInstance.getFeeback(by: sessionID) != nil
        } else {
            feedbackAvailable = false
        }

        switch section {
        case TableSections.UserActions.rawValue:
            return feedbackAvailable ? 0.0 : footerHeight
        case TableSections.Feedback.rawValue:
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
        case TableSections.UserActions.rawValue:
            return feedbackAvailable ? nil : footerView
        case TableSections.Feedback.rawValue:
            return feedbackAvailable ? footerView : nil
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case TableSections.MainInfo.rawValue:
            showFullSessionDescription = true
            tableView.reloadData()
        case TableSections.WatchVideo.rawValue:
            if let youtubeID = session?.videos.first?.youtubeID,
                let url = URL.init(string: "https://www.youtube.com/watch?v=\(youtubeID)") {
                UIApplication.shared.openURL(url)
            }
        case TableSections.AddToCalendar.rawValue:
            let properDay = (self.day != nil) ? self.day : session?.day
            if SwissKnife.sharedInstance.calendarEvent(for: self.session!, on: properDay!) != nil {
                SwissKnife.sharedInstance.removeFromCalendar(session: self.session!, on: properDay!)
            } else {
                SwissKnife.sharedInstance.getEventDialogFor(self.session!, on: properDay!, completion: { [weak self] (controller) in
                    if let addEventController = controller {
                        addEventController.editViewDelegate = self
                        addEventController.navigationBar.tintColor = .white
                        addEventController.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                            self?.present(addEventController, animated: true, completion: nil)
                        })
                    }
                })
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                tableView.reloadData()
            })

        case TableSections.UserActions.rawValue:
            switch indexPath.row {
            case 0:

                if Auth.auth().currentUser?.uid != nil {
                    self.toggleFavourite()
                } else {
                    GIDSignIn.sharedInstance().signIn()
                }
            case 1:
                if Auth.auth().currentUser?.uid != nil {
                performSegue(withIdentifier: "leaveFeedback", sender: self)
                } else {
                    GIDSignIn.sharedInstance().signIn()
                }
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

            guard let userID = Auth.auth().currentUser?.uid,
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

