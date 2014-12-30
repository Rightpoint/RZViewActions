RZViewActions
=============
It can be difficult and unwieldy to perform complex animations using `[UIView animateWithDuration...]`, especially when trying to manage several concurrent animations and their completion blocks. Core Animation offers some help with `CAAnimationGroup`, but realistically using Core Animation for such tasks can be wordy and just as cumbersome.
`RZViewActions` offers a solution.

## Basic Usage
`RZViewActions` seeks to provide additional structure to UIView animations, and allows you to define animations semantically:
```
RZViewAction *changeBg = [RZViewAction action:^{
        self.view.backgroundColor = [UIColor blueColor];
} withDuration:1.0];

[UIView rz_runAction:changeBg withCompletion:^(BOOL finished) {
  NSLog(@"The view changed background color over 1 second");
}];
```
This simple usage may not be particularly useful on its own, but is the fundamental building block for more complex actions.

## Sequences
Basic actions can be combined in sequences that run each action to completion before running the next in the sequence:
```
RZViewAction *rotate = [RZViewAction action:^{
        self.label.transform = CGAffineTransformMakeRotation(M_PI_2);
} withOptions:UIViewAnimationOptionCurveEaseInOut duration:3.0];
    
RZViewAction *wait = [RZViewAction waitForDuration:2.0];

RZViewAction *fade = [RZViewAction action:^{
  self.label.alpha = 0.5f;
} withDuration:1.0];
    
RZViewAction *seq = [RZViewAction sequence:@[rotate, wait, fade]];

[UIView rz_runAction:seq withCompletion:^(BOOL finished) {
  NSLog(@"The label rotated, and then faded out 2 seconds later");
}];
```
It's immediately clear what the intent of the above animation is, because each action is defined separately instead of nested within completion blocks.

## Groups
`RZViewActions` also provides group animations, which performs several actions at once:
```
RZViewAction *group = [RZViewAction group:@[rotate, fade]];

[UIView rz_runAction:group withCompletion:^(BOOL finished) {
  NSLog(@"The label rotated over 3 seconds, and faded out during the first second");
}];
```
Grouping behavior is difficult to accomplish with standard UIView animations, especially when trying to execute a completion block, but `RZViewActions` makes these tasks clear and simple.

## Endless Possibilities
Sequences can be added to groups and groups can be added to sequences, which means the your view animations can be arbitrarily complex. However, the self documenting nature of `RZViewActions` means your animations can grow in complexity, but your code remains approachable, debuggable, and explicit in intent.
