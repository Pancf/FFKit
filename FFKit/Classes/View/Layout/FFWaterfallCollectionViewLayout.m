//
//  FFWaterfallCollectionViewLayout.m
//  FFKit
//
//  Created by focus on 2021/4/20.
//

#import "FFWaterfallCollectionViewLayout.h"

static NSString * const kFFCollectionViewDecorationViewElementKind = @"kFFCollectionViewDecorationViewElementKind";
const CGFloat FFWaterfallCollectionViewLayoutAutomaticHeight = CGFLOAT_MAX;

@interface _FFCollectionViewDecorationLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, assign) FFCollectionViewDecorationType type;
@property (nonatomic, strong, nullable) UIColor *backgroundColor;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, copy, nullable) NSArray<UIColor *> *colors;
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *locations;
@property (nonatomic, strong) UIImage *backgroundImage;

- (void)mergeFromConfig:(FFCollectionViewDecorationConfig *)config;

@end

@implementation _FFCollectionViewDecorationLayoutAttributes

- (void)mergeFromConfig:(FFCollectionViewDecorationConfig *)config
{
    _type = config.type;
    _backgroundColor = config.backgroundColor;
    _startPoint = config.startPoint;
    _endPoint = config.endPoint;
    _colors = [config.colors copy];
    _locations = [config.locations copy];
    _backgroundImage = config.backgroundImage;
}

@end

@interface _FFCollectionViewDecorationView : UICollectionReusableView
@end

@implementation _FFCollectionViewDecorationView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    if (![layoutAttributes isKindOfClass:_FFCollectionViewDecorationLayoutAttributes.class]) {
        return;
    }
    __auto_type attr = (_FFCollectionViewDecorationLayoutAttributes *)layoutAttributes;
    switch (attr.type) {
        case FFCollectionViewDecorationTypeNone:
            self.backgroundColor = UIColor.clearColor;
            break;
        case FFCollectionViewDecorationTypeSolidColor:
            self.backgroundColor = attr.backgroundColor;
            break;
        case FFCollectionViewDecorationTypeGradient: {
            CAGradientLayer *layer = (CAGradientLayer *)self.layer;
            layer.startPoint = attr.startPoint;
            layer.endPoint = attr.endPoint;
            layer.locations = attr.locations;
            NSMutableArray *colors = [NSMutableArray arrayWithCapacity:attr.colors.count];
            [attr.colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [colors addObject:(id)obj.CGColor];
            }];
            layer.colors = colors;
        }
            break;
        case FFCollectionViewDecorationTypeImage:
            self.layer.contents = attr.backgroundImage;
    }
}

+ (Class)layerClass
{
    return CAGradientLayer.class;
}

@end

@implementation FFCollectionViewDecorationConfig
@end

@interface _FFWaterfallCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, assign) NSInteger col;

@end

@implementation _FFWaterfallCollectionViewLayoutAttributes

// UICollectionViewLayoutAttributes instance may be copied
- (instancetype)copyWithZone:(NSZone *)zone
{
    _FFWaterfallCollectionViewLayoutAttributes *obj = [super copyWithZone:zone];
    obj.col = self.col;
    return obj;
}

@end

@implementation FFWaterfallCollectionViewLayout
{
    NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes *> *_headersLayoutAttributes;
    NSMutableArray<NSMutableArray<_FFWaterfallCollectionViewLayoutAttributes *> *> *_itemsLayoutAttributes;
    NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes *> *_footersLayoutAttributes;
    NSMutableArray<_FFCollectionViewDecorationLayoutAttributes *> *_decorationLayoutAttribtues;
    NSMutableArray<NSMutableArray<NSNumber *> *> *_heightsForCols;
    NSMutableDictionary<NSIndexPath *, NSNumber *> *_cachedIndexPathToItemHeight;
    
    BOOL _selfsizingCalculated;
}

