//
//  ForecastTableViewController.swift
//  WeatherForecast
//
//  Created by David Jongepier on 09.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import CoreData

class ForecastTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    private struct Constants {
        static let CellHeight: CGFloat = 91.0
        static let ReuseIdentifier     = "ForecastCell"
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController? = DataManager.sharedManager.createForecastFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Forecast", comment: "Forecast")
        
        tableView.rowHeight = Constants.CellHeight
        tableView.tableFooterView = UIView()
        
        fetchedResultsController?.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationChanged:", name: DataManager.Notifications.NewLocationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataUpdated:", name: DataManager.Notifications.DataUpdatedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "settingsChanged:", name: DataManager.Notifications.SettingsChangedNotification, object: nil)
    }
    
    func reloadFetchedResultsController() -> NSFetchedResultsController? {
        fetchedResultsController = DataManager.sharedManager.createForecastFetchedResultsController()
        tableView.reloadData()
        return fetchedResultsController
    }
    
    func locationChanged(notification: NSNotification) {
        reloadFetchedResultsController()
    }
    
    func dataUpdated(notification: NSNotification) {
        reloadFetchedResultsController()
    }
    
    func settingsChanged(notification: NSNotification) {
        reloadFetchedResultsController()
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.ReuseIdentifier) as ForecastTableViewCell
        cell.selectionStyle = .None
        
        let forecast = fetchedResultsController?.fetchedObjects?[indexPath.row] as Forecast
        
        let placeholderString = "– –"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        cell.dayLabel.text = forecast.date != nil ? dateFormatter.stringFromDate(forecast.date!) : placeholderString
        cell.conditionLabel.text = forecast.weatherDescription ?? placeholderString
        
        var temperature: String?
        
        switch DataManager.sharedManager.preferredTemperatureUnit {
        case .Celsius:
            temperature = forecast.temperatureCelsius != nil ? "\(forecast.temperatureCelsius!)°" : placeholderString
            
        case .Fahrenheit:
            temperature = forecast.temperatureFahrenheit != nil ? "\(forecast.temperatureFahrenheit!)°" : placeholderString
        }
        
        cell.temperatureLabel.text = temperature
        
        if let weatherIconURLString = forecast.weatherIconURL {
            cell.weatherImageView.setImageWithURL(NSURL(string: weatherIconURLString))
        } else {
            cell.weatherImageView.image = nil
        }
        
        return cell
    }
    
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?)
    {
        switch (type) {
        case .Insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
        case .Update:
            if let indexPath = indexPath {
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
        case .Move:
            if let indexPath = indexPath {
                if let newIndexPath = newIndexPath {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
                }
            }
        }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType)
    {
        switch(type) {
            
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex),
                withRowAnimation: UITableViewRowAnimation.Fade)
            
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex),
                withRowAnimation: UITableViewRowAnimation.Fade)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

}
