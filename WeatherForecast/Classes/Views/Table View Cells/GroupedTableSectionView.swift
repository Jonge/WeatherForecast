//
//  GroupedTableSectionView.swift
//  WeatherForecast
//
//  Created by David Jongepier on 10.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class GroupedTableSectionView: UIView {
    
    var text: String? {
        willSet {
            sectionTextLabel.text = newValue?.uppercaseString
            invalidateIntrinsicContentSize()
        }
    }
    
    private struct Constants {
        static let TopMargin: CGFloat    = 25.0
        static let BottomMargin: CGFloat = 5.0
        static let LeftMargin: CGFloat   = 15.0
        static let RightMargin: CGFloat  = 15.0
    }
    
    private lazy var sectionTextLabel: UILabel = { [unowned self] in
        let textLabel = UILabel()
        textLabel.font = UIFont(name: Appearance.SemiboldFontName, size: 14.0)
        textLabel.textColor = Appearance.TintColor
        self.addSubview(textLabel)
        
        // Add constraints
        textLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let viewBindingsDictionary = ["textLabel": textLabel]
        let metricsDictionary = [
            "topMargin":    Constants.TopMargin,
            "bottomMargin": Constants.BottomMargin,
            "leftMargin":   Constants.LeftMargin,
            "rightMargin":  Constants.RightMargin,
        ]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(leftMargin)-[textLabel]-(rightMargin)-|", options: nil, metrics: metricsDictionary, views: viewBindingsDictionary))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(topMargin)-[textLabel]-(bottomMargin)-|", options: nil, metrics: metricsDictionary, views: viewBindingsDictionary))
        
        return textLabel
    }()
    
    
    // MARK: - Overrides
    
    override func tintColorDidChange() {
        sectionTextLabel.textColor = tintColor
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(
            width: sectionTextLabel.frame.size.width + Constants.LeftMargin + Constants.RightMargin,
            height: sectionTextLabel.frame.size.height + Constants.TopMargin + Constants.BottomMargin)
    }

}
