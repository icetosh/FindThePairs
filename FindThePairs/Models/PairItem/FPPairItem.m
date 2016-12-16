//
//  FPPairItem.m
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import "FPPairItem.h"

@interface FPPairItem ()
@property (nonatomic, readwrite) NSString *pairItemId;
@property (nonatomic, readwrite) NSURL *pairItemPreviewUrl;
@property (nonatomic, readwrite) UIColor *itemColor;
@end

@implementation FPPairItem
+ (FPPairItem *)pairItemWithId:(NSString *)pairItemId pairItemPreviewUrl:(NSURL *)pairItemPreviewUrl itemColor:(UIColor *)itemColor {
    return [[self alloc] initWithId:pairItemId pairItemPreviewUrl:pairItemPreviewUrl itemColor:itemColor];
}

- (instancetype)initWithId:(NSString *)pairItemId pairItemPreviewUrl:(NSURL *)pairItemPreviewUrl itemColor:(UIColor *)itemColor {
    self = [super init];
    if (self) {
        self.pairItemId = pairItemId;
        self.pairItemPreviewUrl = pairItemPreviewUrl;
        self.itemColor = itemColor;
    }
    return self;
}

@end
