//
//  SearchCell.swift
//  FavouriteLocations
//
//  Created by Developer on 27/04/2019.
//  Copyright © 2019 Nsystems. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBOutlet weak var weatherInfoStack: UIStackView!
    @IBOutlet weak var windInfoStack: UIStackView!
    @IBOutlet weak var windDirection: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionText: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        weatherInfoStack.isHidden = false
        windInfoStack.isHidden = false
        icon.image = nil
        locationNameLabel.text = nil
    }
    
}
