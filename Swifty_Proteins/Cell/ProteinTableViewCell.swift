//
//  ProteinTableViewCell.swift
//  Swifty_Proteins
//
//  Created by Ivan SELETSKYI on 10/26/18.
//  Copyright © 2018 Ivan SELETSKYI. All rights reserved.
//

import UIKit

class ProteinTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cellActivity: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        if selected == true {
//            self.cellActivity.startAnimating()
//        }
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//    }

}
