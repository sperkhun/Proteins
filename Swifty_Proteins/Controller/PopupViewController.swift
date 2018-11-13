//
//  PopupViewController.swift
//  Swifty_Proteins
//
//  Created by Ivan SELETSKYI on 10/27/18.
//  Copyright © 2018 Ivan SELETSKYI. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {

    var data: [String] = ["-", "-"]
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLebel: UILabel!
    @IBOutlet weak var popupView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 15
            newValue.clipsToBounds = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        titleLabel.text = data[0]
        contentLebel.text = data[1]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tapGesture(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
