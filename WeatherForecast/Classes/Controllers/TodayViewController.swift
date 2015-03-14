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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Today", comment: "Today")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationChanged:", name: DataManager.Notifications.NewLocationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataUpdated:", name: DataManager.Notifications.DataUpdatedNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func locationChanged(notification: NSNotification) {
        let locality = notification.userInfo?["locality"] as? String
        let country = notification.userInfo?["country"] as? String
        
        if locality != nil && country != nil {
            locationLabel.text = "\(locality!), \(country!)"
        } else {
            locationLabel.text = "– –"
        }
    }
    
    func dataUpdated(notification: NSNotification) {
        if let userInfo = notification.userInfo as? [String : String] {
            let temperatureCelsius = userInfo["temperatureCelsius"]
            let pressure = userInfo["pressure"]
            let windSpeedKph = userInfo["windSpeedKph"]
            let windDirection = userInfo["windDirection"]
            let rainPrecipitation = userInfo["rainPrecipitation"]
            let chanceOfRain = userInfo["chanceOfRain"]
            let weatherDescription = userInfo["weatherDescription"]
            let weatherIconURL = userInfo["weatherIconURL"]
            
            if temperatureCelsius != nil && weatherDescription != nil {
                weatherLabel.text = "\(temperatureCelsius!) | \(weatherDescription!)"
            } else {
                weatherLabel.text = "– –"
            }
            
            pressureLabel.text = pressure
            windSpeedLabel.text = windSpeedKph
            windDirectionLabel.text = windDirection
            rainQuantityLabel.text = rainPrecipitation
            chanceOfRainLabel.text = chanceOfRain
            
            if let weatherIconURL = weatherIconURL {
                weatherImageView.setImageWithURL(NSURL(string: weatherIconURL))
            } else {
                weatherImageView.image = nil
            }
        }
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        let shareTitle = "It is beautiful in Prague!"
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
