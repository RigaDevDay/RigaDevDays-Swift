//
//  FeedbackCell.swift
//  RigaDevDays
//
//  Created by Dmitry Beloborodov on 04/03/2017.
//  Copyright © 2017 RigaDevDays. All rights reserved.
//

import UIKit

class FeedbackCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!

    @IBOutlet weak var qcButton1: UIButton!
    @IBOutlet weak var qcButton2: UIButton!
    @IBOutlet weak var qcButton3: UIButton!
    @IBOutlet weak var qcButton4: UIButton!
    @IBOutlet weak var qcButton5: UIButton!

    @IBOutlet weak var spButton1: UIButton!
    @IBOutlet weak var spButton2: UIButton!
    @IBOutlet weak var spButton3: UIButton!
    @IBOutlet weak var spButton4: UIButton!
    @IBOutlet weak var spButton5: UIButton!
    
    var feedback: Feedback? {
        didSet {
            commentLabel.text = feedback?.comment

            for button in [qcButton1, qcButton2, qcButton3, qcButton4, qcButton5] {
                if (button?.tag)! <= (feedback?.qualityOfContent)! {
//                    button?.setTitle("★", for: .normal)
                    button?.setImage(#imageLiteral(resourceName: "bigstar_full"), for: .normal)
                } else {
//                    button?.setTitle("☆", for: .normal)
                    button?.setImage(#imageLiteral(resourceName: "bigstar"), for: .normal)
                }
            }

            for button in [spButton1, spButton2, spButton3, spButton4, spButton5] {
                if (button?.tag)! <= (feedback?.speakerPerformance)! {
//                    button?.setTitle("★", for: .normal)
                    button?.setImage(#imageLiteral(resourceName: "bigstar_full"), for: .normal)
                } else {
//                    button?.setTitle("☆", for: .normal)
                    button?.setImage(#imageLiteral(resourceName: "bigstar"), for: .normal)
                }
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // code common to all your cells goes here
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
