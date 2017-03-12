//
//  SocialCell.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 23/02/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import UIKit

class SocialCell: UITableViewCell {

    @IBOutlet weak var socialImage: UIImageView!
    @IBOutlet weak var socialLink: UILabel!
    @IBOutlet weak var separatorLineHeightConstraint: NSLayoutConstraint!

    var social: Social? {
        didSet {
            socialLink.text = social?.link

            if let type = social?.icon {
                switch type {
                case "twitter":
                    socialImage.image = #imageLiteral(resourceName: "twitter-icon")
                case "linkedin":
                    socialImage.image = #imageLiteral(resourceName: "linkedin-icon")
                default:
                    socialImage.image = #imageLiteral(resourceName: "browser-icon")
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        separatorLineHeightConstraint?.constant = 0.5

        socialImage.layer.cornerRadius = socialImage.frame.size.width / 2
        socialImage.layer.masksToBounds = true
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // code common to all your cells goes here
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
