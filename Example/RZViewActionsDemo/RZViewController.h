//
//  RZViewController.h
//  RZViewActionsSample
//
//  Created by Rob Visentin on 12/11/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//


@import UIKit;

@interface RZViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *testLabel;
@property (weak, nonatomic) IBOutlet UIView *testView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *testViewLeftConstraint;

@end

