//  Copyright © 2018 RigaDevDays. All rights reserved.

import UIKit
import Firebase

class QRProfileCell: UICollectionViewCell {

    @IBOutlet weak var qrCode: UIImageView!

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let userEmail = Auth.auth().currentUser?.email else { return }

        qrCode.image = generateQRCode(from: "\(userID)\n\(userEmail)")
    }
}
