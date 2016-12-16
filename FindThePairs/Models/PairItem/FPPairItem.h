//
//  FPPairItem.h
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FPPairItem : NSObject
@property (nonatomic, readonly) NSString *pairItemId;
@property (nonatomic, readonly) NSURL *pairItemPreviewUrl;
@property (nonatomic, readonly) UIColor *itemColor;

+ (FPPairItem *)pairItemWithId:(NSString *)pairItemId
            pairItemPreviewUrl:(NSURL *)pairItemPreviewUrl
                     itemColor:(UIColor *)itemColor;
@end