- (instancetype)init
{
    if (self = [super init]) {
        _headersLayoutAttributes = [NSMutableDictionary dictionary];
        _itemsLayoutAttributes = [NSMutableArray array];
        _footersLayoutAttributes = [NSMutableDictionary dictionary];
        _decorationLayoutAttribtues = [NSMutableArray array];
        _heightsForCols = [NSMutableArray array];
        _cachedIndexPathToItemHeight = [NSMutableDictionary dictionary];
        _minimumLineSpacing = 10;
        _minimumInteritemSpacing = 10;
        _estimatedHeight = 300;
        _selfsizingCalculated = NO;
    }
    return self;
}

// MARK: - Override

- (void)prepareLayout
{
    printf("[Callstack]: %s %d\n", __PRETTY_FUNCTION__, _selfsizingCalculated);
    [super prepareLayout];
    if (_selfsizingCalculated) return;
    [self _cleanup];
    [self registerClass:_FFCollectionViewDecorationView.class forDecorationViewOfKind:kFFCollectionViewDecorationViewElementKind];
    UICollectionView *collectionView = self.collectionView;
    if (!collectionView) {
        return;
    }
    NSInteger section = collectionView.numberOfSections;
    for (int i = 0; i < section; i++) {
        _heightsForCols[i] = [NSMutableArray array];
        NSInteger numberOfCols = [self.delegate collectionView:collectionView layout:self numberOfColsInSection:i];
        for (int j = 0; j < numberOfCols; ++j) {
            _heightsForCols[i][j] = @0;
        }
    }
    CGFloat y = 0;
    for (int i = 0; i < section; ++i) {
        [self _layoutHeaderFrom:&y inSection:i];
        [self _layoutItemsFrom:&y inSection:i];
        [self _layoutFooterFrom:&y inSection:i];
        [self _layoutDecorationInSection:i];
    }
}

- (CGSize)collectionViewContentSize
{
    printf("[Callstack]: %s\n", __PRETTY_FUNCTION__);
    CGSize size = CGSizeMake(self.collectionView.bounds.size.width, _heightsForCols.lastObject.firstObject.doubleValue);
    return size;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    printf("[Callstack]: %s\n", __PRETTY_FUNCTION__);
    __block NSMutableArray<UICollectionViewLayoutAttributes *> *attrs = [super layoutAttributesForElementsInRect:rect].mutableCopy;
    if (!attrs) {
        attrs = [NSMutableArray array];
    }
    __auto_type blk = ^(UICollectionViewLayoutAttributes *obj) {
        if (CGRectIntersectsRect(obj.frame, rect)) {
            [attrs addObject:obj];
        }
    };
    [_headersLayoutAttributes enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UICollectionViewLayoutAttributes * _Nonnull obj, BOOL * _Nonnull stop) {
        blk(obj);
    }];
    [_footersLayoutAttributes enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UICollectionViewLayoutAttributes * _Nonnull obj, BOOL * _Nonnull stop) {
        blk(obj);
    }];
    [_decorationLayoutAttribtues enumerateObjectsUsingBlock:^(_FFCollectionViewDecorationLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        blk(obj);
    }];
    [_itemsLayoutAttributes enumerateObjectsUsingBlock:^(NSMutableArray<UICollectionViewLayoutAttributes *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            blk(obj);
        }];
    }];
    return attrs.copy;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    printf("[Callstack]: %s\n", __PRETTY_FUNCTION__);
    NSInteger section = indexPath.section;
    if (section >= _itemsLayoutAttributes.count) {
        return nil;
    }
    __auto_type attributesInSection = _itemsLayoutAttributes[section];
    NSInteger idx = indexPath.item;
    if (idx >= attributesInSection.count) {
        return nil;
    }
    return attributesInSection[idx];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    printf("[Callstack]: %s\n", __PRETTY_FUNCTION__);
    NSInteger section = indexPath.section;
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return _headersLayoutAttributes[@(section)];
    } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        return _footersLayoutAttributes[@(section)];
    } else {
        NSLog(@"Unknown elementKind");
        return nil;
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    printf("[Callstack]: %s\n", __PRETTY_FUNCTION__);
    NSInteger section = indexPath.section;
    if (section >= _decorationLayoutAttribtues.count) {
        return nil;
    }
    if ([elementKind isEqualToString:kFFCollectionViewDecorationViewElementKind]) {
        return _decorationLayoutAttribtues[section];
    } else {
        return nil;
    }
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    printf("[Callstack]: %s\n", __PRETTY_FUNCTION__);
    CGRect oldBounds = self.collectionView.bounds;
    return oldBounds.size.width != newBounds.size.width;
}

- (BOOL)shouldInvalidateLayoutForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes
{
    printf("[Callstack]: %s\n", __PRETTY_FUNCTION__);
    // Step1,when user scrolls，_updateVisibleCellsNow: will call
    // [UICollectionReusableView preferredLayoutAttributesFittingAttributes:].
    // Default implementation will calculate result according to AutoLayout constraints.
    // Step2, decide whether invalidating layout or not with originalAttributes and preferredAttributes
    if (originalAttributes.representedElementCategory == UICollectionElementCategoryCell) {
        CGSize originalSize = originalAttributes.size;
        CGSize preferredSize = preferredAttributes.size;
        return ceil(originalSize.height) != ceil(preferredSize.height);
    }
    return [super shouldInvalidateLayoutForPreferredLayoutAttributes:preferredAttributes withOriginalAttributes:originalAttributes];
}

- (void)invalidateLayout
{
    printf("[Callstack]: %s\n", __PRETTY_FUNCTION__);
    [super invalidateLayout];
    [self _cleanup];
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes
{
    printf("[Callstack]: %s\n", __PRETTY_FUNCTION__);
    // Step3, If Step2 return true，then construct an instance of UICollectionViewLayoutInvalidationContext
    __auto_type cxt = [super invalidationContextForPreferredLayoutAttributes:preferredAttributes withOriginalAttributes:originalAttributes];
    _cachedIndexPathToItemHeight[originalAttributes.indexPath] = @(ceil(preferredAttributes.size.height));
    [cxt invalidateItemsAtIndexPaths:@[originalAttributes.indexPath]];
    cxt.contentSizeAdjustment = CGSizeMake(cxt.contentSizeAdjustment.width, preferredAttributes.size.height - originalAttributes.size.height);
    return cxt;
}

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context
{
    printf("[Callstack]: %s %ld-%ld\n", __PRETTY_FUNCTION__, context.invalidatedItemIndexPaths.firstObject.section, context.invalidatedItemIndexPaths.firstObject.item);
    // Step4, use context from step3 to recalculate layout so that avoid full calculation in prepareLayout:
    // TODO: I haven't find perfect resolution yet.
    [super invalidateLayoutWithContext:context];
    NSIndexPath *firstIndexPath = context.invalidatedItemIndexPaths.firstObject;
    if (firstIndexPath.section >= _itemsLayoutAttributes.count ||
        firstIndexPath.item >= _itemsLayoutAttributes[firstIndexPath.section].count) {
        return;
    }
    CGFloat heightAdjustment = context.contentSizeAdjustment.height;
    
   __auto_type layoutAttribute = _itemsLayoutAttributes[firstIndexPath.section][firstIndexPath.item];
    CGRect frame = layoutAttribute.frame;
    frame.size.height = _cachedIndexPathToItemHeight[firstIndexPath].doubleValue;
    layoutAttribute.frame = frame;
    
    NSInteger col = layoutAttribute.col;
    __auto_type layoutAttributesInSection = _itemsLayoutAttributes[firstIndexPath.section];
    for (NSInteger i = firstIndexPath.item + 1; i < layoutAttributesInSection.count; ++i) {
        if (layoutAttributesInSection[i].col == col) {
            CGRect frame = layoutAttributesInSection[i].frame;
            frame.origin.y += heightAdjustment;
            layoutAttributesInSection[i].frame = frame;
        }
    }
    
    __block CGFloat maxHeight = CGFLOAT_MIN;
    __block NSInteger maxCol = NSNotFound;
    [_heightsForCols[firstIndexPath.section] enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.doubleValue > maxHeight) {
            maxHeight = obj.doubleValue;
            maxCol = idx;
        }
    }];
    _heightsForCols[firstIndexPath.section][col] = @(_heightsForCols[firstIndexPath.section][col].doubleValue + heightAdjustment);
    
    if (maxCol == col) {
        for (NSInteger i = firstIndexPath.section + 1; i < _heightsForCols.count; ++i) {
            for (NSInteger j = 0; j < _heightsForCols[i].count; ++j) {
            }
        }
    }
    _selfsizingCalculated = YES;
}

