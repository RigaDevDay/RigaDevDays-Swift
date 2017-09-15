//
//  MoreViewController.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 05/03/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import UIKit
import Firebase

class MoreViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var moreTableView: UITableView!

    var teamDisplayed = true
    var showFullDescription = true
    var selectedVenue: Venue?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .PartnerUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .VenuesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .ResourcesUpdated, object: nil)
        
        moreTableView.estimatedRowHeight = moreTableView.rowHeight
        moreTableView.rowHeight = UITableViewAutomaticDimension

        if let offset = self.tabBarController?.tabBar.frame.height {
            let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, offset, 0);
            //Where tableview is the IBOutlet for your storyboard tableview.
            moreTableView.contentInset = adjustForTabbarInsets;
            moreTableView.scrollIndicatorInsets = adjustForTabbarInsets;
        }

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: moreTableView)
        }
    }

    @objc func dataChanged() {
        moreTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVenue" {
            if let venueController = segue.destination as? VenueViewController {
                venueController.venue = selectedVenue
            }
        }
    }

    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            teamDisplayed = true
        default:
            teamDisplayed = false
        }
        moreTableView.reloadData()
    }
}

extension MoreViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + DataManager.sharedInstance.team.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return teamDisplayed ? 0 : DataManager.sharedInstance.venues.count
        case 1:
            return teamDisplayed ? 2 : 0
        default:
            return teamDisplayed ? DataManager.sharedInstance.team[section-2].members.count : 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return nil
        default:
            if teamDisplayed {
                let title = DataManager.sharedInstance.team[section-2].title
                return title?.isEmpty == false ? title : "Other"
            } else {
                return nil
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell: VenueCell = tableView.dequeueReusableCell(withIdentifier: "VenueCell", for: indexPath) as! VenueCell
            cell.venue = DataManager.sharedInstance.venues[indexPath.row]
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell_Header", for: indexPath) as! ActionCell
                cell.actionTitle.numberOfLines = showFullDescription == false ? 0 : 2
                if let string = DataManager.sharedInstance.resources["team-page-text"] {
                    cell.actionTitle.setHTMLFromString(htmlText: string)
                }
                return cell
            default:
                let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
                cell.actionTitle.text = showFullDescription == false ? "Show less" : "Show more"
                return cell
            }

        default:
            let cell: SpeakerCell = tableView.dequeueReusableCell(withIdentifier: "SpeakerCell", for: indexPath) as! SpeakerCell
            cell.speaker = DataManager.sharedInstance.team[indexPath.section-2].members[indexPath.row]
            return cell
        }
    }
}

extension MoreViewController: UITableViewDelegate {

    // do not remove this; table view cannot calculate proper height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
        case 0:
            selectedVenue = DataManager.sharedInstance.venues[indexPath.row]
            performSegue(withIdentifier: "showVenue", sender: nil)
        case 1:
            if indexPath.row == 1 {
                showFullDescription = !showFullDescription
                tableView.reloadSections(IndexSet.init(integer: indexPath.section), with: .automatic)
            }
        default:
            let member = DataManager.sharedInstance.team[indexPath.section-2].members[indexPath.row]

            let activityController = UIAlertController.init(title: nil, message: "Contacts", preferredStyle: .actionSheet)
            for social in member.socials {
                let socialActivity = UIAlertAction.init(title: social.name, style: .default, handler: { (action) in
                    if let url = URL.init(string: social.link!) {
                        UIApplication.shared.openURL(url)
                    }
                })
                activityController.addAction(socialActivity)
            }

            let cancelActivity = UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) in
                // do nothing
            })
            activityController.addAction(cancelActivity)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.present(activityController, animated: true, completion: nil)
            })
        }
    }
}

extension MoreViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = moreTableView.indexPathForRow(at: location) else { return nil }

        if indexPath.section == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "VenueViewController")
            guard let venueViewController = viewController as? VenueViewController else { return nil }
            venueViewController.venue = DataManager.sharedInstance.venues[indexPath.row]
            let cellRect = moreTableView.rectForRow(at: indexPath)
            previewingContext.sourceRect = previewingContext.sourceView.convert(cellRect, from: moreTableView)

            return venueViewController
        } else {
            return nil
        }
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let venueViewController = viewControllerToCommit as? VenueViewController {
            let _ = venueViewController.venue
        }
        show(viewControllerToCommit, sender: self)
    }
}
