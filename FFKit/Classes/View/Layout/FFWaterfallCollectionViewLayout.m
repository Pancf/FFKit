//
//  FFWaterfallCollectionViewLayout.m
//  FFKit
//
//  Created by focus on 2021/4/20.
//

#import "FFWaterfallCollectionViewLayout.h"

static NSString * const kFFCollectionViewDecorationViewElementKind = @"kFFCollectionViewDecorationViewElementKind";

@interface _FFCollectionViewDecorationView : UICollectionReusableView
@end

@implementation _FFCollectionViewDecorationView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    if (![layoutAttributes isKindOfClass:FFCollectionViewDecorationLayoutAttributes.class]) {
        return;
    }
    __auto_type attr = (FFCollectionViewDecorationLayoutAttributes *)layoutAttributes;
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

@implementation FFCollectionViewDecorationLayoutAttributes
@end

@implementation FFWaterfallCollectionViewLayout
{
    NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes *> *_headersLayoutAttributes;
    NSMutableArray<NSMutableArray<UICollectionViewLayoutAttributes *> *> *_itemsLayoutAttributes;
    NSMutableDictionary<NSNumber *, UICollectionViewLayoutAttributes *> *_footersLayoutAttributes;
    NSMutableArray<UICollectionViewLayoutAttributes *> *_allLayoutAttributes;
    NSMutableArray<UICollectionViewLayoutAttributes *> *_decorationLayoutAttribtues;
    NSMutableArray<NSMutableArray<NSNumber *> *> *_heightsForCols;
}

- (instancetype)init
{
    if (self = [super init]) {
        _headersLayoutAttributes = [NSMutableDictionary dictionary];
        _itemsLayoutAttributes = [NSMutableArray array];
        _footersLayoutAttributes = [NSMutableDictionary dictionary];
        _allLayoutAttributes = [NSMutableArray array];
        _decorationLayoutAttribtues = [NSMutableArray array];
        _heightsForCols = [NSMutableArray array];
        _minimumLineSpacing = 10;
        _minimumInteritemSpacing = 10;
    }
    return self;
}

// MARK: - Override

- (void)prepareLayout
{
    [super prepareLayout];
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
    __block CGFloat maxHeight = CGFLOAT_MIN;
    [_heightsForCols.lastObject enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        maxHeight = (maxHeight > obj.doubleValue ? maxHeight : obj.doubleValue);
    }];
    CGSize size = CGSizeMake(self.collectionView.bounds.size.width, maxHeight);
    return size;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray<UICollectionViewLayoutAttributes *> *attrs = [super layoutAttributesForElementsInRect:rect].mutableCopy;
    if (!attrs) {
        attrs = [NSMutableArray array];
    }
    [_allLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(obj.frame, rect)) {
            [attrs addObject:obj];
        }
    }];
    return attrs.copy;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
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
    NSInteger section = indexPath.section;
    if (section >= _decorationLayoutAttribtues.count) {
        return nil;
    }
    return _decorationLayoutAttribtues[section];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    return oldBounds.size.width != newBounds.size.width;
}

- (void)invalidateLayout
{
    [super invalidateLayout];
    [self _cleanup];
}

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context
{
    [super invalidateLayoutWithContext:context];
}

// MARK: - Private

