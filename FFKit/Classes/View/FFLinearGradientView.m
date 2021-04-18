//
//  FFLinearGradientView.m
//  FFKit
//
//  Created by focus on 2021/4/18.
//

#import "FFLinearGradientView.h"

@interface FFLinearGradientView ()

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, copy) NSArray<NSNumber *> *locations;
@property (nonatomic, copy) NSArray<UIColor *> *colors;

@end

@implementation FFLinearGradientView

- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint locations:(NSArray<NSNumber *> *)locations colors:(NSArray<UIColor *> *)colors
{
    if (self = [super initWithFrame:CGRectZero]) {
        _startPoint = startPoint;
        _endPoint = endPoint;
        _locations = [locations copy];
        _colors = [colors copy];
    }
    return self;
}

+ (Class)layerClass
{
    return CAGradientLayer.class;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (CGRectEqualToRect(CGRectZero, self.bounds)) {
        return;
    }
    CAGradientLayer *layer = (CAGradientLayer *)self.layer;
    layer.startPoint = self.startPoint;
    layer.endPoint = self.endPoint;
    layer.locations = self.locations;
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:self.colors.count];
    [self.colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [colors addObject:(id)obj.CGColor];
    }];
    layer.colors = colors.copy;
}

@end
