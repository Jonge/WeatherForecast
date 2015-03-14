//
//  ForecastTableViewController.swift
//  WeatherForecast
//
//  Created by David Jongepier on 09.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class ForecastTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Forecast", comment: "Forecast")
    }
    
    
    // MARK: - UITableViewDataSource
    
    private struct Constants {
        static let ReuseIdentifier = "ForecastCell"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.ReuseIdentifier) as ForecastTableViewCell
        
        cell.imageView?.image = UIImage(named: "Sun")
        cell.dayLabel.text = "Monday"
        cell.conditionLabel.text = "Sunny"
        
        return cell
    }

}
