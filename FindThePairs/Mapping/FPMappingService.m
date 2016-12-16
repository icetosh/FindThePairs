//
//  FPMappingService.m
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import "FPMappingService.h"
#import "FPPairItem.h"
#import "FPGoogleConstants.h"
#import "UIColor+FPColors.h"

static NSString *const kResultsSortKey = @"rating";
static NSString *const kPairItemResponseIdKey = @"place_id";
static NSString *const kPairItemResponsePhotosKey = @"photos";
static NSString *const kPairItemResponsePhotoReferenceKey = @"photo_reference";

NSString *const imageFormedUrl = @"";

@implementation FPMappingService
+ (NSArray *)mappedPairItemsFromRepresentation:(NSArray *)representation {
    
    representation = [representation sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:kResultsSortKey ascending:YES]]];
    
    NSMutableArray *mappedItems = [@[] mutableCopy];
    for (NSDictionary *dictionary in representation) {
        NSString *pairItemId = dictionary[kPairItemResponseIdKey];
        NSString *photoUrlString = nil;
        NSArray *photos = dictionary[kPairItemResponsePhotosKey];
        if (photos.count) {
            NSString *photoReference = photos.firstObject[kPairItemResponsePhotoReferenceKey];
            photoUrlString = [NSString stringWithFormat:kGoogleImageUrl, photoReference, kGoogleAPIKey];
        }
        if (!photoUrlString) { //skip items without photo
            continue;
        }
        FPPairItem *pairItem = [FPPairItem pairItemWithId:pairItemId pairItemPreviewUrl:[NSURL URLWithString:photoUrlString] itemColor:[UIColor randomColor]];
        [mappedItems addObject:pairItem];
        [mappedItems addObject:pairItem];
        if (mappedItems.count == 16) {
            break;
        }
    }
    
    return mappedItems;
}
@end
