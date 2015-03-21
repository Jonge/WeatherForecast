//
//  TodayViewController.swift
//  WeatherForecast
//
//  Created by David Jongepier on 09.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import CoreLocation

class TodayViewController: UIViewController {
    
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var currentLocationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var chanceOfRainLabel: UILabel!
    @IBOutlet weak var rainQuantityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDirectionLabel: UILabel!
    
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Today", comment: "Today")
        
        shareButton.enabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationChanged:", name: DataManager.Notifications.NewLocationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataUpdated:", name: DataManager.Notifications.DataUpdatedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "settingsChanged:", name: DataManager.Notifications.SettingsChangedNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func locationChanged(notification: NSNotification) {
        redrawData()
    }
    
    func dataUpdated(notification: NSNotification) {
        redrawData()
    }
    
    func settingsChanged(notification: NSNotification) {
        redrawData()
    }
    
    func redrawData() {
        if let location = DataManager.sharedManager.selectedLocation {
            shareButton.enabled = true
            
            let placeholderString = "– –"
            
            if location.city != nil && location.country != nil {
                locationLabel.text = "\(location.city!), \(location.country!)"
            } else {
                locationLabel.text = placeholderString
            }
            
            var temperature: String?
            
            switch DataManager.sharedManager.preferredTemperatureUnit() {
            case .Celsius:
                temperature = location.temperatureCelsius != nil ? "\(location.temperatureCelsius!)°C" : placeholderString
                
            case .Fahrenheit:
                temperature = location.temperatureFahrenheit != nil ? "\(location.temperatureFahrenheit!)°F" : placeholderString
            }
            
            weatherLabel.text = "\(temperature!) | \(location.weatherDescription ?? placeholderString)"
            
            
            var windSpeed: String?
            
            switch DataManager.sharedManager.preferredLengthUnit() {
            case .Kilometers:
                windSpeed = location.windSpeedKph != nil ? "\(location.windSpeedKph!) km/h" : placeholderString
                
            case .Miles:
                windSpeed = location.windSpeedMph != nil ? "\(location.windSpeedMph!) mph" : placeholderString
            }
            
            windSpeedLabel.text = windSpeed
            
            pressureLabel.text = location.pressure != nil ? "\(location.pressure!) hPa" : placeholderString
            windDirectionLabel.text = location.windDirection
            rainQuantityLabel.text = location.rainPrecipitation != nil ? "\(location.rainPrecipitation!) mm" : placeholderString
            chanceOfRainLabel.text = location.humidity != nil ? "\(location.humidity!) %" : placeholderString
            
            if let weatherIconURL = location.weatherIconURL {
                weatherImageView.setImageWithURL(NSURL(string: weatherIconURL))
            } else {
                weatherImageView.image = nil
            }
            
            if location == DataManager.sharedManager.currentLocation {
                currentLocationImageView.image = UIImage(named: "CurrentLocation")
            } else {
                currentLocationImageView.image = nil
            }
        } else {
            shareButton.enabled = false
        }
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        if let location = DataManager.sharedManager.selectedLocation {
            if location.city != nil && location.weatherDescription != nil {
                let shareTitle = "\(location.city!), \(location.weatherDescription!)"
                let activityViewController = UIActivityViewController(activityItems: [shareTitle], applicationActivities: nil)
                
                activityViewController.excludedActivityTypes = [
                    UIActivityTypePrint,
                    UIActivityTypeAssignToContact,
                    UIActivityTypeSaveToCameraRoll,
                    UIActivityTypeAddToReadingList,
                    UIActivityTypePostToFlickr,
                    UIActivityTypePostToVimeo,
                    UIActivityTypePostToWeibo,
                    UIActivityTypePostToTencentWeibo
                ]
                
                presentViewController(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
}
