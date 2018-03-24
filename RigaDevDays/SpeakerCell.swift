//  Copyright © 2017 RigaDevDays. All rights reserved.

import UIKit
import Kingfisher
import QuartzCore

class SpeakerCell: UITableViewCell {

    @IBOutlet weak var speakerIcon: UIImageView!
    @IBOutlet weak var speakerName: UILabel!
    @IBOutlet weak var speakerCompany: UILabel!
    @IBOutlet weak var speakerTags: UILabel!
    @IBOutlet weak var speakerTagsWithDots: UILabel!
    @IBOutlet weak var speakerBio: UILabel!
    @IBOutlet weak var imageBackground: UIView!
    @IBOutlet weak var speakerTitle: UILabel!

    @IBOutlet weak var separatorLineHeightConstraint: NSLayoutConstraint!

    var speakerDescriptionLinesCount: Int = 7

    var speaker: Speaker? {
        didSet {
            speakerName?.text = speaker?.name
            speakerCompany?.text = speaker?.company
            speakerBio?.numberOfLines = speakerDescriptionLinesCount
            speakerTags?.attributedText = TagColorManager.sharedInstance.getTags(for: speaker!)
            speakerTagsWithDots?.attributedText = TagColorManager.sharedInstance.getTags(for: speaker!, withDots: true)

            if let url = URL(string: Config.sharedInstance.baseURLPrefix + (speaker?.photoURL)!) {
                speakerIcon?.kf.indicatorType = .activity
                speakerIcon?.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
            speakerBio?.setHTMLFromString(htmlText: (speaker?.bio)!)
            speakerTitle?.text = speaker?.title
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        speakerIcon.layer.cornerRadius = speakerIcon.frame.size.width / 2
        speakerIcon.layer.masksToBounds = true
        imageBackground.layer.cornerRadius = imageBackground.frame.size.width / 2
        imageBackground.layer.masksToBounds = true

        separatorLineHeightConstraint?.constant = 0.5
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // code common to all your cells goes here
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
