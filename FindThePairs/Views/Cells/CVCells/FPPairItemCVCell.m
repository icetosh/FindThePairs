//
//  FPPairItemCVCell.m
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import "FPPairItemCVCell.h"
#import "FPPairItem.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FPPairItemCVCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation FPPairItemCVCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}

#pragma mark - Configuration
- (void)configureWithPairItem:(FPPairItem *)pairItem {
    [self.imageView sd_setImageWithURL:pairItem.pairItemPreviewUrl];
}
@end
