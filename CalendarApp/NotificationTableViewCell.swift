//
//  NotificationTableViewCell.swift
//  CalendarApp
//
//  Created by Arun on 14/05/22.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
