//
//  PartnerCell.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 13/02/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import UIKit
import Kingfisher

class PartnerCell: UICollectionViewCell {

    @IBOutlet weak var partnerImageView: UIImageView!

    var partner: Partner? {
        didSet {

            // TODO: fix image source
            if let url = URL(string: DataManager.sharedInstance.customImageURLPrefix + (partner?.logoUrl?.replacingOccurrences(of: "../", with: "/"))!) {
                partnerImageView.kf.indicatorType = .activity
                partnerImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
        }
    }
}
