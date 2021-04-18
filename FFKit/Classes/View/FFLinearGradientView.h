//
//  FFLinearGradientView.h
//  FFKit
//
//  Created by focus on 2021/4/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFLinearGradientView : UIView

@property (nonatomic, assign, readonly) CGPoint startPoint;
@property (nonatomic, assign, readonly) CGPoint endPoint;
@property (nonatomic, copy,   readonly) NSArray<UIColor * >* colors;

- (instancetype)initWithStartPoint:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint
                         locations:(NSArray<NSNumber *> * _Nullable)locations
                            colors:(NSArray<UIColor *> *)colors;

- (instancetype)init NS_UNAVAILABLE;


@end

NS_ASSUME_NONNULL_END
