//
//  ArticleCell.swift
//  DailyNews
//
//  Created by Harry Netzer on 9/13/19.
//  Copyright © 2019 Big Hike. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {
    @IBOutlet var headline: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
