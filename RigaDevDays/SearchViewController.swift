//
//  SearchViewController.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 04/03/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {

    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var resultsAreDisplayed = false
    var speakers: [Speaker] = []
    var sessions: [Session] = []

    var selectedSession: Session?
    var selectedSpeaker: Speaker?

    var searchProposals: [String] {
        get {
            return ["Oracle", "Kotlin", "Mobile", "Internet of Things", "UI", "Big Data", "John Doe"]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchTableView.estimatedRowHeight = searchTableView.rowHeight
        searchTableView.rowHeight = UITableViewAutomaticDimension

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: searchTableView)
        }

        if let offset = self.tabBarController?.tabBar.frame.height {
            let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, offset, 0);
            //Where tableview is the IBOutlet for your storyboard tableview.
            searchTableView.contentInset = adjustForTabbarInsets;
            searchTableView.scrollIndicatorInsets = adjustForTabbarInsets;
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSession" {
            if let sessionViewController = segue.destination as? SessionViewController {
                sessionViewController.session = selectedSession
            }
        }

        if segue.identifier == "showSpeaker" {
            if let SpeakerViewController = segue.destination as? SpeakerViewController {
                SpeakerViewController.speaker = selectedSpeaker
            }
        }
    }

    // MARK: -
    func searchFor(_ string: String) {
        searchTableView.alwaysBounceVertical = true
        resultsAreDisplayed = true

        speakers = DataManager.sharedInstance.searchSpeakers(string)
        sessions = DataManager.sharedInstance.searchSessions(string)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.searchTableView.reloadData()
        })

    }
}

extension SearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {

            resultsAreDisplayed = false
            searchTableView.alwaysBounceVertical = false
            sessions = []
            speakers = []

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.searchTableView.reloadData()
            })
            return
        }

        if searchText.characters.count <= 2 {
            return
        }

        searchFor(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultsAreDisplayed = false
        searchTableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            searchBar.resignFirstResponder()
        })
    }
}

// Speakers
// Sessions
// Search header
// Search proposal

extension SearchViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return resultsAreDisplayed ? speakers.count : 0
        case 1:
            return resultsAreDisplayed ? sessions.count : 0
        case 2:
            return resultsAreDisplayed ? 0 : 1
        case 3:
            return resultsAreDisplayed ? 0 : searchProposals.count

        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return resultsAreDisplayed && speakers.count > 0 ? "Speakers" : nil
        case 1:
            return resultsAreDisplayed && sessions.count > 0 ? "Sessions" : nil
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell: SpeakerCell = tableView.dequeueReusableCell(withIdentifier: "SpeakerCell", for: indexPath) as! SpeakerCell
            cell.speaker = speakers[indexPath.row]
            return cell
        case 1:
            let cell: SessionCell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath) as! SessionCell
            cell.session = sessions[indexPath.row]
            return cell
        case 2:
            let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell_SearchHeader", for: indexPath) as! ActionCell
            return cell
        default:
            let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell_SearchSample", for: indexPath) as! ActionCell
            cell.actionTitle.text = searchProposals[indexPath.row]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        switch indexPath.section {
        case 1:
            if (FIRAuth.auth()?.currentUser?.uid) != nil {
                return true
            } else {
                return false
            }
        default:
            return false
        }
    }
}

extension SearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
        case 0:
            selectedSpeaker = speakers[indexPath.row]
            performSegue(withIdentifier: "showSpeaker", sender: nil)
        case 1:
            selectedSession =  sessions[indexPath.row]
            performSegue(withIdentifier: "showSession", sender: nil)
        case 2:
            searchBar.resignFirstResponder()
        case 3:
            let cell: ActionCell = tableView.cellForRow(at: indexPath) as! ActionCell
            searchBar.text = cell.actionTitle.text
            searchFor(searchBar.text!)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {

        let session =  sessions[editActionsForRowAt.row]

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
            toggleFavourite.backgroundColor = Config.sharedInstance.themePrimaryColor
        }

        return [toggleFavourite]
    }
}

extension SearchViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = searchTableView.indexPathForRow(at: location) else { return nil }

        switch indexPath.section {
        case 0:
            //speaker
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "SpeakerViewController_ID")
            guard let speakerViewController = viewController as? SpeakerViewController else { return nil }
            speakerViewController.speaker = speakers[indexPath.row]
            let cellRect = searchTableView.rectForRow(at: indexPath)
            previewingContext.sourceRect = previewingContext.sourceView.convert(cellRect, from: searchTableView)
            return speakerViewController
        case 1:
            // session
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SessionViewController_ID")
            guard let sessionViewController = viewController as? SessionViewController else { return nil }
            sessionViewController.session = sessions[indexPath.row] //selectedDay?.timeslots[indexPath.section].sessions[indexPath.row]
            let cellRect = searchTableView.rectForRow(at: indexPath)
            previewingContext.sourceRect = previewingContext.sourceView.convert(cellRect, from: searchTableView)
            return sessionViewController
        default:
            return nil
        }
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {

        if let speakerViewController = viewControllerToCommit as? SpeakerViewController {
            let _ = speakerViewController.speaker?.name
        }
        show(viewControllerToCommit, sender: self)

        if let sessionViewController = viewControllerToCommit as? SessionViewController {
            print(sessionViewController.title ?? "session")
            show(viewControllerToCommit, sender: self)
        }
    }
}
