//
//  RZViewController.m
//  RZViewActionsSample
//
//  Created by Rob Visentin on 12/11/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZViewController.h"
#import "UIView+RZViewActions.h"

@interface RZViewController ()

@property (copy, nonatomic) NSArray *letters;

@end

@implementation RZViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.letters = [self labelArrayFromLabel:self.copyrightLabel];
}

#pragma mark - touch handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( !self.spinner.isAnimating ) {
        [self.spinner startAnimating];
        
        RZViewAction *action = [RZViewAction group:@[[self titleAnimation], [self waveAnimation], [self colorAnimation]]];
        
        [UIView rz_runAction:action withCompletion:^(BOOL finished) {
            [self.spinner stopAnimating];
        }];
    }
}

#pragma mark - animation helpers

- (RZViewAction *)titleAnimation
{
    RZViewAction *rotate1 = [RZViewAction action:^{
        self.titleLabel.transform = CGAffineTransformRotate(self.titleLabel.transform, M_PI_4);
    } withDuration:1.0f];
    
    RZViewAction *rotate2 = [RZViewAction action:^{
        self.titleLabel.transform = CGAffineTransformRotate(self.titleLabel.transform, -M_PI_2);
    } withDuration:1.0f];
    
    RZViewAction *scale = [RZViewAction action:^{
        self.titleLabel.transform = CGAffineTransformScale(self.titleLabel.transform, 1.25f, 1.25f);
    } withDuration:2.0f];
    
    RZViewAction *seq = [RZViewAction sequence:@[rotate1, rotate2, rotate1]];
    RZViewAction *group = [RZViewAction group:@[seq, scale]];
    
    return group;
}

- (RZViewAction *)waveAnimation
{
    NSMutableArray *wordAnimations = [NSMutableArray array];
    
    NSTimeInterval delay = 0.0f;
    
    for ( UILabel *letter in self.letters ) {
        RZViewAction *animation = [self jumpAnimationForView:letter afterDelay:delay];
        [wordAnimations addObject:animation];
        
        delay += 0.025f;
    }
    
    return [RZViewAction group:wordAnimations];
}

- (RZViewAction *)jumpAnimationForView:(UIView *)view afterDelay:(NSTimeInterval)delay
{
    RZViewAction *wait = [RZViewAction waitForDuration:delay];
    
    CGFloat jumpHeight = 40.0f;
    
    RZViewAction *up = [RZViewAction action:^{
        view.transform = CGAffineTransformTranslate(view.transform, 0.0f, -jumpHeight);
    } withOptions:UIViewAnimationOptionCurveEaseIn duration:0.3f];
    
    RZViewAction *down = [RZViewAction action:^{
        view.transform = CGAffineTransformTranslate(view.transform, 0.0f, jumpHeight);
    } withOptions:UIViewAnimationOptionCurveEaseOut duration:0.3f];
    
    RZViewAction *seq = [RZViewAction sequence:@[wait, up, down]];
    
    return seq;
}

- (RZViewAction *)colorAnimation
{
    NSMutableArray *actions = [NSMutableArray array];

    [self.letters enumerateObjectsUsingBlock:^(UILabel *letter, NSUInteger idx, BOOL *stop) {
        RZViewAction *color = [RZViewAction action:^{
            letter.alpha = 0.5f;
        } withDuration:0.01f];
        
        [actions addObject:color];
    }];
    
    [self.letters enumerateObjectsWithOptions:kNilOptions usingBlock:^(UILabel *letter, NSUInteger idx, BOOL *stop) {
        RZViewAction *uncolor = [RZViewAction action:^{
            letter.alpha = 1.0f;
        } withDuration:0.01f];
        
        [actions addObject:uncolor];
    }];
    
    return [RZViewAction sequence:actions];
}

#pragma mark - misc helpers

- (NSArray *)labelArrayFromLabel:(UILabel *)label
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    NSMutableArray *wordLabels = [NSMutableArray array];
    
    CGFloat letterX = CGRectGetMinX(label.frame);
    for ( NSUInteger i = 0; i < label.text.length; i++ ) {
        NSString *word = [label.text substringWithRange:NSMakeRange(i, 1)];
        CGSize size = [word sizeWithAttributes:@{NSFontAttributeName : label.font}];

        if ( ![whitespace characterIsMember:[word characterAtIndex:0]] ) {
            
            UILabel *wordLabel = [[UILabel alloc] initWithFrame:(CGRect){.origin.x = letterX, .size = size}];
            wordLabel.font = label.font;
            wordLabel.textColor = label.textColor;
            wordLabel.text = word;
            
            wordLabel.center = CGPointMake(wordLabel.center.x, label.center.y);
            
            [label.superview insertSubview:wordLabel aboveSubview:label];
            [wordLabels addObject:wordLabel];
        }
        
        letterX += size.width;
    }
    
    return wordLabels;
}

@end
