//
//  SpeakersViewController.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 26/01/2017.
//  Copyright © 2017 RigaDevDay. All rights reserved.
//

import UIKit
import Firebase

class SpeakersViewController: UIViewController  {

    @IBOutlet weak var speakersTableView: UITableView!
    var cellGap: Double = 10.0
    var selectedCellIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: speakersTableView)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSpeaker" {
            if let speakerViewController = segue.destination as? SpeakerViewController {
                speakerViewController.speaker = DataManager.sharedInstance.speakers[(selectedCellIndexPath?.row)!]
            }
        }
    }
}

extension SpeakersViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.sharedInstance.speakers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SpeakerCell = tableView.dequeueReusableCell(withIdentifier: "SpeakerCell", for: indexPath) as! SpeakerCell
        cell.speaker = DataManager.sharedInstance.speakers[indexPath.row]
        return cell
    }
}

extension SpeakersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedCellIndexPath = indexPath
        performSegue(withIdentifier: "showSpeaker", sender: nil)
        tableView .deselectRow(at: indexPath, animated: true)
    }
}

extension SpeakersViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = speakersTableView.indexPathForRow(at: location) else { return nil }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SpeakerViewController_ID")
        guard let speakerViewController = viewController as? SpeakerViewController else { return nil }
        speakerViewController.speaker = DataManager.sharedInstance.speakers[indexPath.row]
        let cellRect = speakersTableView.rectForRow(at: indexPath)
        previewingContext.sourceRect = previewingContext.sourceView.convert(cellRect, from: speakersTableView)

        return speakerViewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let SpeakerViewController = viewControllerToCommit as? SpeakerViewController {
           let _ = SpeakerViewController.speaker?.name
        }
        show(viewControllerToCommit, sender: self)
    }
}
