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
        searchBar.delegate = self
        return searchBar
    }()
    
    var searchItemArray = [SearchItem]()
    
    var currentSearchTask: NSURLSessionDataTask?
    
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
        currentSearchTask?.cancel()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchItemArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SearchCellReuseIdentifier) as SearchItemTableViewCell
        let location = searchItemArray[indexPath.row]
        
        let cityItemFont = UIFont(name: Appearance.SemiboldFontName, size: 16.0)!
        let countryItemFont = UIFont(name: Appearance.LightFontName, size: 16.0)!
        let darkColor = Appearance.DarkColor
        
        let cityItemFontDictionary = [
            NSFontAttributeName: cityItemFont,
            NSForegroundColorAttributeName: darkColor
        ]
        
        let countryItemFontDictionary = [
            NSFontAttributeName: countryItemFont,
            NSForegroundColorAttributeName: darkColor
        ]
        
        let attributedText = NSMutableAttributedString(string: location.cityName!, attributes: cityItemFontDictionary)
        attributedText.appendAttributedString(NSAttributedString(string: ", \(location.countryName!)", attributes: countryItemFontDictionary))
        
        cell.locationLabel.attributedText = attributedText
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = searchItemArray[indexPath.row]
        DataManager.sharedManager.addLocation(city: location.cityName!, country: location.countryName!, latitude: location.latitude!, longitude: location.longitude!)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchTask?.cancel()
        DataManager.sharedManager.findSuggestedLocationsForQuery(searchText) {
            self.searchItemArray = $0
            self.tableView.reloadData()
        }
    }

}
