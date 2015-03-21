//
//  LocationTableViewCell.swift
//  WeatherForecast
//
//  Created by David Jongepier on 18.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class LocationTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var currentLocationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
}
