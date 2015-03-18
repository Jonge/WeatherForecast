//
//  AddLocationTableViewController.swift
//  WeatherForecast
//
//  Created by David Jongepier on 15.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class AddLocationTableViewController: UITableViewController, UISearchBarDelegate {
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search")
        searchBar.searchBarStyle = .Minimal
        searchBar.delegate = self
        return searchBar
    }()
    
    // TODO: Fill from server API
    lazy var searchItemArray: [SearchItem] = {
        let newYork = SearchItem(locationName: "New York", latitude: 40.730599, longitude: -73.986581)
        let london = SearchItem(locationName: "London", latitude: 51.507322, longitude: -0.127647)
        let moscow = SearchItem(locationName: "Moscow", latitude: 55.751634, longitude: 37.618704)
        let tokyo = SearchItem(locationName: "Tokyo", latitude: 35.690041, longitude: 139.510395)
        let sydney = SearchItem(locationName: "Sydney", latitude: -33.854816, longitude: 151.216454)
        return [newYork, london, moscow, tokyo, sydney]
    }()
    
    private struct Constants {
        static let SearchCellHeight: CGFloat = 40.0
        static let SearchCellReuseIdentifier = "SearchCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
        
        tableView.rowHeight = Constants.SearchCellHeight
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func closeButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchItemArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SearchCellReuseIdentifier) as SearchItemTableViewCell
        
        let location = searchItemArray[indexPath.row]
        cell.locationLabel.text = location.locationName
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = searchItemArray[indexPath.row]
        DataManager.sharedManager.addLocation(location.locationName!, latitude: location.latitude!, longitude: location.longitude!)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: Send searchText to API and display results
    }

}
