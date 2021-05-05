//
//  FFWaterfallCollectionViewLayout.h
//  FFKit
//
//  Created by focus on 2021/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FFWaterfallCollectionViewLayout;

typedef NS_ENUM(NSInteger, FFCollectionViewDecorationType) {
    FFCollectionViewDecorationTypeNone = 0, // clear background
    FFCollectionViewDecorationTypeSolidColor,
    FFCollectionViewDecorationTypeGradient,
    FFCollectionViewDecorationTypeImage
};

@interface FFCollectionViewDecorationConfig : NSObject

@property (nonatomic, assign) FFCollectionViewDecorationType type;
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

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout itemHeightAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout insetsInSection:(NSInteger)section;

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout headerInsetsInSection:(NSInteger)section;

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout footerInsetsInSection:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout headerHeightInSection:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout footerHeightInSection:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout minimumLineSpacingInSection:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout minimumInteritemSpacingInSection:(NSInteger)section;

- (FFCollectionViewDecorationConfig *)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout decorationConfigInSection:(NSInteger)section;

@end

extern const CGFloat FFWaterfallCollectionViewLayoutAutomaticHeight;

@interface FFWaterfallCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, weak) id<FFWaterfallCollectionViewLayoutDelegate> delegate;
@property (nonatomic, assign) CGFloat minimumLineSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) CGFloat estimatedHeight;

@end

NS_ASSUME_NONNULL_END
