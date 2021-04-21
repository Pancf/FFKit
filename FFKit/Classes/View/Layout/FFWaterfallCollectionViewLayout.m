//
//  FFWaterfallCollectionViewLayout.m
//  FFKit
//
//  Created by focus on 2021/4/20.
//

#import "FFWaterfallCollectionViewLayout.h"

@implementation FFCollectionViewDecarationLayoutAttributes
@end

@implementation FFWaterfallCollectionViewLayout
{
    NSMutableArray<UICollectionViewLayoutAttributes *> *_headersLayoutAttributes;
    NSMutableArray<NSMutableArray<UICollectionViewLayoutAttributes *> *> *_itemsLayoutAttributes;
    NSMutableArray<UICollectionViewLayoutAttributes *> *_footersLayoutAttributes;
    NSMutableArray<UICollectionViewLayoutAttributes *> *_allLayoutAttributes;
    NSMutableArray<UICollectionViewLayoutAttributes *> *_decorationLayoutAttribtues;
    NSMutableArray<NSMutableArray<NSNumber *> *> *_heightsForCols;
}

- (instancetype)init
{
    if (self = [super init]) {
        _headersLayoutAttributes = [NSMutableArray array];
        _itemsLayoutAttributes = [NSMutableArray array];
        _footersLayoutAttributes = [NSMutableArray array];
        _allLayoutAttributes = [NSMutableArray array];
        _decorationLayoutAttribtues = [NSMutableArray array];
        _heightsForCols = [NSMutableArray array];
    }
    return self;
}

// MARK: - Override

- (void)prepareLayout
{
    [super prepareLayout];
    UICollectionView *collectionView = self.collectionView;
    if (!collectionView) {
        return;
    }
    NSInteger section = collectionView.numberOfSections;
    for (int i = 0; i < section; i++) {
        _heightsForCols[i] = [NSMutableArray array];
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
    NSMutableArray<UICollectionViewLayoutAttributes *> *attrs = [NSMutableArray array];
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
    if ([elementKind isEqualToString:kFFCollectionViewSupplementaryViewKindHeader]) {
        if (section >= _headersLayoutAttributes.count) {
            return nil;
        }
        return _headersLayoutAttributes[section];
    } else if ([elementKind isEqualToString:kFFCollectionViewSupplementaryViewKindFooter]) {
        if (section >=  _footersLayoutAttributes.count) {
            return nil;
        }
        return _footersLayoutAttributes[section];
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

- (BOOL)shouldInvalidateLayoutForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes
{
    
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
    
}

- (void)_layoutHeaderFrom:(CGFloat *)y inSection:(NSInteger)section
{
    UICollectionView *collectionView = self.collectionView;
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    CGSize headerSize = CGSizeZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:headerSizeInSection:)]) {
        headerSize = [self.delegate collectionView:collectionView layout:self headerSizeInSection:section];
    }
}

- (void)_layoutItemsFrom:(CGFloat *)y inSection:(NSInteger)section
{
    
}

- (void)_layoutFooterFrom:(CGFloat *)y inSection:(NSInteger)section
{
    
}

- (void)_layoutDecorationInSection:(NSInteger)section
{
    
}

@end
