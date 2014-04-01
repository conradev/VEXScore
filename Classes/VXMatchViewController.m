//
//  VXMatchViewController.m
//  VEXScore
//
//  Created by Conrad Kramer on 2/6/14.
//  Copyright (c) 2014 Conrad Kramer. All rights reserved.
//

#import "VXMatchViewController.h"

#import "VXMatch.h"
#import "VXAlliance.h"
#import "VXAllianceView.h"
#import "VXSteppingSlider.h"

@interface VXMatchViewController ()

@property (weak, nonatomic) VXAllianceView *redView;

@property (weak, nonatomic) VXAllianceView *blueView;

@property (weak, nonatomic) VXSteppingSlider *autonomousSlider;

@property (weak, nonatomic) UIView *separatorView;

@end

@implementation VXMatchViewController

#pragma mark - UIViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"Match";
    }
    return self;
}

- (void)loadView {
    [super loadView];

    self.view.backgroundColor = [UIColor whiteColor];

    VXAllianceView *redView = [[VXAllianceView alloc] init];
    redView.hidden = (_match == nil);
    redView.alliance = self.match.red;
    redView.tintColor = [UIColor redColor];
    redView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:redView];
    self.redView = redView;

    VXAllianceView *blueView = [[VXAllianceView alloc] init];
    blueView.hidden = (_match == nil);
    blueView.alliance = self.match.blue;
    blueView.tintColor = [UIColor blueColor];
    blueView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:blueView];
    self.blueView = blueView;

    UIView *separatorView = [[UIView alloc] init];
    separatorView.hidden = (_match == nil);
    separatorView.backgroundColor = [UIColor grayColor];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:separatorView];
    self.separatorView = separatorView;

    VXSteppingSlider *autonomousSlider = [[VXSteppingSlider alloc] init];
    autonomousSlider.maximumValue = 1.0f;
    autonomousSlider.minimumValue = -1.0f;
    autonomousSlider.value = _match.red.autonomousValue == VXAutonomousStateWin ? -1.0f : (_match.blue.autonomousValue == VXAutonomousStateWin ? 1.0f : 0.0f);
    [self updateSliderColor];
    [autonomousSlider addTarget:self action:@selector(autonomousSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:autonomousSlider];
    self.autonomousSlider = autonomousSlider;

    id<UILayoutSupport> topLayoutGuide = self.topLayoutGuide;
    NSDictionary *views = NSDictionaryOfVariableBindings(topLayoutGuide, redView, separatorView, blueView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[redView][separatorView(1)][blueView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLayoutGuide][redView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLayoutGuide][separatorView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLayoutGuide][blueView]|" options:0 metrics:nil views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:redView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:blueView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
}

- (void)viewDidLayoutSubviews {
    [self.redView layoutIfNeeded];
    self.autonomousSlider.bounds = CGRectMake(0, 0, 200, 100);
    self.autonomousSlider.center = CGPointMake(CGRectGetMidX(self.view.bounds), [self.view convertPoint:self.redView.scoreLabel.center fromView:self.redView.scoreLabel.superview].y);
}

#pragma mark - VXMatchViewController

- (void)setMatch:(VXMatch *)match {
    _match = match;

    self.separatorView.hidden = (_match == nil);
    self.redView.hidden = (_match == nil);
    self.blueView.hidden = (_match == nil);
    self.redView.alliance = _match.red;
    self.blueView.alliance = _match.blue;

    self.autonomousSlider.value = _match.red.autonomousValue == VXAutonomousStateWin ? -1.0f : (_match.blue.autonomousValue == VXAutonomousStateWin ? 1.0f : 0.0f);
    [self updateSliderColor];
}

- (void)autonomousSliderChanged:(UISlider *)slider {
    self.match.red.autonomousValue = slider.value < 0 ? VXAutonomousStateWin : VXAutonomousStateLoss;
    self.match.blue.autonomousValue = slider.value > 0 ? VXAutonomousStateWin : VXAutonomousStateLoss;
    [self updateSliderColor];

    NSError *error = nil;
    if (![self.match.managedObjectContext save:&error]) {
        NSLog(@"Error: Could not save autonomous status: %@", error);
    }
}

- (void)updateSliderColor {
    UIColor *color = self.autonomousSlider.value < 0 ? self.redView.tintColor : (self.autonomousSlider.value > 0 ? self.blueView.tintColor : [UIColor lightGrayColor]);
    self.autonomousSlider.minimumTrackTintColor = color;
    self.autonomousSlider.maximumTrackTintColor = color;
}

@end
