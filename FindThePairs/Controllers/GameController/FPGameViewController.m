//
//  FPGameViewController.m
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import "FPGameViewController.h"
#import "FPGameViewControllerDataSource.h"

@interface FPGameViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *attemptsCountLabel;
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
                                                           } gameOverCallback:^{
                                                               @strongify(self);
                                                               [self handleGameOver];
                                                           }];
}

#pragma mark - FPGameViewControllerDataSource callbacks

- (void)handleDataFetchCompletion {
    
}

- (void)handlePairSelection {
    
}

- (void)handlePairMatch {
    
}

- (void)handleGameOver {
    
}

#pragma mark - IBActions

- (IBAction)restartButtonAction:(UIButton *)sender {
    [self.dataSource restart];
}

@end
