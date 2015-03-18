//
//  SearchItem.swift
//  WeatherForecast
//
//  Created by David Jongepier on 18.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import Foundation

class SearchItem {
    
    var locationName: String?
    var latitude: Float?
    var longitude: Float?
    
    convenience init(locationName: String, latitude: Float, longitude: Float) {
        self.init()
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
    }
    
}
