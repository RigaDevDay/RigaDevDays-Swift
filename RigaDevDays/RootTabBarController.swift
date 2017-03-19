//
//  RootTabBarController.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 09/02/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn

class RootTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self

        let defaults = UserDefaults.standard
        if defaults.bool(forKey: UserDefaultsKeys.loggedInOnce.rawValue) {
            GIDSignIn.sharedInstance().signIn()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(shareItems), name: .ShareItem, object: nil)
    }

    func shareItems(notification: Notification) {
        if let userInfo = notification.userInfo {
            let itemsToShare = userInfo["dataToShare"] as! [Any]
            let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}

extension RootTabBarController: GIDSignInUIDelegate {
    // do nothing here
}
