//
//  FFViewController.m
//  FFKit
//
//  Created by panchenfeng@stu.xmu.edu.cn on 04/17/2021.
//  Copyright (c) 2021 panchenfeng@stu.xmu.edu.cn. All rights reserved.
//

#import "FFViewController.h"
#import <FFKit/FFWaterfallCollectionViewLayout.h>

@interface FFViewController () <FFWaterfallCollectionViewLayoutDelegate, UICollectionViewDataSource>

@end

@implementation FFViewController

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(FFWaterfallCollectionViewLayout *)layout numberOfColsInSection:(NSInteger)section
{
    return section + 2;
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

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __auto_type cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(UICollectionViewCell.class) forIndexPath:indexPath];
    UILabel *label = [UILabel new];
    label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
    [cell.contentView addSubview:label];
    cell.contentView.backgroundColor = UIColor.greenColor;
    label.frame = CGRectMake(0, 0, 40, 40);
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    FFWaterfallCollectionViewLayout *layout = [FFWaterfallCollectionViewLayout new];
    layout.delegate = self;
    UICollectionView *view = [[UICollectionView alloc] initWithFrame:UIScreen.mainScreen.bounds
                                                collectionViewLayout:layout];
    [view registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:NSStringFromClass(UICollectionViewCell.class)];
    view.dataSource = self;
    [self.view addSubview:view];
}

@end
