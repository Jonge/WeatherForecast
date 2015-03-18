//
//  Forecast.swift
//  WeatherForecast
//
//  Created by David Jongepier on 17.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import Foundation
import CoreData

class Forecast: NSManagedObject {

    @NSManaged var date: NSDate?
    @NSManaged var temperatureCelsius: NSNumber?
    @NSManaged var temperatureFahrenheit: NSNumber?
    @NSManaged var weatherDescription: String?
    @NSManaged var weatherIconURL: String?
    @NSManaged var location: Location?

}
