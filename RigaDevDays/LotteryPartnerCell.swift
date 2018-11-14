//  Copyright © 2018 RigaDevDays. All rights reserved.

import UIKit

class LotteryPartnerCell: UICollectionViewCell {
    
    @IBOutlet weak var partnerImageView: UIImageView!
    @IBOutlet weak var checkmark: UILabel!

    var partner: Partner? {
        didSet {
            if let photoURL = partner?.logoUrl, photoURL.contains("http"), let imageURL = URL(string: photoURL) {
                partnerImageView?.kf.indicatorType = .activity
                partnerImageView?.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
            } else if let url = URL(string: Config.sharedInstance.baseURLPrefix + (partner?.logoUrl?.replacingOccurrences(of: "../", with: "/"))!) {
                partnerImageView?.kf.indicatorType = .activity
                partnerImageView?.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }

            guard let partnerID = partner?.identifier else { return }

            if DataManager.sharedInstance.isCheckedAtPartner(withID: partnerID) {
                partnerImageView?.alpha = 1
                checkmark.isHidden = false
            } else {
                partnerImageView?.alpha = 0.3
                checkmark.isHidden = true
            }
        }
    }
}

extension UIImage {

    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}
