//  Copyright © 2018 RigaDevDays. All rights reserved.

import UIKit
import Firebase

class LotteryParticipantsController: UIViewController {

    @IBOutlet weak var participantsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .LotteryParticipantsUpdated, object: nil)
    }
    
    @objc
    func dataChanged() {
        participantsTableView.reloadData()
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func exportParticipants(_ sender: UIBarButtonItem) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let records = DataManager.sharedInstance.lotteryParticipantsRecords[userID] else { return }

        let result: String = records.values.sorted().joined(separator: "\n")

        let items = [result];
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }
}

extension LotteryParticipantsController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let userID = Auth.auth().currentUser?.uid else { return 0 }
        return DataManager.sharedInstance.lotteryParticipantsRecords[userID]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: LotteryParticipantCell = tableView.dequeueReusableCell(withIdentifier: "LotteryParticipantCell", for: indexPath) as? LotteryParticipantCell else {
            return UITableViewCell()
        }
        guard let userID = Auth.auth().currentUser?.uid else { return UITableViewCell() }

        guard let records = DataManager.sharedInstance.lotteryParticipantsRecords[userID] else {
            return UITableViewCell()
        }
        cell.participantEmail.text = records.values.sorted()[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension LotteryParticipantsController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            guard let userID = Auth.auth().currentUser?.uid else { return }

            guard let records = DataManager.sharedInstance.lotteryParticipantsRecords[userID] else { return }
            let email = records.values.sorted()[indexPath.row]
            guard let key = records.filter({ $0.value == email }).first?.key else { return }

            DataManager.sharedInstance.rootRef.child(Endpoint.lottery.rawValue)
                .child(userID).child(key).removeValue()
        }
    }
}

