//
//  FavouritesViewController.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 06/02/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class FavouritesViewController: UITableViewController {

    @IBOutlet weak var signInView: UIView!
    @IBOutlet var emptyView: UIView!

    var favourites: [Session] = []
    var selectedSession: Session?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .FavouritesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .UserDidSignIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .UserDidSignOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .SessionsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .TagsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .SpeakersUpdated, object: nil)

        reloadData()
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
                sessionViewController.session = selectedSession
            }
        }
    }

    @IBAction func signInButtonPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }

    func reloadData() {

        signInView.removeFromSuperview()
        emptyView.removeFromSuperview()

        if FIRAuth.auth()?.currentUser != nil {
            reloadFavourites()
        } else {
            tableView.addSubview(signInView)
            signInView.center = tableView.convert(tableView.center, from: tableView.superview)
            favourites = []
            tableView.reloadData()
        }
    }

    func reloadFavourites() {
        favourites = []

        emptyView.removeFromSuperview()
        signInView.removeFromSuperview()

        for day in DataManager.sharedInstance.days {
            for timeslot in day.timeslots {
                for session in timeslot.sessions {
                    if session.isFavourite {
                        session.assignedDay = day
                        favourites.append(session)
                    }
                }
            }
        }

        if favourites.count == 0 {
            tableView.addSubview(emptyView)
            emptyView.center = tableView.convert(tableView.center, from: tableView.superview)
        }

        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource -

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SessionCell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath) as! SessionCell
        cell.session = favourites[indexPath.row]
        return cell
    }

    // MARK: - UITableViewDelegate -

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedSession =  self.favourites[indexPath.row]
        performSegue(withIdentifier: "showSession", sender: nil)

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {

        let session =  self.favourites[editActionsForRowAt.row]

        var toggleFavourite: UITableViewRowAction
        if session.isFavourite {
            toggleFavourite = UITableViewRowAction(style: .normal, title: " ★ Remove") { action, index in
                session.toggleFavourite(completionBlock: { (error, reference) in
                    // do nothing
                })
            }
            toggleFavourite.backgroundColor = .orange

        } else {
            toggleFavourite = UITableViewRowAction(style: .normal, title: " ★ Add") { action, index in
                session.toggleFavourite(completionBlock: { (error, reference) in
                    // do nothing
                })
            }
            toggleFavourite.backgroundColor = Config.sharedInstance.themePrimaryColor
        }
        return [toggleFavourite]
    }
}

extension FavouritesViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SessionViewController_ID")
        guard let sessionViewController = viewController as? SessionViewController else { return nil }
        sessionViewController.session = self.favourites[indexPath.row]
        let cellRect = tableView.rectForRow(at: indexPath)
        previewingContext.sourceRect = previewingContext.sourceView.convert(cellRect, from: tableView)
        return sessionViewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let _ = viewControllerToCommit as? SessionViewController {
            //
        }
        show(viewControllerToCommit, sender: self)
    }
}
