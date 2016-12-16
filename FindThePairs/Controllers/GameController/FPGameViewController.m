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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    self.dataSource = [FPGameViewControllerDataSource dataSourceWithCollectionView:self.collectionView
                                                           fetchCompletionCallback:^{
                                                               
                                                           } itemSelectCallback:^{
                                                               @strongify(self);
                                                               self.attemptsCountLabel.text = [NSString stringWithFormat:@"%@", @(self.attemptsCountLabel.text.integerValue + 1)];
                                                           }];
}


@end
