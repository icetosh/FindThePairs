//
//  FPPairItem.h
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPPairItem : NSObject
@property (nonatomic, readonly) NSString *pairItemId;
@property (nonatomic, readonly) NSURL *pairItemPreviewUrl;

+ (FPPairItem *)pairItemWithId:(NSString *)pairItemId pairItemPreviewUrl:(NSURL *)pairItemPreviewUrl;
@end
