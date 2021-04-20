//
//  FFCollectionViewDecarationLayoutAttributes.h
//  FFKit
//
//  Created by focus on 2021/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FFCollectionViewDecarationType) {
    FFCollectionViewDecarationTypeSolidColor = 0,
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

NS_ASSUME_NONNULL_END
