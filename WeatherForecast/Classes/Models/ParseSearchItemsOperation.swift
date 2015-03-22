//
//  ParseSearchItemsOperation.swift
//  WeatherForecast
//
//  Created by David Jongepier on 22.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class ParseSearchItemsOperation: NSOperation {
    
    var responseDictionary: [String: AnyObject]?
    var completion: ([SearchItem] -> ())?
    
    override init() {
        super.init()
    }
    
    convenience init(dictionary: [String: AnyObject], completion: [SearchItem] -> ())
    {
        self.init()
        self.responseDictionary = dictionary
        self.completion = completion
    }
    
    private struct JSONKeys {
        static let SearchResultsDictionary = "search_api"
        static let ResultArray             = "result"
        
        static let CityName    = "areaName"
        static let CountryName = "country"
        static let Latitude    = "latitude"
        static let Longitude   = "longitude"
        static let Value       = "value"
    }
    
    override func main() {
        var searchItemsArray = [SearchItem]()
        
        let searchResultsDictionary = self.responseDictionary?[JSONKeys.SearchResultsDictionary] as? [String: AnyObject]
        if let resultArray          = searchResultsDictionary?[JSONKeys.ResultArray]             as? [AnyObject]
        {
            for object in resultArray {
                if let resultDictionary = object as? [String: AnyObject] {
                    let cityNameArray = resultDictionary[JSONKeys.CityName] as? [AnyObject]
                    let cityNameDictionary = cityNameArray?.first as? [String: AnyObject]
                    let cityName = cityNameDictionary?[JSONKeys.Value] as? String
                    
                    let countryNameArray = resultDictionary[JSONKeys.CountryName] as? [AnyObject]
                    let countryNameDictionary = countryNameArray?.first as? [String: AnyObject]
                    let countryName = countryNameDictionary?[JSONKeys.Value] as? String
                    
                    let latitude  = (resultDictionary[JSONKeys.Latitude]  as? NSString)?.doubleValue
                    let longitude = (resultDictionary[JSONKeys.Longitude] as? NSString)?.doubleValue
                    
                    let searchItem = SearchItem(cityName: cityName, countryName: countryName, latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)
                    searchItemsArray.append(searchItem)
                }
            }
        }
        
        if let completion = self.completion {
            completion(searchItemsArray)
        }
    }
}