// MARK: - Private

- (void)_cleanup
{
    [_headersLayoutAttributes removeAllObjects];
    [_footersLayoutAttributes removeAllObjects];
    [_itemsLayoutAttributes removeAllObjects];
    [_decorationLayoutAttribtues removeAllObjects];
    [_heightsForCols removeAllObjects];
}

- (NSInteger)_whichColToLayoutItem:(NSIndexPath *)indexPath
{
    __auto_type heightsInSection = _heightsForCols[indexPath.section];
    __block NSInteger col = 0;
    __block CGFloat minHeight = CGFLOAT_MAX;
    [heightsInSection enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.doubleValue < minHeight) {
            minHeight = obj.doubleValue;
            col = idx;
        }
    }];
    return col;
}

- (void)_layoutHeaderFrom:(CGFloat *)y inSection:(NSInteger)section
{
    UICollectionView *collectionView = self.collectionView;
    UIEdgeInsets headerInsets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:headerInsetsInSection:)]) {
        headerInsets = [self.delegate collectionView:collectionView layout:self headerInsetsInSection:section];
    }
    *y += (headerInsets.top);
    
    CGFloat width = collectionView.bounds.size.width;
    CGFloat headerHeight = 0;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:headerHeightInSection:)]) {
        headerHeight = [self.delegate collectionView:collectionView layout:self headerHeightInSection:section];
        if (headerHeight > DBL_EPSILON) {
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attr.frame = CGRectMake(headerInsets.left,
                                    *y,
                                    width - headerInsets.left - headerInsets.right,
                                    headerHeight);
            _headersLayoutAttributes[@(section)] = attr;
        }
    }
    
    UIEdgeInsets sectionInsets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInsets = [self.delegate collectionView:collectionView layout:self insetsInSection:section];
    }
    *y += (headerHeight + headerInsets.bottom + sectionInsets.top);
    __auto_type heightsInSection = _heightsForCols[section];
    for (int i = 0; i < heightsInSection.count; ++i) {
        heightsInSection[i] = @(*y);
    }
}

- (void)_layoutItemsFrom:(CGFloat *)y inSection:(NSInteger)section
{
    UICollectionView *collectionView = self.collectionView;
    UIEdgeInsets sectionInsets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInsets = [self.delegate collectionView:collectionView layout:self insetsInSection:section];
    }
    
    CGFloat minimumLineSpacing = _minimumLineSpacing;
    CGFloat minimumInteritemSpacing = _minimumInteritemSpacing;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingInSection:)]) {
        minimumLineSpacing = [self.delegate collectionView:collectionView layout:self minimumLineSpacingInSection:section];
    }
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingInSection:)]) {
        minimumInteritemSpacing = [self.delegate collectionView:collectionView layout:self minimumInteritemSpacingInSection:section];
    }
    
    NSInteger numberOfCols = [self.delegate collectionView:collectionView layout:self numberOfColsInSection:section];
    CGFloat width = collectionView.bounds.size.width;
    CGFloat itemWidth = (width - sectionInsets.left - sectionInsets.right - (numberOfCols - 1) * minimumInteritemSpacing) / numberOfCols;
    CGFloat padding = itemWidth + minimumInteritemSpacing;
    
    NSInteger numberOfItems = [collectionView numberOfItemsInSection:section];
    NSMutableArray<_FFWaterfallCollectionViewLayoutAttributes *> *itemAttributes = [NSMutableArray arrayWithCapacity:numberOfItems];
    
    __auto_type heightsInSection = _heightsForCols[section];
    for (int i = 0; i < numberOfItems; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
        _FFWaterfallCollectionViewLayoutAttributes *attr = [_FFWaterfallCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        NSInteger col = [self _whichColToLayoutItem:indexPath];
        CGFloat itemHeight = [self.delegate collectionView:collectionView layout:self itemHeightAtIndexPath:indexPath];
        if (itemHeight == FFWaterfallCollectionViewLayoutAutomaticHeight) {
            itemHeight = _cachedIndexPathToItemHeight[indexPath] ? _cachedIndexPathToItemHeight[indexPath].doubleValue : self.estimatedHeight;
        }
        attr.frame = CGRectMake(sectionInsets.left + padding * col,
                                heightsInSection[col].doubleValue,
                                itemWidth,
                                itemHeight);
        attr.col = col;
        heightsInSection[col] = @(CGRectGetMaxY(attr.frame) + minimumLineSpacing);
        [itemAttributes addObject:attr];
    }
    [_itemsLayoutAttributes addObject:itemAttributes];
    
    for (int i = 0; i < heightsInSection.count; ++i) {
        heightsInSection[i] = @(heightsInSection[i].doubleValue - minimumLineSpacing);
    }
    __block CGFloat maxHeight = CGFLOAT_MIN;
    [heightsInSection enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.doubleValue > maxHeight) {
            maxHeight = obj.doubleValue;
        }
    }];
    *y = maxHeight;
}

