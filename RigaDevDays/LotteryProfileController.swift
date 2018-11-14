//  Copyright © 2018 RigaDevDays. All rights reserved.

import UIKit

class LotteryProfileController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .LotteryPartnersUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .LotteryParticipantsUpdated, object: nil)
    }

    @objc
    func dataChanged() {
        collectionView.reloadData()
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension LotteryProfileController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return DataManager.sharedInstance.lotteryPartners.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {
        case 0:
            let cell: QRProfileCell = collectionView.dequeueReusableCell(withReuseIdentifier: "QRProfileCell", for: indexPath) as! QRProfileCell
            return cell
        default:
            let cell: LotteryPartnerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LotteryPartnerCell", for: indexPath) as! LotteryPartnerCell
            cell.partner = DataManager.sharedInstance.lotteryPartners[indexPath.row]
            return cell
        }
    }
}

extension LotteryProfileController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            let cellWidth: CGFloat = min(collectionView.frame.size.width - 20.0, 200.0)
            return CGSize(width: cellWidth, height: cellWidth )
        default:
            let cellWidth: CGFloat = (collectionView.frame.size.width - 30.0) / 2.0
            return CGSize(width: cellWidth, height: cellWidth)
        }
    }
}
