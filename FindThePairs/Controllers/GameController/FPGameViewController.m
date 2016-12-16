//
//  FPGameViewController.m
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import "FPGameViewController.h"
#import "FPGameViewControllerDataSource.h"
#import "UIView+FPAdditions.h"
#import "UIColor+FPColors.h"

@interface FPGameViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *attemptsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *fadingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fadingLabelCenterY;
@property (nonatomic, strong) FPGameViewControllerDataSource *dataSource;
@end

@implementation FPGameViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    self.dataSource = [FPGameViewControllerDataSource dataSourceWithCollectionView:self.collectionView
                                                           fetchCompletionCallback:^{
                                                               @strongify(self);
                                                               [self handleDataFetchCompletion];
                                                           } pairSelectCallback:^{
                                                               @strongify(self);
                                                               [self handlePairSelection];
                                                           } pairMatchCallback:^{
                                                               @strongify(self);
                                                               [self handlePairMatch];
                                                           } pairNotMatchCallback:^{
                                                               @strongify(self);
                                                               [self handlePairNotMatch];
                                                           } gameOverCallback:^{
                                                               @strongify(self);
                                                               [self handleGameOver];
                                                           }];
}

#pragma mark - FPGameViewControllerDataSource callbacks

- (void)handleDataFetchCompletion {
    
}

- (void)handlePairSelection {
    self.attemptsCountLabel.text = [NSString stringWithFormat:@"%@", @(self.attemptsCountLabel.text.integerValue + 1)];
}

- (void)handlePairMatch {
    [self showFadingLabelWithText:NSLocalizedString(@"Great!", nil)
                        textColor:[UIColor fp_pairMatchColor]
                      shouldShake:NO
                    shouldFadeOut:YES];
}

- (void)handlePairNotMatch {
    [self showFadingLabelWithText:NSLocalizedString(@"Try again!", nil)
                        textColor:[UIColor fp_pairMatchFailedColor]
                      shouldShake:YES
                    shouldFadeOut:YES];
}

- (void)handleGameOver {
    @weakify(self);
    [self showFadingLabelWithText:NSLocalizedString(@"Great! To start new game, press Restart button", nil)
                        textColor:[UIColor fp_gameOverColor]
                      shouldShake:NO
                    shouldFadeOut:NO];
    self.fadingLabelCenterY.priority = 999.f;
    [UIView animateWithDuration:.5
                          delay:.0
         usingSpringWithDamping:24.f
          initialSpringVelocity:32.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         @strongify(self);
                         [self.view layoutIfNeeded];
                     } completion:nil];
}

- (void)showFadingLabelWithText:(NSString *)text
                      textColor:(UIColor *)textColor
                    shouldShake:(BOOL)shouldShake
                  shouldFadeOut:(BOOL)shouldFadeOut {
    self.fadingLabel.alpha = 1.f;
    self.fadingLabel.textColor = textColor;
    self.fadingLabel.text = text;
    
    if (shouldShake) {
        [self.fadingLabel shakeView];
    }

    if (!shouldFadeOut) {
        return;
    }
    @weakify(self);
    [UIView animateWithDuration:.3 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
        @strongify(self);
        self.fadingLabel.alpha = 0.f;
    } completion:nil];
    
}

#pragma mark - Functions

- (void)restoreFadingLabelDefaults {
    self.fadingLabelCenterY.priority = 500.f;
    [UIView animateWithDuration:.5
                          delay:.0
         usingSpringWithDamping:24.f
          initialSpringVelocity:12.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.fadingLabel.alpha = 0.f;
                         [self.view layoutIfNeeded];
                     } completion:nil];

}

#pragma mark - IBActions

- (IBAction)restartButtonAction:(UIButton *)sender {
    [self.dataSource restart];
    [self restoreFadingLabelDefaults];
}

@end
