//
//  WeatherCell.swift
//  Weather
//
//  Created by Hanyuan Li on 14/1/18.
//  Copyright © 2018 Qwerp-Derp. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