- (void)_layoutFooterFrom:(CGFloat *)y inSection:(NSInteger)section
{
    UICollectionView *collectionView = self.collectionView;
    CGFloat width = collectionView.bounds.size.width;
    UIEdgeInsets footerInsets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:footerInsetsInSection:)]) {
        footerInsets = [self.delegate collectionView:collectionView layout:self footerInsetsInSection:section];
    }
    UIEdgeInsets sectionInsets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInsets = [self.delegate collectionView:collectionView layout:self insetsInSection:section];
    }
    *y += (footerInsets.top + sectionInsets.bottom);
    
    CGFloat footerHeight = 0;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:footerHeightInSection:)]) {
        footerHeight = [self.delegate collectionView:collectionView layout:self footerHeightInSection:section];
        if (footerHeight > DBL_EPSILON) {
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attr.frame = CGRectMake(footerInsets.left,
                                    *y,
                                    width - footerInsets.left - footerInsets.right,
                                    footerHeight);
            _footersLayoutAttributes[@(section)] = attr;
        }
    }
    
    *y += (footerHeight + footerInsets.bottom);
    __auto_type heightsInSection = _heightsForCols[section];
    for (int i = 0; i < heightsInSection.count; ++i) {
        heightsInSection[i] = @(*y);
    }
}

- (void)_layoutDecorationInSection:(NSInteger)section
{
    UICollectionView *collectionView = self.collectionView;
    _FFCollectionViewDecorationLayoutAttributes *attr = [_FFCollectionViewDecorationLayoutAttributes layoutAttributesForDecorationViewOfKind:kFFCollectionViewDecorationViewElementKind withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    attr.type = FFCollectionViewDecorationTypeNone;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:decorationConfigInSection:)]) {
        FFCollectionViewDecorationConfig *config = [self.delegate collectionView:collectionView layout:self decorationConfigInSection:section];
        [attr mergeFromConfig:config];
    }
    
    UIEdgeInsets sectionInsets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInsets = [self.delegate collectionView:collectionView layout:self insetsInSection:section];
    }

    __auto_type itemAttributesInSection = _itemsLayoutAttributes[section];
    __auto_type heightsInSection = _heightsForCols[section];
    CGFloat startY = itemAttributesInSection.firstObject.frame.origin.y;
    CGFloat height = heightsInSection.lastObject.doubleValue - startY - _footersLayoutAttributes[@(section)].frame.size.height;
    attr.frame = CGRectMake(sectionInsets.left,
                            startY,
                            collectionView.bounds.size.width - sectionInsets.left - sectionInsets.right,
                            height);
    attr.zIndex = -1;
    [_decorationLayoutAttribtues addObject:attr];
}

@end
