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

#pragma mark- Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    CGAffineTransform transform = CGAffineTransformIdentity;
    self.transform = transform;
    self.imageView.hidden = YES;
    self.imageView.image = nil;
}

#pragma mark - Configuration

- (void)configureWithPairItem:(FPPairItem *)pairItem {
    [self.imageView sd_setImageWithURL:pairItem.pairItemPreviewUrl];
}

- (void)markAsMatched {
    @weakify(self);
    [UIView animateWithDuration:.3 animations:^{
        @strongify(self);
        self.alpha = 0.f;
    }];
}

#pragma markk - Overrides

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    @weakify(self);
    [UIView transitionWithView:self.imageView
                      duration:.3
                       options:selected ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        @strongify(self);
                        self.imageView.hidden = !selected;
                    } completion:^(BOOL finished) {
                        
                    }];
}

@end
