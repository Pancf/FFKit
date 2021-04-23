//
//  FFViewController.m
//  FFKit
//
//  Created by panchenfeng@stu.xmu.edu.cn on 04/17/2021.
//  Copyright (c) 2021 panchenfeng@stu.xmu.edu.cn. All rights reserved.
//

#import "FFViewController.h"
#import "FFCollectionViewTestViewController.h"

@interface FFViewController ()

@end

@implementation FFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:@"Waterfall CollectionView" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(testWaterfallCollectionView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [btn.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

- (void)testWaterfallCollectionView
{
    FFCollectionViewTestViewController *vc = [FFCollectionViewTestViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
