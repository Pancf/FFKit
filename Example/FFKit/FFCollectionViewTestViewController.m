//
//  FFCollectionViewTestViewController.m
//  FFKit_Example
//
//  Created by focus on 2021/4/23.
//  Copyright © 2021 panchenfeng@stu.xmu.edu.cn. All rights reserved.
//

#import "FFCollectionViewTestViewController.h"
#import <FFKit/FFWaterfallCollectionViewLayout.h>

@interface _FFTextContentCell : UICollectionViewCell
@property (nonatomic, copy) NSString *content;
@end

@implementation _FFTextContentCell {
    UILabel *_label;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _label = [UILabel new];
        [self.contentView addSubview:_label];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        [_label.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
        [_label.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
        self.contentView.backgroundColor = UIColor.redColor;
    }
    return self;
}

- (void)setContent:(NSString *)content
{
    _content = [content copy];
    _label.text = content;
}

@end

@interface FFCollectionViewTestViewController () <FFWaterfallCollectionViewLayoutDelegate, UICollectionViewDataSource>

@end

@implementation FFCollectionViewTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FFWaterfallCollectionViewLayout *layout = [FFWaterfallCollectionViewLayout new];
    layout.delegate = self;
    UICollectionView *view = [[UICollectionView alloc] initWithFrame:UIScreen.mainScreen.bounds
                                                collectionViewLayout:layout];
    [view registerClass:_FFTextContentCell.class forCellWithReuseIdentifier:NSStringFromClass(_FFTextContentCell.class)];
    view.dataSource = self;
    [self.view addSubview:view];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout numberOfColsInSection:(NSInteger)section
{
    return section + 3;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout itemHeightAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.item % 5) * 10 + 40;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return section * 5 + 20;
}

- (FFCollectionViewDecorationConfig *)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout decorationConfigInSection:(NSInteger)section
{
    FFCollectionViewDecorationConfig *attr = [FFCollectionViewDecorationConfig new];
    if (section == 0) {
        attr.type = FFCollectionViewDecorationTypeSolidColor;
        attr.backgroundColor = UIColor.grayColor;
    } else if (section == 1) {
        attr.type = FFCollectionViewDecorationTypeGradient;
        attr.endPoint = CGPointMake(1, 1);
        attr.colors = @[UIColor.whiteColor, UIColor.greenColor];
    }
    return attr;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    _FFTextContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(_FFTextContentCell.class) forIndexPath:indexPath];
    cell.content = [NSString stringWithFormat:@"%ld-%ld", indexPath.section, indexPath.item];
    return cell;
}

@end