- (void)_cleanup
{
    [_headersLayoutAttributes removeAllObjects];
    [_footersLayoutAttributes removeAllObjects];
    [_itemsLayoutAttributes removeAllObjects];
    [_allLayoutAttributes removeAllObjects];
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
    if (![self.delegate respondsToSelector:@selector(collectionView:layout:headerHeightInSection:)]) {
        return;
    }
    UICollectionView *collectionView = self.collectionView;
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    CGFloat width = collectionView.bounds.size.width;
    CGFloat headerHeight = 0;
    headerHeight = [self.delegate collectionView:collectionView layout:self headerHeightInSection:section];
    UIEdgeInsets headerInsets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:headerInsetsInSection:)]) {
        headerInsets = [self.delegate collectionView:collectionView layout:self headerInsetsInSection:section];
    }
    UIEdgeInsets sectionInsets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInsets = [self.delegate collectionView:collectionView layout:self insetsInSection:section];
    }
    *y += (sectionInsets.top + headerInsets.top);
    attr.frame = CGRectMake(sectionInsets.left + headerInsets.left,
                            *y,
                            width - sectionInsets.left - sectionInsets.right - headerInsets.left - headerInsets.right,
                            headerHeight);
    *y += headerHeight;
    __auto_type heightsInSection = _heightsForCols[section];
    for (int i = 0; i < heightsInSection.count; ++i) {
        heightsInSection[i] = @(*y);
    }
    _headersLayoutAttributes[@(section)] = attr;
    [_allLayoutAttributes addObject:attr];
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
    
    NSInteger numberOfItems = [collectionView numberOfItemsInSection:section];
    NSInteger numberOfCols = [self.delegate collectionView:collectionView layout:self numberOfColsInSection:section];
    CGFloat width = collectionView.bounds.size.width;
    CGFloat itemWidth = (width - sectionInsets.left - sectionInsets.right - (numberOfCols - 1) * minimumInteritemSpacing) / numberOfCols;
    CGFloat padding = itemWidth + minimumInteritemSpacing;
    
    NSMutableArray<UICollectionViewLayoutAttributes *> *itemAttributes = [NSMutableArray arrayWithCapacity:numberOfItems];
    __auto_type heightsInSection = _heightsForCols[section];
    for (int i = 0; i < heightsInSection.count; ++i) {
        heightsInSection[i] = @(*y);
    }
    
    for (int i = 0; i < numberOfItems; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        NSInteger col = [self _whichColToLayoutItem:indexPath];
        CGFloat itemHeight = [self.delegate collectionView:collectionView layout:self itemHeightAtIndexPath:indexPath];
        attr.frame = CGRectMake(sectionInsets.left + padding * col,
                                heightsInSection[col].doubleValue,
                                itemWidth,
                                itemHeight);
        heightsInSection[col] = @(heightsInSection[col].doubleValue + itemHeight + minimumLineSpacing);
        [itemAttributes addObject:attr];
        [_allLayoutAttributes addObject:attr];
    }
    [_itemsLayoutAttributes addObject:itemAttributes];
    
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
    if (![self.delegate respondsToSelector:@selector(collectionView:layout:footerHeightInSection:)]) {
        return;
    }
    UICollectionView *collectionView = self.collectionView;
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    CGFloat width = collectionView.bounds.size.width;
    CGFloat footerHeight = 0;
    footerHeight = [self.delegate collectionView:collectionView layout:self footerHeightInSection:section];
    UIEdgeInsets footerInsets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:footerInsetsInSection:)]) {
        footerInsets = [self.delegate collectionView:collectionView layout:self footerInsetsInSection:section];
    }
    UIEdgeInsets sectionInsets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInsets = [self.delegate collectionView:collectionView layout:self insetsInSection:section];
    }
    attr.frame = CGRectMake(sectionInsets.left + footerInsets.left,
                            *y,
                            width - sectionInsets.left - sectionInsets.right - footerInsets.left - footerInsets.right,
                            footerHeight);
    *y += (footerHeight + sectionInsets.bottom + footerInsets.bottom);
    __auto_type heightsInSection = _heightsForCols[section];
    for (int i = 0; i < heightsInSection.count; ++i) {
        heightsInSection[i] = @(*y);
    }
    _footersLayoutAttributes[@(section)] = attr;;
    [_allLayoutAttributes addObject:attr];
}

- (void)_layoutDecorationInSection:(NSInteger)section
{
    UICollectionView *collectionView = self.collectionView;
    FFCollectionViewDecorationLayoutAttributes *attr = [FFCollectionViewDecorationLayoutAttributes layoutAttributesForDecorationViewOfKind:kFFCollectionViewDecorationViewElementKind withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    attr.type = FFCollectionViewDecorationTypeNone;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:decorationAttributesInSection:)]) {
        attr = [self.delegate collectionView:collectionView layout:self decorationAttributesInSection:section];
    }
    
    UIEdgeInsets sectionInsets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInsets = [self.delegate collectionView:collectionView layout:self insetsInSection:section];
    }

    __auto_type itemAttributesInSection = _itemsLayoutAttributes[section];
    __auto_type heightsInSection = _heightsForCols[section];
    CGFloat height = heightsInSection.lastObject.doubleValue - _footersLayoutAttributes[@(section)].frame.size.height;
    attr.frame = CGRectMake(sectionInsets.left,
                            itemAttributesInSection.firstObject.frame.origin.y,
                            collectionView.bounds.size.width - sectionInsets.left - sectionInsets.right,
                            height);
    [_decorationLayoutAttribtues addObject:attr];
    [_allLayoutAttributes addObject:attr];
}

@end
