//
//  TableViewCell.swift
//  KeepUp
//
//  Created by Harry Netzer on 9/12/19.
//  Copyright © 2019 Big Hike. All rights reserved.
//

import UIKit

class SectionCell: UITableViewCell {
    @IBOutlet var displayName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
