//
//  FFWaterfallCollectionViewLayout.h
//  FFKit
//
//  Created by focus on 2021/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FFWaterfallCollectionViewLayout;

typedef NS_ENUM(NSInteger, FFCollectionViewDecarationType) {
    FFCollectionViewDecarationTypeNone = 0,
    FFCollectionViewDecarationTypeSolidColor,
    FFCollectionViewDecarationTypeGradient,
    FFCollectionViewDecarationTypeImage
};

@interface FFCollectionViewDecarationLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, assign) FFCollectionViewDecarationType type;
// For solidColor
@property (nonatomic, strong, nullable) UIColor *backgroundColor;
// For gradient
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, copy, nullable) NSArray<UIColor *> *colors;
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *locations;
// for image
@property (nonatomic, strong) UIImage *backgroundImage;

@end


@protocol FFWaterfallCollectionViewLayoutDelegate <NSObject>

@required
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout numberOfColsInSection:(NSInteger)section;

@optional
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout insetsInSection:(NSInteger)section;

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout headerInsetsInSection:(NSInteger)section;

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout footerInsetsInSection:(NSInteger)section;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout headerSizeInSection:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout itemHeightAtIndexPath:(NSIndexPath *)indexPath;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout footerSizeInSection:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout minimumLineSpacingInSection:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout minimumInteritemSpacingInSection:(NSInteger)section;

- (FFCollectionViewDecarationLayoutAttributes *)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout decorationAttributesInSection:(NSInteger)section;

@end

@interface FFWaterfallCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, weak) id<FFWaterfallCollectionViewLayoutDelegate> delegate;
@property (nonatomic, assign) CGFloat minimumLineSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;

@end

NS_ASSUME_NONNULL_END
