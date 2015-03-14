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
        static let fontName = "ProximaNova-Semibold"
        static let fontSize: CGFloat = 14.0
    }
    
    private lazy var sectionTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        textLabel.textColor = self.tintColor
        self.addSubview(textLabel)
        
        // Add constraints
        textLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let viewBindingsDictionary = ["textLabel" : textLabel]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(15)-[textLabel]-(15)-|", options: nil, metrics: nil, views: viewBindingsDictionary))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(25)-[textLabel]-(5)-|", options: nil, metrics: nil, views: viewBindingsDictionary))
        
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
        return CGSize(width: sectionTextLabel.frame.size.width + 30.0, height: sectionTextLabel.frame.size.height + 20)
    }

}
