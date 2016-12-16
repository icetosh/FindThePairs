//
//  FPMappingService.h
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPMappingService : NSObject
/**
 Returns mapped collection of FPPairItems
 */
+ (NSArray *)mappedPairItemsFromRepresentation:(NSArray *)representation;
@end
