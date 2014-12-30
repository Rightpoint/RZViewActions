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

@property (copy, nonatomic) NSArray *tapLetters;
@property (copy, nonatomic) NSArray *copyrightLetters;

@end

@implementation RZViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.tapLetters = [self decomposeLabel:self.tapLabel];
    self.copyrightLetters = [self decomposeLabel:self.copyrightLabel];
}

#pragma mark - touch handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( self.tapLetters != nil ) {
        [UIView rz_runAction:[self tapLabelAnimation]];
        self.tapLetters = nil;
    }
    
    if ( !self.spinner.isAnimating ) {
        [self.spinner startAnimating];
        
        RZViewAction *action = [RZViewAction group:@[[self titleAnimation], [self waveAnimation], [self fadeAnimation]]];
        
        [UIView rz_runAction:action withCompletion:^(BOOL finished) {
            [self.spinner stopAnimating];
        }];
    }
}

#pragma mark - animation helpers

- (RZViewAction *)titleAnimation
{
    RZViewAction *scaleUp = [RZViewAction action:^{
        self.titleLabel.transform = CGAffineTransformScale(self.titleLabel.transform, 1.3f, 1.3f);
    } withOptions:UIViewAnimationOptionCurveEaseOut duration:0.2f];
    
    RZViewAction *scaleDown = [RZViewAction action:^{
        self.titleLabel.transform = CGAffineTransformIdentity;
    } withDuration:0.15];
    
    RZViewAction *wait = [RZViewAction waitForDuration:0.7];
    
    RZViewAction *pulse = [RZViewAction sequence:@[scaleUp, scaleDown, wait]];
    RZViewAction *seq = [RZViewAction sequence:@[pulse, pulse, pulse]];
    
    return seq;
}

- (RZViewAction *)waveAnimation
{
    NSMutableArray *wordAnimations = [NSMutableArray array];
    
    [self.copyrightLetters enumerateObjectsUsingBlock:^(UILabel *letter, NSUInteger idx, BOOL *stop) {
        RZViewAction *animation = [self jumpAnimationForView:letter afterDelay:(0.025 * idx)];
        [wordAnimations addObject:animation];
    }];
    
    return [RZViewAction group:wordAnimations];
}

- (RZViewAction *)jumpAnimationForView:(UIView *)view afterDelay:(NSTimeInterval)delay
{
    RZViewAction *wait = [RZViewAction waitForDuration:delay];
    
    CGFloat jumpHeight = 40.0f;
    
    RZViewAction *up = [RZViewAction action:^{
        view.transform = CGAffineTransformTranslate(view.transform, 0.0f, -jumpHeight);
    } withOptions:UIViewAnimationOptionCurveEaseIn duration:0.3];
    
    RZViewAction *down = [RZViewAction action:^{
        view.transform = CGAffineTransformTranslate(view.transform, 0.0f, jumpHeight);
    } withOptions:UIViewAnimationOptionCurveEaseOut duration:0.3];
    
    RZViewAction *seq = [RZViewAction sequence:@[wait, up, down]];
    
    return seq;
}

- (RZViewAction *)fadeAnimation
{
    NSMutableArray *actions = [NSMutableArray array];

    [self.copyrightLetters enumerateObjectsUsingBlock:^(UILabel *letter, NSUInteger idx, BOOL *stop) {
        RZViewAction *fade = [RZViewAction action:^{
            letter.alpha = 0.5f;
        } withDuration:0.01];
        
        [actions addObject:fade];
    }];
    
    [self.copyrightLetters enumerateObjectsUsingBlock:^(UILabel *letter, NSUInteger idx, BOOL *stop) {
        RZViewAction *unfade = [RZViewAction action:^{
            letter.alpha = 1.0f;
        } withDuration:0.01];
        
        [actions addObject:unfade];
    }];
    
    return [RZViewAction sequence:actions];
}

- (RZViewAction *)tapLabelAnimation
{
    NSMutableArray *spread = [NSMutableArray array];
    NSMutableArray *circle = [NSMutableArray array];
    
    CGFloat radius = 3.0f * self.tapLetters.count;
    CGFloat angleIncrement = 2.0f * M_PI / self.tapLetters.count;
    
    [self.tapLetters enumerateObjectsUsingBlock:^(UILabel *letter, NSUInteger idx, BOOL *stop) {
        CGFloat trans = (idx % 2 == 0) ? -15.0f : 15.0f;
        
        RZViewAction *yTrans = [RZViewAction action:^{
            letter.center = CGPointMake(letter.center.x, letter.center.y + trans);
        } withOptions:UIViewAnimationOptionCurveEaseIn duration:0.5];
        
        [spread addObject:yTrans];
        
        CGFloat angle = idx * angleIncrement;
        CGFloat x = radius * cosf(angle);
        CGFloat y = radius * sinf(angle);

        RZViewAction *circleTrans = [RZViewAction action:^{
            letter.transform = CGAffineTransformMakeRotation(angle - M_PI_2);
            letter.center = CGPointMake(CGRectGetMidX(self.view.bounds) - x, CGRectGetMidY(self.view.bounds) - y);
        } withOptions:UIViewAnimationOptionCurveEaseOut duration:0.7];
        
        [circle addObject:circleTrans];
    }];
    
    RZViewAction *spreadGroup = [RZViewAction group:spread];
    RZViewAction *circleGroup = [RZViewAction group:circle];
    
    return [RZViewAction sequence:@[spreadGroup, circleGroup]];
}

#pragma mark - misc helpers

- (NSArray *)decomposeLabel:(UILabel *)label
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
    
    [label removeFromSuperview];
    
    return wordLabels;
}

@end
