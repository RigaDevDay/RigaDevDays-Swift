//
//  VenueCell.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 05/03/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import UIKit
import Kingfisher
import QuartzCore

class VenueCell: UITableViewCell {

    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var venueTitle: UILabel!
    @IBOutlet weak var venueAddress: UILabel!
    @IBOutlet weak var separatorLineHeightConstraint: NSLayoutConstraint!

    var venue: Venue? {
        didSet {
            venueName?.text = venue?.name
            venueTitle?.text = venue?.title
            venueAddress?.text = venue?.address
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

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
