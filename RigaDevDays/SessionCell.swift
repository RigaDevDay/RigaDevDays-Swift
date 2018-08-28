//  Copyright © 2017 RigaDevDays. All rights reserved.

import UIKit
import Kingfisher
import QuartzCore

class SessionCell: UITableViewCell {

    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var sessionRoom: UILabel!
    @IBOutlet weak var sessionSpeakerName: UILabel!
    @IBOutlet weak var colorCodeView: UIView!
    @IBOutlet weak var favouriteSignLabel: UILabel!
    @IBOutlet weak var favouriteSignRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sessionLocationAndTime: UILabel!
    @IBOutlet weak var sessionSpeakers: UILabel!
    @IBOutlet weak var imageBackground: UIView!
    @IBOutlet weak var speakerImage: UIImageView!
    @IBOutlet weak var sessionDescription: UILabel!
    @IBOutlet weak var sessionTags: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var separatorLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var speakerImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sessionImage: UIImageView!
    @IBOutlet weak var imageGradient: UIImageView!

    var day: Day?

    var session: Session? {
        didSet {
            sessionName.text = session?.title

            if let properDay = (self.day != nil) ? self.day : session?.day,
                let room = session?.track?.title,
                let startTime = session?.timeslot?.startTime,
                let endTime = session?.timeslot?.endTime,
                let date = properDay.localizedDate {
                sessionRoom?.text = "\(room) - \(startTime) - \(endTime)"
                sessionLocationAndTime?.text = "\(room) - \(startTime) - \(endTime) / \(date)"
            } else {
                sessionRoom?.text = session?.track?.title
                sessionLocationAndTime?.text = session?.track?.title
            }
            sessionSpeakerName?.text = session?.speakers.first?.name
            colorCodeView?.backgroundColor = session?.color
            sessionDescription?.setHTMLFromString(htmlText: (session?.description)!)

            if let photoURL = session?.speakers.first?.photoURL, photoURL.contains("http"), let imageURL = URL(string: photoURL) {
                self.speakerImage?.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
            } else if let photoReference = session?.speakers.first?.speakerPhotoReference {
                photoReference.downloadURL(completion: { (url, error) in
                    self.imageBackground?.isHidden = false
                    self.speakerImageHeightConstraint?.constant = self.speakerImage.frame.size.width
                    self.speakerImage?.kf.indicatorType = .activity
                    self.speakerImage?.kf.setImage(with: url, options: [.transition(.fade(0.2))])
                })
            } else {
                self.speakerImageHeightConstraint?.constant = 0
                self.imageBackground?.isHidden = true
            }

            if let sessionImageURL = session?.image, let url = URL(string: Config.sharedInstance.baseURLPrefix + sessionImageURL) {
                sessionImage?.kf.indicatorType = .activity
                sessionImage?.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }

            if session?.speakers.first?.tags.count != nil,
                TagColorManager.sharedInstance.getTags(for: session!).string.isEmpty == false {
                tagsLabel?.isHidden = false
                sessionTags?.attributedText = TagColorManager.sharedInstance.getTags(for: session!)
            } else {
                tagsLabel?.isHidden = true
                sessionTags?.text = ""
            }

            if (session?.isFavourite)! {
                favouriteSignLabel?.text = "★"
                favouriteSignRightConstraint?.constant = 8.0
            } else {
                favouriteSignRightConstraint?.constant = 0
                favouriteSignLabel?.text = nil
            }

            guard sessionSpeakers != nil && (session?.speakers.count)! > 0 else {
                return
            }

            if (session?.speakers.count)! > 0 {
                var allSessionSpeakers = "by "
                for speaker in (session?.speakers)! {
                    if let speakerName = speaker.name {
                        allSessionSpeakers.append("\(speakerName), ")
                    }
                }
                //remove ", " at the end
                let endIndex = allSessionSpeakers.index(allSessionSpeakers.endIndex, offsetBy: -2)
                sessionSpeakers.text = allSessionSpeakers.substring(to: endIndex)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        colorCodeView?.layer.cornerRadius = colorCodeView.frame.width
        colorCodeView?.layer.masksToBounds = true

        speakerImage?.layer.cornerRadius = speakerImage.frame.width / 2
        speakerImage?.layer.masksToBounds = true

        imageBackground?.layer.cornerRadius = imageBackground.frame.width / 2
        imageBackground?.layer.masksToBounds = true

        separatorLineHeightConstraint?.constant = 0.5

        favouriteSignLabel?.textColor = Config.sharedInstance.themePrimaryColor
        sessionSpeakerName?.textColor = Config.sharedInstance.themePrimaryColor

        sessionSpeakers?.text = nil
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // code common to all your cells goes here
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
