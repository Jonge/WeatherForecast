//
//  DataManager.swift
//  WeatherForecast
//
//  Created by David Jongepier on 10.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class DataManager: AFHTTPSessionManager, CLLocationManagerDelegate {
    
    class var sharedManager: DataManager {
        struct Static {
            static let instance = DataManager(baseURL: NSURL(string: Constants.APIAddress))
        }
        return Static.instance
    }
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        
        // Three kilometers should be accurate enough for weather
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        // iOS 8+ authorization request
        if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
            locationManager.requestWhenInUseAuthorization()
        }
        
        return locationManager
    }()
    
    let apiParameters: [String : AnyObject] = [
        "key" : Constants.APIKey,
        "format" : "json",
        "tp" : 24,
        "num_of_days" : 7
    ]
    
    var currentDataTask: NSURLSessionDataTask?
    var currentLocation: CLLocation?
    var didLoadLocationFromCache: Bool = false
    
    
    struct Notifications {
        static let NewLocationNotification = "DataManagerNewLocationNotification"
        static let DataUpdatedNotification = "DataManagerDidUpdateDataNotification"
    }
    
    private struct Constants {
        static let APIAddress = "https://api2.worldweatheronline.com/free/v2"
        static let APIKey     = "68c5220fb72c6397e94a28b80960a"
        static let ModelName  = "DataModel"
    }
    
    func updateDataForCurrentLocation() -> NSURLSessionDataTask {
        var parameters = apiParameters
        parameters.updateValue("\(currentLocation!.coordinate.latitude),\(currentLocation!.coordinate.longitude)", forKey: "q")
        
        return super.GET("weather.ashx", parameters: parameters, success: { task, responseObject in
            if responseObject is [String: AnyObject] {
                let responseDictionary = responseObject as [String: AnyObject]
                self.retrieveCurrentWeatherFromResponseDictionary(responseDictionary)
            }
        }, failure: { error in
            NSLog("\(error)")
        })
    }
    
    func retrieveCurrentWeatherFromResponseDictionary(dictionary: [String: AnyObject]) {
        println(dictionary)
        
        let dataDictionary = dictionary["data"] as? [String: AnyObject]
        let currentConditionArray = dataDictionary?["current_condition"] as? [AnyObject]
        let currentCondition = currentConditionArray?.first as? [String: AnyObject]
        
        let temperatureCelsius = currentCondition?["temp_C"] as? String
        let pressure = currentCondition?["pressure"] as? String
        let windSpeedKph = currentCondition?["windspeedKmph"] as? String
        let windDirection = currentCondition?["winddir16Point"] as? String
        let rainPrecipitation = currentCondition?["precipMM"] as? String
        
        let weatherDescriptionArray = currentCondition?["weatherDesc"] as? [AnyObject]
        let weatherDescriptionDictionary = weatherDescriptionArray?.first as? [String: AnyObject]
        let weatherDescription = weatherDescriptionDictionary?["value"] as? String
        
        let weatherIconURLArray = currentCondition?["weatherIconUrl"] as? [AnyObject]
        let weatherIconURLDictionary = weatherIconURLArray?.first as? [String: AnyObject]
        let weatherIconURL = weatherIconURLDictionary?["value"] as? String
        
        let weatherArray = dataDictionary?["weather"] as? [AnyObject]
        let weather = weatherArray?.first as? [String: AnyObject]
        let weatherHourlyArray = weather?["hourly"] as? [AnyObject]
        let weatherForFirstHour = weatherHourlyArray?.first as? [String: AnyObject]
        let chanceOfRain = weatherForFirstHour?["chanceofrain"] as? String
        
        let placeholderString = "– –"
        
        var userInfo = [
            "temperatureCelsius" : "\(temperatureCelsius ?? placeholderString) °C",
            "pressure" : "\(pressure ?? placeholderString) hPa",
            "windSpeedKph" : "\(windSpeedKph ?? placeholderString) km/h",
            "windDirection" : "\(windDirection ?? placeholderString)",
            "rainPrecipitation" : "\(rainPrecipitation ?? placeholderString) mm",
            "chanceOfRain" : "\(chanceOfRain ?? placeholderString) %",
            "weatherDescription" : "\(weatherDescription ?? placeholderString)",
        ]
        
        // Add icon URL if available
        if let weatherIconURL = weatherIconURL {
            userInfo.updateValue(weatherIconURL, forKey: "weatherIconURL")
        }
        
        let newLocationNotification = NSNotification(name: Notifications.DataUpdatedNotification, object: self, userInfo: userInfo)
        NSNotificationCenter.defaultCenter().postNotification(newLocationNotification)
    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if !didLoadLocationFromCache {
            didLoadLocationFromCache = true
            return
        }
        
        currentLocation = manager.location
        
        // Cancel current task, we have a new request
        if currentDataTask != nil {
            currentDataTask?.cancel()
            currentDataTask = nil
        }
        
        updateDataForCurrentLocation()
        
        CLGeocoder().reverseGeocodeLocation(currentLocation) { placemarks, error in
            if error == nil && placemarks.count > 0 {
                let placemark = placemarks.first as CLPlacemark
                
                self.locationManager.stopUpdatingLocation()
                println(placemark.locality)
                println(placemark.country)
                
                let userInfo = [
                    "locality" : placemark.locality,
                    "country" : placemark.country
                ]
                
                let newLocationNotification = NSNotification(name: Notifications.NewLocationNotification, object: self, userInfo: userInfo)
                NSNotificationCenter.defaultCenter().postNotification(newLocationNotification)
            }
        }
    }
    
    
    // MARK: - Core Data stack
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        if let masterMOC = self.masterManagedObjectContext {
            var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            managedObjectContext.parentContext = masterMOC
            
            return managedObjectContext
        }
        
        return nil
    }()
    
    private lazy var masterManagedObjectContext: NSManagedObjectContext? = {
        if let coordinator = self.persistentStoreCoordinator {
            var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            return managedObjectContext
        }
        
        return nil
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(Constants.ModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(Constants.ModelName).sqlite")
        
        var error: NSError? = nil
        if coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            // Delete store and recreate it
            NSFileManager.defaultManager().removeItemAtURL(url, error: &error)
            if (coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil) {
                NSLog("Unresolved error \(error) \(error?.userInfo)")
                abort()
            }
        }
        
        return coordinator
    }()
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.last as NSURL
    }()
    
    func saveContext() {
        if let moc = self.managedObjectContext {
            if let masterMOC = self.masterManagedObjectContext {
                moc.performBlock() {
                    var error: NSError? = nil
                    if moc.hasChanges && !moc.save(&error) {
                        NSLog("Unresolved error \(error) \(error?.userInfo)")
                        abort()
                    }
                    
                    masterMOC.performBlock() {
                        if masterMOC.hasChanges && !masterMOC.save(&error) {
                            NSLog("Unresolved error \(error) \(error?.userInfo)")
                            abort()
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        saveContext()
    }
    
}
