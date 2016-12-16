//
//  FPPlacesService.h
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FPPairItem;
typedef void(^FPPlacesServiceCompletion)(NSArray <FPPairItem *> *pairItems, NSError *error);

@interface FPPlacesService : NSObject
/**
 Perform fetch SAPairItems, mapped from Google Places API response. Completion returns max 8 different items.
 */
+ (NSURLSessionDataTask *)fetchPlacesNearLatitude:(CGFloat)latitude
                                        longitude:(CGFloat)longitude
                                           radius:(NSInteger)radius
                                       completion:(FPPlacesServiceCompletion)completion;
+ (void)fetchFakeLocationPlacesWithCompletion:(FPPlacesServiceCompletion)completion;
@end
