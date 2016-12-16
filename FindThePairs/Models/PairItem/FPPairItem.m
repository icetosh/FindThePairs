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
@end

@implementation FPPairItem
+ (FPPairItem *)pairItemWithId:(NSString *)pairItemId pairItemPreviewUrl:(NSURL *)pairItemPreviewUrl {
    return [[self alloc] initWithId:pairItemId pairItemPreviewUrl:pairItemPreviewUrl];
}

- (instancetype)initWithId:(NSString *)pairItemId pairItemPreviewUrl:(NSURL *)pairItemPreviewUrl {
    self = [super init];
    if (self) {
        self.pairItemId = pairItemId;
        self.pairItemPreviewUrl = pairItemPreviewUrl;
    }
    return self;
}

@end
