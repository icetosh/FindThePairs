//
//  FPPairItemCVCell.h
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FPPairItem;
@interface FPPairItemCVCell : UICollectionViewCell
- (void)configureWithPairItem:(FPPairItem *)pairItem;
- (void)markAsMatched;
@end
