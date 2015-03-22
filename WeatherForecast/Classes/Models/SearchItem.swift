//
//  SearchItem.swift
//  WeatherForecast
//
//  Created by David Jongepier on 18.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import Foundation

class SearchItem {
    
    var cityName: String?
    var countryName: String?
    var latitude: Double?
    var longitude: Double?
    
    convenience init(cityName: String?, countryName: String?, latitude: Double, longitude: Double) {
        self.init()
        self.cityName = cityName
        self.countryName = countryName
        self.latitude = latitude
        self.longitude = longitude
    }
    
}
