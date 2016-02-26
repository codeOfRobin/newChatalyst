//
//  leftCell.swift
//  newChatalyst
//
//  Created by Robin Malhotra on 21/02/16.
//  Copyright © 2016 Robin Malhotra. All rights reserved.
//

import UIKit

class leftCell: UITableViewCell {


    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var messageImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
