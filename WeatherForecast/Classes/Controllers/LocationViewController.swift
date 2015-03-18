//
//  LocationViewController.swift
//  WeatherForecast
//
//  Created by David Jongepier on 09.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import CoreData

class LocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private struct Constants {
        static let LocationCellHeight: CGFloat = 91.0
        static let LocationCellReuseIdentifier = "LocationCell"
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController? = DataManager.sharedManager.createLocationsFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Location", comment: "Location")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = Constants.LocationCellHeight
        tableView.tableFooterView = UIView()
        
        fetchedResultsController?.delegate = self
    }

    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.LocationCellReuseIdentifier) as LocationTableViewCell
        let location = fetchedResultsController?.fetchedObjects?[indexPath.row] as Location
        
        let placeholderString = "– –"
        
        cell.locationLabel.text = location.city ?? placeholderString
        cell.conditionLabel.text = location.weatherDescription ?? placeholderString
        
        var temperature: String?
        
        switch DataManager.sharedManager.preferredTemperatureUnit() {
        case .Celsius:
            temperature = location.temperatureCelsius != nil ? "\(location.temperatureCelsius!)°" : placeholderString
            
        case .Fahrenheit:
            temperature = location.temperatureFahrenheit != nil ? "\(location.temperatureFahrenheit!)°" : placeholderString
        }
        
        cell.temperatureLabel.text = temperature
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let location = fetchedResultsController?.fetchedObjects?[indexPath.row] as Location
            DataManager.sharedManager.deleteLocation(location)
        }
    }
    
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = fetchedResultsController?.fetchedObjects?[indexPath.row] as Location
        DataManager.sharedManager.currentLocation = location
        dismissViewControllerAnimated(true, completion: nil)
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
