//
//  Location.swift
//  WeatherForecast
//
//  Created by David Jongepier on 17.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {

    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var currentLocation: NSNumber?
    @NSManaged var humidity: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var pressure: NSNumber?
    @NSManaged var rainPrecipitation: NSNumber?
    @NSManaged var temperatureCelsius: NSNumber?
    @NSManaged var temperatureFahrenheit: NSNumber?
    @NSManaged var weatherDescription: String?
    @NSManaged var weatherIconURL: String?
    @NSManaged var windDirection: String?
    @NSManaged var windSpeedKph: NSNumber?
    @NSManaged var windSpeedMph: NSNumber?
    @NSManaged var forecast: NSSet

}
