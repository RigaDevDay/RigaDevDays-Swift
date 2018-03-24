//  Copyright © 2017 RigaDevDays. All rights reserved.

import UIKit
import Firebase

class DayViewController: UITableViewController {

    var selectedSession: Session?
    var selectedDay: Day?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSession" {
            if let sessionViewController = segue.destination as? SessionViewController {
                sessionViewController.day = self.selectedDay
                sessionViewController.session = selectedSession
            }
        }
    }

    // MARK: - UITableViewDataSource -

    override func numberOfSections(in tableView: UITableView) -> Int {
        return selectedDay?.timeslots.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectedDay?.timeslots[section].startTime
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedDay?.timeslots[section].sessions.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SessionCell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath) as! SessionCell
        cell.day = self.selectedDay
        cell.session = selectedDay?.timeslots[indexPath.section].sessions[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        if (Auth.auth().currentUser?.uid) != nil {
            return true
        } else {
            return false
        }
    }

    // MARK: - UITableViewDelegate -

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedSession =  selectedDay?.timeslots[indexPath.section].sessions[indexPath.row]
        performSegue(withIdentifier: "showSession", sender: nil)

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {

        if let session =  selectedDay?.timeslots[editActionsForRowAt.section].sessions[editActionsForRowAt.row] {

            var toggleFavourite: UITableViewRowAction
            if session.isFavourite {

                toggleFavourite = UITableViewRowAction(style: .normal, title: " ★ Remove") { action, index in
                    session.toggleFavourite(completionBlock: { (error, reference) in
//                        tableView.reloadRows(at: [editActionsForRowAt], with: .fade)
                        tableView.reloadData()
                    })
                }
                toggleFavourite.backgroundColor = .orange

            } else {
                toggleFavourite = UITableViewRowAction(style: .normal, title: " ★ Add") { action, index in
                    session.toggleFavourite(completionBlock: { (error, reference) in
//                        tableView.reloadRows(at: [editActionsForRowAt], with: .fade)
                        tableView.reloadData()
                    })
                }
                toggleFavourite.backgroundColor = Config.sharedInstance.themePrimaryColor
            }
            
            return [toggleFavourite]
        }
        
        return nil
    }
}

extension DayViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SessionViewController_ID")
        guard let sessionViewController = viewController as? SessionViewController else { return nil }
        sessionViewController.session = selectedDay?.timeslots[indexPath.section].sessions[indexPath.row]
        let cellRect = tableView.rectForRow(at: indexPath)
        previewingContext.sourceRect = previewingContext.sourceView.convert(cellRect, from: tableView)
        return sessionViewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let sessionViewController = viewControllerToCommit as? SessionViewController {
            print(sessionViewController.title ?? "session")
        }
        show(viewControllerToCommit, sender: self)
    }
}
