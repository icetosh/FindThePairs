//
//  UIColor+FPColors.h
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (FPColors)
+ (UIColor *)fp_pairMatchColor;
+ (UIColor *)fp_pairMatchFailedColor;
+ (UIColor *)fp_gameOverColor;

+ (UIColor *)randomColor;
@end
