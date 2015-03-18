//
//  SettingsTableViewController.swift
//  WeatherForecast
//
//  Created by David Jongepier on 09.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var pickerViewIndexPath: NSIndexPath?
    
    private struct Constants {
        static let SectionHeaderHeight: CGFloat  = 50.0
        static let SettingsCellHeight: CGFloat   = 48.0
        static let PickerViewCellHeight: CGFloat = 163.0
        
        static let SettingsCellReuseIdentifier   = "SettingsCell"
        static let PickerViewCellReuseIdentifier = "PickerViewCell"
        
        static let TableViewRowIndexLength       = 0
        static let TableViewRowIndexTemperature  = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Settings", comment: "Settings")
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.SectionHeaderHeight
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let generalSectionView = GroupedTableSectionView()
        generalSectionView.text = NSLocalizedString("General", comment: "General")
        return generalSectionView
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pickerViewIndexPath != nil {
            return 3
        }
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.isEqual(pickerViewIndexPath) {
            return Constants.PickerViewCellHeight
        }
        return Constants.SettingsCellHeight
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.isEqual(pickerViewIndexPath) {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.PickerViewCellReuseIdentifier) as PickerViewTableViewCell
            
            cell.selectionStyle = .None
            cell.pickerView.dataSource = self
            cell.pickerView.delegate = self
            
            var modifiedIndexPathRow = indexPath.row - 1
            cell.pickerView.tag = modifiedIndexPathRow
            
            var unitIndex = 0
            
            switch modifiedIndexPathRow {
            case 0:
                switch DataManager.sharedManager.preferredLengthUnit() {
                case .Kilometers:
                    unitIndex = 0
                    
                case .Miles:
                    unitIndex = 1
                    
                default:
                    break
                }
            case 1:
                switch DataManager.sharedManager.preferredTemperatureUnit() {
                case .Celsius:
                    unitIndex = 0
                    
                case .Fahrenheit:
                    unitIndex = 1
                    
                default:
                    break
                }
                
            default:
                break
            }
            
            cell.pickerView.selectRow(unitIndex, inComponent: 0, animated: false)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SettingsCellReuseIdentifier) as SettingsTableViewCell
        
        var modifiedIndexPathRow = indexPath.row
        if let pickerViewIndexPath = pickerViewIndexPath {
            modifiedIndexPathRow = indexPath.row < pickerViewIndexPath.row ? indexPath.row : indexPath.row - 1
        }
        
        switch modifiedIndexPathRow {
        case Constants.TableViewRowIndexLength:
            cell.itemLabel.text = NSLocalizedString("Unit of length", comment: "Unit of length")
            
            switch DataManager.sharedManager.preferredLengthUnit() {
            case .Kilometers:
                cell.unitLabel.text = NSLocalizedString("Kilometers", comment: "Kilometers")
                
            case .Miles:
                cell.unitLabel.text = NSLocalizedString("Miles", comment: "Miles")
            }
            
        case Constants.TableViewRowIndexTemperature:
            cell.itemLabel.text = NSLocalizedString("Unit of temperature", comment: "Unit of temperature")
            
            switch DataManager.sharedManager.preferredTemperatureUnit() {
            case .Celsius:
                cell.unitLabel.text = NSLocalizedString("Celsius", comment: "Celsius")
                
            case .Fahrenheit:
                cell.unitLabel.text = NSLocalizedString("Fahrenheit", comment: "Fahrenheit")
            }
            
        default:
            break
        }
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.isEqual(pickerViewIndexPath) {
            return
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let possiblePickerViewIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
        
        if let pickerViewIndexPath = pickerViewIndexPath {
            if pickerViewIndexPath.isEqual(possiblePickerViewIndexPath) {
                endValuePickingForRowAtIndexPath(indexPath)
                return
            }
        }
        
        beginValuePickingForRowAtIndexPath(indexPath)
    }
    
    
    // MARK: UIPickerView supporting methods
    
    func beginValuePickingForRowAtIndexPath(indexPath: NSIndexPath) {
        let pickerRow = indexPath.row + 1
        var newPickerViewIndexPath = NSIndexPath(forRow: pickerRow, inSection: indexPath.section)
        
        tableView.beginUpdates()
        
        if let pickerViewIndexPath = pickerViewIndexPath {
            tableView.deleteRowsAtIndexPaths([pickerViewIndexPath], withRowAnimation: .Fade)
            
            if pickerViewIndexPath.row < indexPath.row {
                newPickerViewIndexPath = NSIndexPath(forRow: newPickerViewIndexPath.row-1, inSection: newPickerViewIndexPath.section)
            }
        }
        
        pickerViewIndexPath = newPickerViewIndexPath
        
        tableView.insertRowsAtIndexPaths([newPickerViewIndexPath], withRowAnimation: .Fade)
        tableView.endUpdates()
        
        tableView.scrollToRowAtIndexPath(newPickerViewIndexPath, atScrollPosition: .None, animated: true)
    }
    
    func endValuePickingForRowAtIndexPath(indexPath: NSIndexPath) {
        let pickerRow = indexPath.row + 1
        let oldPickerViewIndexPath = NSIndexPath(forRow: pickerRow, inSection: indexPath.section)
        
        pickerViewIndexPath = nil
        
        tableView.deleteRowsAtIndexPaths([oldPickerViewIndexPath], withRowAnimation: .Fade)
    }
    
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case Constants.TableViewRowIndexLength:
            return 2
            
        case Constants.TableViewRowIndexTemperature:
            return 2
            
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        switch pickerView.tag {
        case Constants.TableViewRowIndexLength:
            switch row {
            case 0:
                return NSLocalizedString("Kilometers", comment: "Kilometers")
                
            case 1:
                return NSLocalizedString("Miles", comment: "Miles")
                
            default:
                return nil
            }
            
        case Constants.TableViewRowIndexTemperature:
            switch row {
            case 0:
                return NSLocalizedString("Celsius", comment: "Celsius")
                
            case 1:
                return NSLocalizedString("Fahrenheit", comment: "Fahrenheit")
                
            default:
                return nil
            }
            
        default:
            return nil
        }
    }
    
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cellIndexPath = NSIndexPath(forRow: pickerViewIndexPath!.row-1, inSection: pickerViewIndexPath!.section)
        
        switch pickerView.tag {
        case Constants.TableViewRowIndexLength:
            switch row {
            case 0:
                DataManager.sharedManager.setPreferredLengthUnit(.Kilometers)
                
            case 1:
                DataManager.sharedManager.setPreferredLengthUnit(.Miles)
                
            default:
                break
            }
            
        case Constants.TableViewRowIndexTemperature:
            switch row {
            case 0:
                DataManager.sharedManager.setPreferredTemperatureUnit(.Celsius)
                
            case 1:
                DataManager.sharedManager.setPreferredTemperatureUnit(.Fahrenheit)
                
            default:
                break
            }
            
        default:
            return
        }
        
        tableView.reloadRowsAtIndexPaths([cellIndexPath], withRowAnimation: .None)
    }

}
