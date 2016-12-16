//
//  FPGameViewControllerDataSource.m
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import "FPGameViewControllerDataSource.h"
#import "FPPlacesService.h"
#import "FPPairItemCVCell.h"
#import "FPPairItem.h"

static NSInteger const kItemsInColumnCount = 4;
static NSInteger const kMinItemsCount = 8;
static NSInteger const kGoogleDefaultSearchRadius = 1000;
static NSTimeInterval const kSelectionDuration = 1.0;

@interface FPGameViewControllerDataSource () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) FPGameViewControllerDataSourceEmptyCallback fetchCompletionCallback;
@property (nonatomic, copy) FPGameViewControllerDataSourceEmptyCallback pairSelectCallback;
@property (nonatomic, copy) FPGameViewControllerDataSourceEmptyCallback pairMatchCallback;
@property (nonatomic, copy) FPGameViewControllerDataSourceEmptyCallback gameOverCallback;
@property (nonatomic, strong) NSArray <FPPairItem *> *pairItems;
@end

@implementation FPGameViewControllerDataSource
#pragma mark - Initialization

+ (FPGameViewControllerDataSource *)dataSourceWithCollectionView:(UICollectionView *)collectionView
                                         fetchCompletionCallback:(FPGameViewControllerDataSourceEmptyCallback)fetchCompletionCallback
                                              pairSelectCallback:(FPGameViewControllerDataSourceEmptyCallback)pairSelectCallback
                                               pairMatchCallback:(FPGameViewControllerDataSourceEmptyCallback)pairMatchCallback
                                                gameOverCallback:(FPGameViewControllerDataSourceEmptyCallback)gameOverCallback {
    return [[self alloc] initWithCollectionView:collectionView
                        fetchCompletionCallback:fetchCompletionCallback
                             pairSelectCallback:pairSelectCallback
                              pairMatchCallback:pairMatchCallback
                               gameOverCallback:gameOverCallback];
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
               fetchCompletionCallback:(FPGameViewControllerDataSourceEmptyCallback)fetchCompletionCallback
                    pairSelectCallback:(FPGameViewControllerDataSourceEmptyCallback)pairSelectCallback
                     pairMatchCallback:(FPGameViewControllerDataSourceEmptyCallback)pairMatchCallback
                      gameOverCallback:(FPGameViewControllerDataSourceEmptyCallback)gameOverCallback {
    self = [super init];
    if (self) {
        self.collectionView = collectionView;
        self.pairSelectCallback = pairSelectCallback;
        self.pairMatchCallback = pairMatchCallback;
        self.gameOverCallback = gameOverCallback;
        self.fetchCompletionCallback = fetchCompletionCallback;
        [self configureCollectionView];
        [self fetchDataWithRadius:kGoogleDefaultSearchRadius];
    }
    return self;
}

#pragma mark - Configuration

- (void)configureCollectionView {
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FPPairItemCVCell class]) bundle:nil]
          forCellWithReuseIdentifier:NSStringFromClass([FPPairItemCVCell class])];
    [self.collectionView reloadData];
}

- (void)configureWithPrefilledData {
    
}

#pragma mark - Fetch

- (void)fetchDataWithRadius:(NSInteger)radius {
    @weakify(self);
    [FPPlacesService fetchPlacesNearLatitude:40.836181
                                   longitude:-73.913896
                                      radius:radius
                                  completion:^(NSArray<FPPairItem *> *pairItems, NSError *error) {
                                      @strongify(self);
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          if (!error) {
                                              if (pairItems.count < kMinItemsCount) {
                                                  [self fetchDataWithRadius:radius * 2];
                                              } else {
                                                  self.pairItems = pairItems;
                                                  [self.collectionView reloadData];
                                              }
                                          } else {
                                              [self configureWithPrefilledData];
                                          }
                                      });
                                  }];
}

#pragma mark - Setters

- (void)setPairItems:(NSArray<FPPairItem *> *)pairItems {
    //randomize items arrangement
    NSMutableArray *randomOrderedArray = [pairItems mutableCopy];
    for (int i = ((int)pairItems.count - 1); i > 0; i--) {
        [randomOrderedArray exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform(i + 1)];
    }
    _pairItems = randomOrderedArray;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pairItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FPPairItemCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FPPairItemCVCell class])
                                                                       forIndexPath:indexPath];
    [cell configureWithPairItem:self.pairItems[indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray <NSIndexPath *> *selectedIndexPaths = [collectionView indexPathsForSelectedItems];
    if (selectedIndexPaths.count == 2) {
        collectionView.userInteractionEnabled = NO;
        if (self.itemSelectCallback) {
            self.itemSelectCallback();
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSelectionDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BOOL matchFount = [self.pairItems[selectedIndexPaths.firstObject.row] isEqual:self.pairItems[selectedIndexPaths.lastObject.row]];
            for (NSIndexPath *indexPath in selectedIndexPaths) {
                [collectionView deselectItemAtIndexPath:indexPath animated:YES];
                if (matchFount) {
                    FPPairItemCVCell *cell = (FPPairItemCVCell *)[collectionView cellForItemAtIndexPath:indexPath];
                    [cell markAsMatched];
                }
            }
            collectionView.userInteractionEnabled = YES;
        });
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat padding = 8.f;
    CGFloat width = CGRectGetWidth(collectionView.frame) / kItemsInColumnCount - padding;
    CGFloat height = width;
    return CGSizeMake(width, height);
}

#pragma mark - Public

- (void)restart {
    self.pairItems = self.pairItems; //force call setter to rearrange fetched items
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
    } completion:nil];
}

@end
