//
//  RZViewController.m
//  RZViewActionsSample
//
//  Created by Rob Visentin on 12/11/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZViewController.h"
#import "UIView+RZViewActions.h"

@implementation RZViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.statusLabel.textColor = [UIColor lightGrayColor];
    self.statusLabel.text = @"Running...";
    
    RZViewAction *rotate = [RZViewAction action:^{
        self.testLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
    } withDuration:1.0f];
    
    RZViewAction *scale = [RZViewAction action:^{
        self.testLabel.transform = CGAffineTransformConcat(self.testLabel.transform, CGAffineTransformMakeScale(2.0f, 2.0f));
    } withDuration:0.5f];
    
    RZViewAction *wait = [RZViewAction waitForDuration:2.0f];
    
    RZViewAction *scaleBack = [RZViewAction action:^{
        self.testLabel.transform = CGAffineTransformIdentity;
    } withDuration:1.0f];
    
    RZViewAction *fade = [RZViewAction action:^{
        self.testLabel.alpha = 0.1f;
    } withDuration:2.0f];
    
    RZViewAction *seq = [RZViewAction sequence:@[rotate, scale, wait, [RZViewAction group:@[scaleBack, fade]]]];
    
    RZViewAction *trans = [RZViewAction action:^{
        self.testViewLeftConstraint.constant = 100.0f;
        [self.testView layoutIfNeeded];
    } withOptions:UIViewAnimationOptionCurveEaseInOut duration:3.0f];
    
    RZViewAction *color = [RZViewAction action:^{
        self.testView.backgroundColor = [UIColor blueColor];
    } withDuration:0.5f];
    
    [UIView rz_runAction:[RZViewAction group:@[seq, [RZViewAction sequence:@[trans, color]]]] withCompletion:^(BOOL finished) {
        self.statusLabel.textColor = [UIColor greenColor];
        self.statusLabel.text = @"Done!";
    }];
}

@end
