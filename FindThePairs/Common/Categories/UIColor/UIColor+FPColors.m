//
//  UIColor+FPColors.m
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import "UIColor+FPColors.h"

@implementation UIColor (FPColors)
+ (UIColor *)fp_pairMatchColor {
    return [[UIColor greenColor] colorWithAlphaComponent:.5f];
}

+ (UIColor *)fp_pairMatchFailedColor {
    return [[UIColor redColor] colorWithAlphaComponent:.5f];
}

+ (UIColor *)fp_gameOverColor {
    return [UIColor colorWithRed:0.f/255.f green:122.f/255.f blue:255.f/255.f alpha:1.f];
}

+ (UIColor *)randomColor {
    CGFloat hue = (arc4random() % 256 / 256.f);
    CGFloat saturation = (arc4random() % 128 / 256.f) + 0.5f;  //  0.5 to 1.0, away from white
    CGFloat brightness = (arc4random() % 128 / 256.f) + 0.5f;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.f];
}
@end
