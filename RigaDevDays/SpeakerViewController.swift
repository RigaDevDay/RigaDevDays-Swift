//
//  SpeakerViewController.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 29/01/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Firebase

class SpeakerViewController: UIViewController {

    @IBOutlet weak var speakerTableView: UITableView!

    var showFullSpeakerDescription: Bool = false

    var speaker: Speaker?
    var selectedSession: Session?

    override func viewDidLoad() {
        super.viewDidLoad()

        speakerTableView.estimatedRowHeight = speakerTableView.rowHeight
        speakerTableView.rowHeight = UITableViewAutomaticDimension

        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .favouritesUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .userDidSignInNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .userDidSignOutNotification, object: nil)

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: speakerTableView)
        }

        updateNavigationButtons()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSession" {
            if let sessionViewController = segue.destination as? SessionViewController {
                sessionViewController.session = selectedSession
            }
        }
    }

    func dataChanged() {
        speakerTableView.reloadData()
    }

    func updateNavigationButtons() {

        var rightBarButtonItems: [UIBarButtonItem] = []

        let shareButton = UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(shareSpeaker))
        rightBarButtonItems.append(shareButton)

        navigationItem.rightBarButtonItems = rightBarButtonItems
    }

    func shareSpeaker() {
        if let text = speaker?.name, let url = URL.init(string: (speaker?.speakerURL)!) {
            let dataToShare = ["dataToShare": [ text, url ] ]
            NotificationCenter.default.post(name: .shareItemsNotification, object: nil, userInfo: dataToShare)
        }
    }

    //MARK: -

    override var previewActionItems: [UIPreviewActionItem] {
        var actions: [UIPreviewActionItem] = []

        let shareAction = UIPreviewAction(title: "Share", style: .default) { [weak self] (action: UIPreviewAction, viewController: UIViewController) -> Void in
            self?.shareSpeaker()
        }
        actions.append(shareAction)

        return actions
    }
}

extension SpeakerViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "Sessions"
        case 2:
            return "Socials"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return showFullSpeakerDescription == false ? 2 : 1
        case 1:
            return DataManager.sharedInstance.getSessionsForSpeaker(withID: (speaker?.speakerID)!).count
        case 2:
            return (speaker?.socials.count)!
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell: SpeakerCell = tableView.dequeueReusableCell(withIdentifier: "SpeakerCell", for: indexPath) as! SpeakerCell
                cell.speakerDescriptionLinesCount = showFullSpeakerDescription == false ? 7 : 0
                cell.speaker = self.speaker
                return cell
            default:
                let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
                return cell
            }

        case 1:
            let cell: SessionCell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath) as! SessionCell
            cell.session = DataManager.sharedInstance.getSessionsForSpeaker(withID: (speaker?.speakerID)!)[indexPath.row]
            return cell
        case 2:
            let cell: SocialCell = tableView.dequeueReusableCell(withIdentifier: "SocialCell", for: indexPath) as! SocialCell
            cell.social = speaker?.socials[indexPath.row]
            return cell

        default:
            let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
            return cell
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        if indexPath.section == 1 {
            if (FIRAuth.auth()?.currentUser?.uid) != nil {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }


}

extension SpeakerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 1:
                showFullSpeakerDescription = true
                tableView.reloadSections(IndexSet.init(integer: indexPath.section), with: .automatic)
            default:
                // do nothing here
                break
            }

        case 1:
            selectedSession = DataManager.sharedInstance.getSessionsForSpeaker(withID: (speaker?.speakerID)!)[indexPath.row]
            performSegue(withIdentifier: "showSession", sender: nil)
        case 2:
            if let url = URL.init(string: (speaker?.socials[indexPath.row].link)!) {
                UIApplication.shared.openURL(url)
            }
        default:
            // do nothing here

            break
        }

        tableView .deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {

        guard editActionsForRowAt.section == 1, let speakerID = speaker?.speakerID  else {
            return nil
        }

        let session =  DataManager.sharedInstance.getSessionsForSpeaker(withID: speakerID)[editActionsForRowAt.row]

        var toggleFavourite: UITableViewRowAction
        if session.isFavourite {

            toggleFavourite = UITableViewRowAction(style: .normal, title: " ★ Remove") { action, index in
                session.toggleFavourite(completionBlock: { (error, reference) in
                    tableView.reloadRows(at: [editActionsForRowAt], with: .automatic)
                })
            }
            toggleFavourite.backgroundColor = .orange

        } else {
            toggleFavourite = UITableViewRowAction(style: .normal, title: " ★ Add") { action, index in
                session.toggleFavourite(completionBlock: { (error, reference) in
                    tableView.reloadRows(at: [editActionsForRowAt], with: .automatic)
                })
            }
            toggleFavourite.backgroundColor = .rddDefaultColor
        }

        return [toggleFavourite]
    }
}

extension SpeakerViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = speakerTableView.indexPathForRow(at: location) else { return nil }

        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SessionViewController_ID")
        guard let sessionViewController = viewController as? SessionViewController else { return nil }

        sessionViewController.session = DataManager.sharedInstance.getSessionsForSpeaker(withID: (speaker?.speakerID)!)[indexPath.row]
        let cellRect = speakerTableView.rectForRow(at: indexPath)
        previewingContext.sourceRect = previewingContext.sourceView.convert(cellRect, from: speakerTableView)
        return sessionViewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let _ = viewControllerToCommit as? SessionViewController {

        }
        show(viewControllerToCommit, sender: self)
    }
}
