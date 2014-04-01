//
//  VXAllianceView.m
//  VEXScore
//
//  Created by Conrad Kramer on 2/6/14.
//  Copyright (c) 2014 Conrad Kramer. All rights reserved.
//

#import "VXAllianceView.h"

#import "VXAlliance.h"
#import "VXUtilities.h"
#import "VXSteppingSlider.h"
#import "VXZoneView.h"

@interface VXAllianceView () <VXZoneViewDelegate>

@property (weak, nonatomic) VXZoneView *stashingZoneView;

@property (weak, nonatomic) VXZoneView *scoringZoneView;

@property (weak, nonatomic) VXZoneView *middleZoneView;

@end

@implementation VXAllianceView

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *scoreLabel = [[UILabel alloc] init];
        scoreLabel.font = [UIFont boldSystemFontOfSize:72.0f];
        scoreLabel.textColor = self.tintColor;
        scoreLabel.textAlignment = NSTextAlignmentCenter;
        scoreLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:scoreLabel];
        self.scoreLabel = scoreLabel;

        VXZoneView *stashingZoneView = [[VXZoneView alloc] init];
        stashingZoneView.delegate = self;
        stashingZoneView.nameLabel.text = @"Stashing";
        stashingZoneView.ballSlider.maximumValue = 2.0f;
        stashingZoneView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:stashingZoneView];
        self.stashingZoneView = stashingZoneView;

        VXZoneView *scoringZoneView = [[VXZoneView alloc] init];
        scoringZoneView.delegate = self;
        scoringZoneView.nameLabel.text = @"Scoring";
        scoringZoneView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:scoringZoneView];
        self.scoringZoneView = scoringZoneView;

        VXZoneView *middleZoneView = [[VXZoneView alloc] init];
        middleZoneView.delegate = self;
        middleZoneView.nameLabel.text = @"Middle";
        middleZoneView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:middleZoneView];
        self.middleZoneView = middleZoneView;

        [self addObserver:self forKeyPath:VXKeyPathFromSelectors(@selector(alliance), @selector(score), nil) options:NSKeyValueObservingOptionNew context:NULL];

        NSDictionary *metrics = @{ @"margin": @40, @"padding": @20 };
        NSDictionary *views = NSDictionaryOfVariableBindings(scoreLabel, stashingZoneView, scoringZoneView, middleZoneView);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(margin)-[scoreLabel]-(margin)-[stashingZoneView]-(padding)-[scoringZoneView]-(padding)-[middleZoneView]-(margin)-|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scoreLabel]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[stashingZoneView]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[scoringZoneView]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[middleZoneView]|" options:0 metrics:metrics views:views]];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:VXKeyPathFromSelectors(@selector(alliance), @selector(score), nil)];
}

- (void)tintColorDidChange {
    self.scoreLabel.textColor = self.tintColor;
}

#pragma mark - VXAllianceView

- (void)setAlliance:(VXAlliance *)alliance {
    _alliance = alliance;

    UIImage *ballImage = _alliance.matchIfBlue ? [UIImage imageNamed:@"BlueBall.png"] : [UIImage imageNamed:@"RedBall.png"];
    UIImage *buckyImage = _alliance.matchIfBlue ? [UIImage imageNamed:@"BlueBucky.png"] : [UIImage imageNamed:@"RedBucky.png"];
    [self.stashingZoneView.ballSlider setThumbImage:ballImage forState:UIControlStateNormal];
    [self.scoringZoneView.ballSlider setThumbImage:ballImage forState:UIControlStateNormal];
    [self.middleZoneView.ballSlider setThumbImage:ballImage forState:UIControlStateNormal];
    [self.stashingZoneView.buckySlider setThumbImage:buckyImage forState:UIControlStateNormal];
    [self.scoringZoneView.buckySlider setThumbImage:buckyImage forState:UIControlStateNormal];
    [self.middleZoneView.buckySlider setThumbImage:buckyImage forState:UIControlStateNormal];

    self.stashingZoneView.ballSlider.value = _alliance.stashedBallsValue;
    self.scoringZoneView.ballSlider.value = _alliance.scoredBallsValue;
    self.middleZoneView.ballSlider.value = _alliance.middleBallsValue;
    self.stashingZoneView.buckySlider.value = _alliance.stashedBuckysValue;
    self.scoringZoneView.buckySlider.value = _alliance.scoredBuckysValue;
    self.middleZoneView.buckySlider.value = _alliance.middleBuckysValue;
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSNumber *score = [change[NSKeyValueChangeNewKey] isEqual:[NSNull null]] ? nil : change[NSKeyValueChangeNewKey];
    self.scoreLabel.text = [NSString stringWithFormat:@"%03d", score.intValue];
}

#pragma mark - VXZoneViewDelegate

- (void)zoneView:(VXZoneView *)zoneView ballSliderChangedValue:(float)floatValue {
    NSString *keyPath = nil;
    if ([zoneView isEqual:self.stashingZoneView])
        keyPath = NSStringFromSelector(@selector(stashedBalls));
    else if ([zoneView isEqual:self.scoringZoneView])
        keyPath = NSStringFromSelector(@selector(scoredBalls));
    else if ([zoneView isEqual:self.middleZoneView])
        keyPath = NSStringFromSelector(@selector(middleBalls));

    NSNumber *value = @(floatValue);
    if ([self.alliance validateValue:&value forKeyPath:keyPath error:nil])
        [self.alliance setValue:value forKey:keyPath];
    zoneView.ballSlider.value = value.floatValue;

    NSError *error = nil;
    if (![self.alliance.managedObjectContext save:&error]) {
        NSLog(@"Error: Could not save alliance: %@", error);
    }
}

- (void)zoneView:(VXZoneView *)zoneView buckySliderChangedValue:(float)floatValue {
    NSString *keyPath = nil;
    if ([zoneView isEqual:self.stashingZoneView])
        keyPath = NSStringFromSelector(@selector(stashedBuckys));
    else if ([zoneView isEqual:self.scoringZoneView])
        keyPath = NSStringFromSelector(@selector(scoredBuckys));
    else if ([zoneView isEqual:self.middleZoneView])
        keyPath = NSStringFromSelector(@selector(middleBuckys));

    NSNumber *value = @(floatValue);
    if ([self.alliance validateValue:&value forKeyPath:keyPath error:nil])
        [self.alliance setValue:value forKey:keyPath];
    zoneView.buckySlider.value = value.floatValue;

    NSError *error = nil;
    if (![self.alliance.managedObjectContext save:&error]) {
        NSLog(@"Error: Could not save alliance: %@", error);
    }
}

@end
