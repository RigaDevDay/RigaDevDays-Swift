//  Copyright © 2017 RigaDevDays. All rights reserved.

import Foundation
import GoogleSignIn
import Firebase

class PartnersViewController: UIViewController  {

    @IBOutlet weak var partnersCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: .PartnerUpdated, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationButtons), name: .UserDidSignIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationButtons), name: .UserDidSignOut, object: nil)

        updateNavigationButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateNavigationButtons()
    }

    @objc
    func dataChanged() {
        partnersCollectionView.reloadData()
    }

    @objc
    func updateNavigationButtons() {
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil

        guard DataManager.sharedInstance.remoteConfig["enable_lottery"].boolValue else { return }

        guard let userID = Auth.auth().currentUser?.uid else {
            let participantButton = UIBarButtonItem(title: "Lottery",
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(signIn))
            navigationItem.leftBarButtonItem = participantButton
            return
        }
        if DataManager.sharedInstance.lotteryPartners.filter({ $0.identifier == userID }).count > 0 {
            let partnerButton = UIBarButtonItem(title: "Lottery",
                                                style: .plain,
                                                target: self,
                                                action: #selector(showLotteryForPartner))
            navigationItem.rightBarButtonItem = partnerButton

        } else {
            let participantButton = UIBarButtonItem(title: "Lottery",
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(showLoteryForParticipant))
            navigationItem.leftBarButtonItem = participantButton
        }

    }

    @objc
    func showLoteryForParticipant() {
        performSegue(withIdentifier: "showLotteryForParticipant", sender: self)
    }

    @objc
    func showLotteryForPartner() {
        performSegue(withIdentifier: "showLotteryForPartner", sender: self)
    }

    @objc
    func signIn() {
        GIDSignIn.sharedInstance().signIn()
    }
}

extension PartnersViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return DataManager.sharedInstance.partnerGroups.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManager.sharedInstance.partnerGroups[section].partners.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PartnerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PartnerCell", for: indexPath) as! PartnerCell
        cell.partner = DataManager.sharedInstance.partnerGroups[indexPath.section].partners[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionElementKindSectionHeader {
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "PartnerHeaderView", for: indexPath) as!  PartnerHeaderView
            let partnerGroup = DataManager.sharedInstance.partnerGroups[indexPath.section]
            cell.sectionTitle.text = partnerGroup.title?.replacingOccurrences(of: "-", with: " ").localizedCapitalized
            return cell
        } else {
            return UICollectionReusableView()
        }
    }
}

extension PartnersViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let partnerURL = URL.init(string: DataManager.sharedInstance.partnerGroups[indexPath.section].partners[indexPath.row].url!) {
            UIApplication.shared.openURL(partnerURL)
        }
    }
}

extension PartnersViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellHeight = 100.0
        cellHeight = Double(collectionView.frame.size.width - 30.0) / 2.0
        return CGSize(width: cellHeight, height: cellHeight / 5 * 2 )
    }
}

class PartnerHeaderView: UICollectionReusableView {
    @IBOutlet weak var sectionTitle: UILabel!
}
