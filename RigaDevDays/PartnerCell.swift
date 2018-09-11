//  Copyright © 2017 RigaDevDays. All rights reserved.

import UIKit
import Kingfisher

class PartnerCell: UICollectionViewCell {

    @IBOutlet weak var partnerImageView: UIImageView!

    var partner: Partner? {
        didSet {
            if let photoURL = partner?.logoUrl, photoURL.contains("http"), let imageURL = URL(string: photoURL) {
                partnerImageView?.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
            } else if let url = URL(string: Config.sharedInstance.baseURLPrefix + (partner?.logoUrl?.replacingOccurrences(of: "../", with: "/"))!) {
                partnerImageView?.kf.indicatorType = .activity
                partnerImageView?.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
        }
    }
}
