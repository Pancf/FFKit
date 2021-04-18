//
//  FFViewController.m
//  FFKit
//
//  Created by panchenfeng@stu.xmu.edu.cn on 04/17/2021.
//  Copyright (c) 2021 panchenfeng@stu.xmu.edu.cn. All rights reserved.
//

#import "FFViewController.h"
#import <FFKit/FFLinearGradientView.h>

@interface FFViewController ()

@end

@implementation FFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    FFLinearGradientView *view = [[FFLinearGradientView alloc] initWithStartPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1) locations:@[@0, @0.6, @1] colors:@[UIColor.whiteColor, UIColor.greenColor, UIColor.redColor]];
    view.frame = CGRectMake(0, 0, 200, 200);
    [self.view addSubview:view];
}

@end
