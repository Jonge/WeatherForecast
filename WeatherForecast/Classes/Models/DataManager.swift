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
    
    enum LengthUnit: String {
        case Kilometers = "Kilometers"
        case Miles      = "Miles"
    }
    
    enum TemperatureUnit: String {
        case Celsius    = "Celsius"
        case Fahrenheit = "Fahrenheit"
    }
    
    private struct UserDefaultKeys {
        static let LengthUnitKey = "LengthUnitKey"
        static let TemperatureUnitKey = "TemperatureUnitKey"
    }
    
    
    func preferredLengthUnit() -> LengthUnit {
        let lengthUnit = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultKeys.LengthUnitKey)
        if let lengthUnit = lengthUnit {
            if let rawLengthUnit = LengthUnit(rawValue: lengthUnit) {
                return rawLengthUnit
            }
        }
        return LengthUnit.Kilometers
    }
    
    func setPreferredLengthUnit(lengthUnit: LengthUnit) {
        NSUserDefaults.standardUserDefaults().setObject(lengthUnit.rawValue, forKey: UserDefaultKeys.LengthUnitKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        postSettingsChangedNotification()
    }
    
    func preferredTemperatureUnit() -> TemperatureUnit {
        let temperatureUnit = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultKeys.TemperatureUnitKey)
        if let temperatureUnit = temperatureUnit {
            if let rawTemperatureUnit = TemperatureUnit(rawValue: temperatureUnit) {
                return rawTemperatureUnit
            }
        }
        return TemperatureUnit.Celsius
    }
    
    func setPreferredTemperatureUnit(temperatureUnit: TemperatureUnit) {
        NSUserDefaults.standardUserDefaults().setObject(temperatureUnit.rawValue, forKey: UserDefaultKeys.TemperatureUnitKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        postSettingsChangedNotification()
    }
    
    func postSettingsChangedNotification() {
        let settingsChangedNotification = NSNotification(name: Notifications.SettingsChangedNotification, object: self, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(settingsChangedNotification)
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
    
    let apiParameters: [String: AnyObject] = [
        "key":         Constants.APIKey,
        "format":      "json",
        "tp":          24,
        "num_of_days": 7
    ]
    
    var didLoadLocationFromCache: Bool = false
    var currentDataTask: NSURLSessionDataTask?
    
    var currentLocation: Location? {
        get {
            if let moc = managedObjectContext {
                var fetchRequest = NSFetchRequest()
                var entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: moc)
                
                fetchRequest.entity = entity
                fetchRequest.predicate = NSPredicate(format: "currentLocation = %@", true)
                
                var sortDescriptor = NSSortDescriptor(key: "city", ascending: true)
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                var error: NSError? = nil
                var matches = moc.executeFetchRequest(fetchRequest, error: &error)
                
                if error == nil {
                    if matches?.count == 1 {
                        return matches?.first as? Location
                    } else {
                        if let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext!) {
                            if let location = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext!) as? Location {
                                location.currentLocation = true
                                saveContext()
                                return location
                            }
                        }
                    }
                }
            }
            
            return nil
        }
    }
    
    var selectedLocation: Location? {
        didSet {
            let notification = NSNotification(name: Notifications.NewLocationNotification, object: self)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    
    
    struct Notifications {
        static let NewLocationNotification     = "DataManagerNewLocationNotification"
        static let DataUpdatedNotification     = "DataManagerDidUpdateDataNotification"
        static let SettingsChangedNotification = "DataManagerDidChangeSettingsNotification"
    }
    
    private struct Constants {
        static let APIAddress = "https://api2.worldweatheronline.com/free/v2"
        static let APIKey     = "68c5220fb72c6397e94a28b80960a"
        static let ModelName  = "DataModel"
    }
    
    
    func addLocation(city: String, latitude: Float, longitude: Float) {
        if let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext!) {
            if let location = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext!) as? Location {
                location.city = city
                location.country = "lol"
                location.latitude = latitude
                location.longitude = longitude
                saveContext()
                
                updateDataForLocation(location)
            }
        }
    }
    
    func deleteLocation(location: Location) {
        managedObjectContext?.deleteObject(location)
        saveContext()
    }
    
    func createLocationsFetchedResultsController() -> NSFetchedResultsController? {
        if let moc = managedObjectContext {
            var fetchRequest = NSFetchRequest()
            var entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: moc)
            fetchRequest.entity = entity
            
            var sortDescriptor = NSSortDescriptor(key: "city", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.fetchBatchSize = 20
            
            var error: NSError? = nil
            let cacheName = "Locations"
            
            NSFetchedResultsController.deleteCacheWithName(cacheName)
            
            var fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: cacheName)
            
            if !fetchedResultsController.performFetch(&error) {
                NSLog("Unresolved error \(error) \(error?.userInfo)")
                abort()
            }
            
            return fetchedResultsController
        }
        
        return nil
    }
    
    func createForecastFetchedResultsController() -> NSFetchedResultsController? {
        if let moc = managedObjectContext {
            var fetchRequest = NSFetchRequest()
            var entity = NSEntityDescription.entityForName("Forecast", inManagedObjectContext: moc)
            fetchRequest.entity = entity
            
            if let selectedLocation = selectedLocation {
                fetchRequest.predicate = NSPredicate(format: "location = %@", selectedLocation)
            } else {
                return nil
            }
            
            var sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.fetchBatchSize = 20
            
            var error: NSError? = nil
            let cacheName = "Forecast"
            
            NSFetchedResultsController.deleteCacheWithName(cacheName)
            
            var fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: cacheName)
            
            if !fetchedResultsController.performFetch(&error) {
                NSLog("Unresolved error \(error) \(error?.userInfo)")
                abort()
            }
            
            return fetchedResultsController
        }
        
        return nil
    }
    
    func updateDataForLocation(location: Location) -> NSURLSessionDataTask {
        var parameters = apiParameters
        parameters.updateValue("\(location.latitude ?? 0.0),\(location.longitude ?? 0.0)", forKey: "q")
        
        return super.GET("weather.ashx", parameters: parameters, success: { task, responseObject in
            if responseObject is [String: AnyObject] {
                let responseDictionary = responseObject as [String: AnyObject]
    
                let parser = ParseWeatherOperation(location: location, dictionary: responseDictionary, managedObjectContext: self.createManagedObjectContextForPrivateQueue()) { managedObjectID in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.saveContext()
                        if let managedObjectID = managedObjectID {
                            if let location = self.managedObjectContext?.objectWithID(managedObjectID) as? Location {
                                let notification = NSNotification(name: Notifications.DataUpdatedNotification, object: self)
                                NSNotificationCenter.defaultCenter().postNotification(notification)
                            }
                        }
                    }
                }
                parser.start()
            }
        }, failure: { task, error in
            NSLog("%@", error)
        })
    }
    
    func findSuggestedLocationsForQuery(query: String) -> NSURLSessionDataTask {
        var parameters = apiParameters
        parameters.updateValue(query, forKey: "q")
        
        return super.GET("search.ashx", parameters: parameters, success: { task, responseObject in
            if responseObject is [String: AnyObject] {
                let responseDictionary = responseObject as [String: AnyObject]
                
                // TODO: Parse
            }
        }, failure: { task, error in
            NSLog("%@", error)
        })
    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if !didLoadLocationFromCache {
            didLoadLocationFromCache = true
            return
        }
        
        // Cancel current task, we have a new request
        if currentDataTask != nil {
            currentDataTask?.cancel()
            currentDataTask = nil
        }
        
        CLGeocoder().reverseGeocodeLocation(manager.location) { placemarks, error in
            if error == nil && placemarks.count > 0 {
                let placemark = placemarks.first as CLPlacemark
                
                self.locationManager.stopUpdatingLocation()
                self.didLoadLocationFromCache = false
                println(placemark.locality)
                println(placemark.country)
                
                if let currentLocation = self.currentLocation {
                    currentLocation.city = placemark.locality
                    currentLocation.country = placemark.country
                    currentLocation.latitude = manager.location.coordinate.latitude
                    currentLocation.longitude = manager.location.coordinate.longitude
                    self.updateDataForLocation(currentLocation)
                }
                
                let newLocationNotification = NSNotification(name: Notifications.NewLocationNotification, object: self, userInfo: nil)
                NSNotificationCenter.defaultCenter().postNotification(newLocationNotification)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            manager.startUpdatingLocation()
            
        default:
            break
        }
    }
    
    
    // MARK: - Core Data stack
    
    func createManagedObjectContextForPrivateQueue() -> NSManagedObjectContext {
        let privateQueueManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateQueueManagedObjectContext.parentContext = managedObjectContext
        return privateQueueManagedObjectContext
    }
    
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
        
        var error: NSError?
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
        if let moc = managedObjectContext {
            if let masterMOC = masterManagedObjectContext {
                moc.performBlock() {
                    var error: NSError?
                    
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
