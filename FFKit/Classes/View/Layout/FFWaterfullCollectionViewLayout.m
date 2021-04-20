//
//  FFWaterfullCollectionViewLayout.m
//  FFKit
//
//  Created by focus on 2021/4/20.
//

#import "FFWaterfullCollectionViewLayout.h"

@implementation FFWaterfullCollectionViewLayout
{
    NSMutableArray<UICollectionViewLayoutAttributes *> *_headersLayoutAttributes;
    NSMutableArray<NSMutableArray<UICollectionViewLayoutAttributes *> *> *_itemsLayoutAttributes;
    NSMutableArray<UICollectionViewLayoutAttributes *> *_footersLayoutAttributes;
    NSMutableArray<UICollectionViewLayoutAttributes *> *_allLayoutAttributes;
    NSMutableArray<UICollectionViewLayoutAttributes *> *_decorationLayoutAttribtues;
    NSMutableArray<NSMutableArray<NSNumber *> *> *_heightsForCols;
}

// MARK: - Override

- (CGSize)collectionViewContentSize
{
    
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath
{
    
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    
}

- (BOOL)shouldInvalidateLayoutForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes
{
    
}

// MARK: - Private

@end
