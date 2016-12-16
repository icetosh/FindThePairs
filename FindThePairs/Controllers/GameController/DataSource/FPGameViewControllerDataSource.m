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
#import <CoreLocation/CoreLocation.h>

static NSInteger const kItemsInColumnCount = 4;
static NSInteger const kMinItemsCount = 8;
static NSInteger const kGoogleDefaultSearchRadius = 1000;
static NSTimeInterval const kSelectionDuration = 1.0;

@interface FPGameViewControllerDataSource () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) FPGameViewControllerDataSourceEmptyCallback fetchCompletionCallback;
@property (nonatomic, copy) FPGameViewControllerDataSourceEmptyCallback pairSelectCallback;
@property (nonatomic, copy) FPGameViewControllerDataSourceEmptyCallback pairMatchCallback;
@property (nonatomic, copy) FPGameViewControllerDataSourceEmptyCallback gameOverCallback;
@property (nonatomic, copy) FPGameViewControllerDataSourceEmptyCallback pairNotMatchCallback;

@property (nonatomic, strong) NSArray <FPPairItem *> *pairItems;
@property (nonatomic, assign) NSInteger totalMatchesFound;

@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation FPGameViewControllerDataSource
#pragma mark - Initialization

+ (FPGameViewControllerDataSource *)dataSourceWithCollectionView:(UICollectionView *)collectionView
                                         fetchCompletionCallback:(FPGameViewControllerDataSourceEmptyCallback)fetchCompletionCallback
                                              pairSelectCallback:(FPGameViewControllerDataSourceEmptyCallback)pairSelectCallback
                                               pairMatchCallback:(FPGameViewControllerDataSourceEmptyCallback)pairMatchCallback
                                            pairNotMatchCallback:(FPGameViewControllerDataSourceEmptyCallback)pairNotMatchCallback
                                                gameOverCallback:(FPGameViewControllerDataSourceEmptyCallback)gameOverCallback {
    NSAssert(collectionView != nil, @"FPGameViewControllerDataSource collectionView can not be nil.");
    NSAssert(fetchCompletionCallback != nil, @"FPGameViewControllerDataSource fetchCompletionCallback can not be nil.");
    NSAssert(pairSelectCallback != nil, @"FPGameViewControllerDataSource fetchCompletionCallback can not be nil.");
    NSAssert(pairMatchCallback != nil, @"FPGameViewControllerDataSource fetchCompletionCallback can not be nil.");
    NSAssert(pairNotMatchCallback != nil, @"FPGameViewControllerDataSource fetchCompletionCallback can not be nil.");
    NSAssert(gameOverCallback != nil, @"FPGameViewControllerDataSource fetchCompletionCallback can not be nil.");
    return [[self alloc] initWithCollectionView:collectionView
                        fetchCompletionCallback:fetchCompletionCallback
                             pairSelectCallback:pairSelectCallback
                              pairMatchCallback:pairMatchCallback
                           pairNotMatchCallback:pairNotMatchCallback
                               gameOverCallback:gameOverCallback];
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
               fetchCompletionCallback:(FPGameViewControllerDataSourceEmptyCallback)fetchCompletionCallback
                    pairSelectCallback:(FPGameViewControllerDataSourceEmptyCallback)pairSelectCallback
                     pairMatchCallback:(FPGameViewControllerDataSourceEmptyCallback)pairMatchCallback
                  pairNotMatchCallback:(FPGameViewControllerDataSourceEmptyCallback)pairNotMatchCallback
                      gameOverCallback:(FPGameViewControllerDataSourceEmptyCallback)gameOverCallback {
    NSAssert(fetchCompletionCallback != nil, @"fetchCompletionCallback can not be nil.");
    NSAssert(pairSelectCallback != nil, @"fetchCompletionCallback can not be nil.");
    NSAssert(pairMatchCallback != nil, @"fetchCompletionCallback can not be nil.");
    NSAssert(pairNotMatchCallback != nil, @"fetchCompletionCallback can not be nil.");
    NSAssert(gameOverCallback != nil, @"fetchCompletionCallback can not be nil.");
    self = [super init];
    if (self) {
        self.totalMatchesFound = 0;
        self.collectionView = collectionView;
        self.pairSelectCallback = pairSelectCallback;
        self.pairMatchCallback = pairMatchCallback;
        self.pairNotMatchCallback = pairNotMatchCallback;
        self.gameOverCallback = gameOverCallback;
        self.fetchCompletionCallback = fetchCompletionCallback;
        [self configureLocationManager];
        [self configureCollectionView];
    }
    return self;
}

#pragma mark - Configuration

- (void)configureLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        self.locationManager.allowsBackgroundLocationUpdates = NO;
    }
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.locationManager.delegate = self;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)configureCollectionView {
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FPPairItemCVCell class]) bundle:nil]
          forCellWithReuseIdentifier:NSStringFromClass([FPPairItemCVCell class])];
    [self.collectionView reloadData];
}

- (void)configureWithPrefilledData {
    self.fetchCompletionCallback();
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    } else if (status == kCLAuthorizationStatusDenied ||
               status == kCLAuthorizationStatusRestricted) {
        [self configureWithPrefilledData];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager stopUpdatingLocation];
    [self fetchDataWithRadius:kGoogleDefaultSearchRadius];
}

#pragma mark - Fetch

- (void)fetchDataWithRadius:(NSInteger)radius {
    @weakify(self);
    
    FPPlacesServiceCompletion completion = ^(NSArray<FPPairItem *> *pairItems, NSError *error) {
        @strongify(self);
        if (!error) {
            if (pairItems.count < kMinItemsCount) {
                [self fetchDataWithRadius:radius * 2];
            } else {
                self.fetchCompletionCallback();
                self.pairItems = pairItems;
                [self.collectionView reloadData];
                [UIView animateWithDuration:.5 animations:^{
                    self.collectionView.alpha = 1.f;
                }];
            }
        } else {
            [self configureWithPrefilledData];
        }
    };
    
    CGFloat latitude = self.locationManager.location.coordinate.latitude;
    CGFloat longitude = self.locationManager.location.coordinate.longitude;
    [FPPlacesService fetchPlacesNearLatitude:latitude
                                   longitude:longitude
                                      radius:radius
                                  completion:^(NSArray<FPPairItem *> *pairItems, NSError *error) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          completion(pairItems, error);
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
        BOOL matchFount = [self.pairItems[selectedIndexPaths.firstObject.row] isEqual:self.pairItems[selectedIndexPaths.lastObject.row]];

        collectionView.userInteractionEnabled = NO;
        if (self.pairSelectCallback) {
            self.pairSelectCallback();
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSelectionDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (NSIndexPath *indexPath in selectedIndexPaths) {
                [collectionView deselectItemAtIndexPath:indexPath animated:YES];
                if (matchFount) {
                    FPPairItemCVCell *cell = (FPPairItemCVCell *)[collectionView cellForItemAtIndexPath:indexPath];
                    [cell markAsMatched];
                }
            }
            collectionView.userInteractionEnabled = YES;
        });
        
        if (matchFount) {
            self.pairMatchCallback();
            self.totalMatchesFound += 1;
        } else {
            self.pairNotMatchCallback();
        }
        
        if (self.totalMatchesFound == self.pairItems.count / 2) {
            self.gameOverCallback();
        }
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
