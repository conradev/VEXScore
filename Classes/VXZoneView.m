//
//  VXZoneView.m
//  VEXScore
//
//  Created by Conrad Kramer on 2/6/14.
//  Copyright (c) 2014 Conrad Kramer. All rights reserved.
//

#import "VXZoneView.h"
#import "VXSteppingSlider.h"

@interface VXZoneView ()

@property (weak, nonatomic) UILabel *ballLabel;

@property (weak, nonatomic) UILabel *buckyLabel;

@end

@implementation VXZoneView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;

        VXSteppingSlider *ballSlider = [[VXSteppingSlider alloc] init];
        ballSlider.maximumValue = 4.0f;
        ballSlider.translatesAutoresizingMaskIntoConstraints = NO;
        [ballSlider addTarget:self action:@selector(ballSliderChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:ballSlider];
        self.ballSlider = ballSlider;

        UILabel *ballLabel = [[UILabel alloc] init];
        ballLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        ballLabel.textAlignment = NSTextAlignmentCenter;
        ballLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:ballLabel];
        self.ballLabel = ballLabel;

        VXSteppingSlider *buckySlider = [[VXSteppingSlider alloc] init];
        buckySlider.maximumValue = 10.0f;
        buckySlider.translatesAutoresizingMaskIntoConstraints = NO;
        [buckySlider addTarget:self action:@selector(buckySliderChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:buckySlider];
        self.buckySlider = buckySlider;

        UILabel *buckyLabel = [[UILabel alloc] init];
        buckyLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        buckyLabel.textAlignment = NSTextAlignmentCenter;
        buckyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:buckyLabel];
        self.buckyLabel = buckyLabel;

        [self ballSliderChanged];
        [self buckySliderChanged];

        NSDictionary *metrics = @{ @"label": @60 };
        NSDictionary *views = NSDictionaryOfVariableBindings(nameLabel, ballSlider, ballLabel, buckySlider, buckyLabel);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nameLabel]-(10)-[ballSlider]-(10)-[buckySlider]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[nameLabel]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[ballSlider][ballLabel(label)]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[buckySlider][buckyLabel(label)]|" options:0 metrics:metrics views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:ballLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:ballSlider attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:buckyLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:buckySlider attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    }
    return self;
}

- (void)ballSliderChanged {
    if ([self.delegate respondsToSelector:@selector(zoneView:ballSliderChangedValue:)])
        [self.delegate zoneView:self ballSliderChangedValue:self.ballSlider.value];
    self.ballLabel.text = [NSString stringWithFormat:@"%02d", (int)self.ballSlider.value];
}

- (void)buckySliderChanged {
    if ([self.delegate respondsToSelector:@selector(zoneView:buckySliderChangedValue:)])
        [self.delegate zoneView:self buckySliderChangedValue:self.buckySlider.value];
    self.buckyLabel.text = [NSString stringWithFormat:@"%02d", (int)self.buckySlider.value];
}

@end
