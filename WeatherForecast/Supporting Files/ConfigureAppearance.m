//
//  ConfigureAppearance.m
//  WeatherForecast
//
//  Created by David Jongepier on 20.03.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ConfigureAppearance.h"

@implementation ConfigureAppearance

+ (void)configureSearchBarWithTextColor:(UIColor *)color font:(UIFont *)font
{
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: font}];
}

@end
