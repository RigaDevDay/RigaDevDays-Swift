//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import UIKit
import Firebase

class FeedbackController: UITableViewController {

    var session: Session?

    var qualityOfContent: Int = 0
    var speakerPerformance: Int = 0

    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var speakerImage: UIImageView!
    @IBOutlet weak var speakersNames: UILabel!
    @IBOutlet weak var userComment: UITextView!
    @IBOutlet weak var imageBackground: UIView!

    @IBOutlet weak var qcButton1: UIButton!
    @IBOutlet weak var qcButton2: UIButton!
    @IBOutlet weak var qcButton3: UIButton!
    @IBOutlet weak var qcButton4: UIButton!
    @IBOutlet weak var qcButton5: UIButton!

    @IBOutlet weak var spButton1: UIButton!
    @IBOutlet weak var spButton2: UIButton!
    @IBOutlet weak var spButton3: UIButton!
    @IBOutlet weak var spButton4: UIButton!
    @IBOutlet weak var spButton5: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension

        userComment.text = ""
        updateQualityOfContent(0)
        updateSpeakerPerformance(0)

        speakerImage?.layer.cornerRadius = speakerImage.frame.width / 2
        speakerImage?.layer.masksToBounds = true
        imageBackground?.layer.cornerRadius = imageBackground.frame.width / 2
        imageBackground?.layer.masksToBounds = true

        if session != nil {
            updateSession(session!)
        }
    }

    //MARK: -

    func updateSession(_ session: Session) {
        sessionName.text = session.title
        if let photoURL = session.speakers.first?.photoURL, photoURL.contains("http"), let imageURL = URL(string: photoURL) {
            self.speakerImage?.kf.indicatorType = .activity
            self.speakerImage?.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
        } else if let photoReference = session.speakers.first?.speakerPhotoReference {
            photoReference.downloadURL(completion: { (url, error) in
                self.imageBackground?.isHidden = false
                self.speakerImage?.kf.indicatorType = .activity
                self.speakerImage?.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            })
        }

        var allSessionSpeakers = "by "
        for speaker in session.speakers {
            if let speakerName = speaker.name {
                allSessionSpeakers.append("\(speakerName), ")
            }
        }
        //remove ", " at the end
        let endIndex = allSessionSpeakers.index(allSessionSpeakers.endIndex, offsetBy: -2)
        speakersNames.text = allSessionSpeakers.substring(to: endIndex)
    }

    func updateQualityOfContent(_ rating:Int) {
        self.qualityOfContent = rating

        for button in [qcButton1, qcButton2, qcButton3, qcButton4, qcButton5] {
            if (button?.tag)! <= rating {
                button?.setImage(#imageLiteral(resourceName: "bigstar_full"), for: .normal)
            } else {
                button?.setImage(#imageLiteral(resourceName: "bigstar"), for: .normal)
            }
        }
    }

    func updateSpeakerPerformance(_ rating:Int) {
        self.speakerPerformance = rating

        for button in [spButton1, spButton2, spButton3, spButton4, spButton5] {
            if (button?.tag)! <= rating {
                button?.setImage(#imageLiteral(resourceName: "bigstar_full"), for: .normal)
            } else {
                button?.setImage(#imageLiteral(resourceName: "bigstar"), for: .normal)
            }
        }
    }

    //MARK: -

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            // do nothing
        }
    }

    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {

        guard let userID = Auth.auth().currentUser?.uid,
            let sessionID = session?.sessionID?.description
            else {
                return
        }

        let feedback = ["qualityOfContent" : qualityOfContent,
                        "speakerPerformance" : speakerPerformance,
                        "comment": userComment.text] as [String : Any]

        DataManager.sharedInstance.rootRef
            .child(Endpoint.feedbacks.rawValue)
            .child(userID)
            .updateChildValues([sessionID: feedback], withCompletionBlock: { (error, reference) in

                if error != nil {
                    print("failed to save feedback \(String(describing: error))")
                }

                self.dismiss(animated: true) {
                    // do nothing
                }
            })
    }

    @IBAction func qcButtonPressed(_ sender: UIButton) {
        self.updateQualityOfContent(sender.tag)
    }

    @IBAction func spButtonPressed(_ sender: UIButton) {
        self.updateSpeakerPerformance(sender.tag)
    }

    // do not remove this; table view cannot calculate proper height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
