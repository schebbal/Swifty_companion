//
//  lineTableViewCell.swift
//  Switfy Companion
//
//  Created by Said Chebbal on 18/03/2019.
//  Copyright © 2019 Said Chebbal. All rights reserved.
//

import UIKit

class lineTableViewCell: UITableViewCell {

    @IBOutlet weak var champ1: UILabel!
    @IBOutlet weak var champ2: UILabel!
    @IBOutlet weak var champ3: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
