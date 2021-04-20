//
//  FFWaterfullCollectionViewLayout.h
//  FFKit
//
//  Created by focus on 2021/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FFWaterfullCollectionViewLayout;

@protocol FFWaterfullCollectionViewLayoutDelegate <NSObject>

@required
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(FFWaterfullCollectionViewLayout *)layout numberOfColsInSection:(NSInteger)section;

@optional
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(FFWaterfullCollectionViewLayout *)layout insetsInSection:(NSInteger)section;

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(FFWaterfullCollectionViewLayout *)layout headerInsetsInSection:(NSInteger)section;

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(FFWaterfullCollectionViewLayout *)layout footerInsetsInSection:(NSInteger)section;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(FFWaterfullCollectionViewLayout *)layout headerSizeInSection:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FFWaterfullCollectionViewLayout *)layout itemHeightAtIndexPath:(NSIndexPath *)indexPath;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(FFWaterfullCollectionViewLayout *)layout footerSizeInSection:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FFWaterfullCollectionViewLayout *)layout minimumLineSpacingInSection:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FFWaterfullCollectionViewLayout *)layout minimumInteritemSpacingInSection:(NSInteger)section;

@end

@interface FFWaterfullCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, weak) id<FFWaterfullCollectionViewLayoutDelegate> delegate;
@property (nonatomic, assign) CGFloat minimumLineSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) CGFloat numberOfCols;

@end

NS_ASSUME_NONNULL_END
