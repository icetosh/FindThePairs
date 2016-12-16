//
//  FPGameViewControllerDataSource.h
//  FindThePairs
//
//  Created by Prokopiev on 12/16/16.
//  Copyright © 2016 Nick Prokopiev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FPGameViewControllerDataSourceEmptyCallback)();

@interface FPGameViewControllerDataSource : NSObject
+ (FPGameViewControllerDataSource *)dataSourceWithCollectionView:(UICollectionView *)collectionView
                                         fetchCompletionCallback:(FPGameViewControllerDataSourceEmptyCallback)fetchCompletionCallback
                                              itemSelectCallback:(FPGameViewControllerDataSourceEmptyCallback)itemSelectCallback;
@end
