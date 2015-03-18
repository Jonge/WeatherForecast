//
//  ParseWeatherOperation.swift
//  WeatherForecast
//
//  Created by David Jongepier on 15.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import CoreData

class ParseWeatherOperation: NSOperation {
    
    var responseDictionary: [String: AnyObject]?
    var managedObjectContext: NSManagedObjectContext?
    var currentLocation: Bool = false
    var completion: (NSManagedObjectID? -> ())?
    
    override init() {
        super.init()
    }
    
    convenience init(dictionary: [String: AnyObject],
        managedObjectContext: NSManagedObjectContext,
        currentLocation: Bool,
        completion: NSManagedObjectID? -> ())
    {
        self.init()
        self.responseDictionary = dictionary
        self.managedObjectContext = managedObjectContext
        self.currentLocation = currentLocation
        self.completion = completion
    }
    
    private struct JSONKeys {
        static let DataDictionary          = "data"
        
        static let CurrentConditionArray   = "current_condition"
        
        static let TemperatureCelsius      = "temp_C"
        static let TemperatureFahrenheit   = "temp_F"
        static let Pressure                = "pressure"
        static let WindSpeedKph            = "windspeedKmph"
        static let WindSpeedMph            = "windspeedMiles"
        static let WindDirection           = "winddir16Point"
        static let RainPrecipitation       = "precipMM"
        static let Humidity                = "humidity"
        static let WeatherDescriptionArray = "weatherDesc"
        static let WeatherDescription      = "value"
        static let WeatherIconURLArray     = "weatherIconUrl"
        static let WeatherIconURL          = "value"
        static let WeatherArray            = "weather"
        static let WeatherHourlyArray      = "hourly"
        static let ChanceOfRain            = "chanceofrain"
        
        static let Date                    = "date"
        static let ForecastTempCelsius     = "tempC"
        static let ForecastTempFahrenheit  = "tempF"
    }
    
    override func main() {
        assert(responseDictionary != nil, "Fatal error: Response dictionary must not be nil")
        assert(managedObjectContext != nil, "Fatal error: Managed object context must not be nil")
        
        var locationObject: Location?
        
        managedObjectContext!.performBlockAndWait {
            // TODO: Find current location object in database
            if let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext!) {
                locationObject = NSManagedObject(entity: entity, insertIntoManagedObjectContext: self.managedObjectContext!) as? Location
            }
            
            let dataDictionary        = self.responseDictionary![JSONKeys.DataDictionary] as? [String: AnyObject]
            
            // Current condition
            let currentConditionArray = dataDictionary?[JSONKeys.CurrentConditionArray]   as? [AnyObject]
            let currentCondition      = currentConditionArray?.first                      as? [String: AnyObject]
            
            locationObject?.temperatureCelsius    = currentCondition?[JSONKeys.TemperatureCelsius]    as? Int
            locationObject?.temperatureFahrenheit = currentCondition?[JSONKeys.TemperatureFahrenheit] as? Int
            locationObject?.pressure              = currentCondition?[JSONKeys.Pressure]              as? Int
            locationObject?.windSpeedKph          = currentCondition?[JSONKeys.WindSpeedKph]          as? Int
            locationObject?.windSpeedMph          = currentCondition?[JSONKeys.WindSpeedMph]          as? Int
            locationObject?.windDirection         = currentCondition?[JSONKeys.WindDirection]         as? String
            locationObject?.rainPrecipitation     = currentCondition?[JSONKeys.RainPrecipitation]     as? Double
            locationObject?.humidity              = currentCondition?[JSONKeys.Humidity]              as? Int
            
            let weatherDescriptionArray = currentCondition?[JSONKeys.WeatherDescriptionArray] as? [AnyObject]
            let weatherDescriptionDictionary = weatherDescriptionArray?.first as? [String: AnyObject]
            locationObject?.weatherDescription = weatherDescriptionDictionary?[JSONKeys.WeatherDescription] as? String
            
            let weatherIconURLArray = currentCondition?[JSONKeys.WeatherIconURLArray] as? [AnyObject]
            let weatherIconURLDictionary = weatherIconURLArray?.first as? [String: AnyObject]
            locationObject?.weatherIconURL = weatherIconURLDictionary?[JSONKeys.WeatherIconURL] as? String
            
            // Forecast
            let forecastArray = dataDictionary?[JSONKeys.WeatherArray] as? [AnyObject]
            
            if let forecastArray = forecastArray {
                for forecastDictionary in forecastArray {
                    if let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext!) {
                        let forecastObject = NSManagedObject(entity: entity, insertIntoManagedObjectContext: self.managedObjectContext!) as? Forecast
                        
                        // Assign forecast location
                        forecastObject?.location = locationObject
                        
                        // Date
                        if let dateString = forecastDictionary[JSONKeys.Date] as? String {
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            forecastObject?.date = dateFormatter.dateFromString(dateString)
                        }
                        
                        let weatherHourlyArray = forecastDictionary[JSONKeys.WeatherHourlyArray] as? [AnyObject]
                        let weatherForWholeDay = weatherHourlyArray?.first as? [String: AnyObject]
                        
                        // Temperatures
                        forecastObject?.temperatureCelsius = weatherForWholeDay?[JSONKeys.ForecastTempCelsius] as? NSNumber
                        forecastObject?.temperatureFahrenheit = weatherForWholeDay?[JSONKeys.ForecastTempFahrenheit] as? NSNumber
                        
                        // Weather description
                        let weatherDescriptionArray = weatherForWholeDay?[JSONKeys.WeatherDescriptionArray] as? [AnyObject]
                        let weatherDescriptionDictionary = weatherDescriptionArray?.first as? [String: AnyObject]
                        forecastObject?.weatherDescription = weatherDescriptionDictionary?[JSONKeys.WeatherDescription] as? String
                        
                        // Weather icon URL
                        let weatherIconURLArray = weatherForWholeDay?[JSONKeys.WeatherIconURLArray] as? [AnyObject]
                        let weatherIconURLDictionary = weatherIconURLArray?.first as? [String: AnyObject]
                        forecastObject?.weatherIconURL = weatherIconURLDictionary?[JSONKeys.WeatherIconURL] as? String
                    }
                }
            }
        }
        
        if !cancelled {
            if let completion = completion {
                let managedObjectID = locationObject?.objectID
                completion(managedObjectID)
            }
        }
    }
    
}
