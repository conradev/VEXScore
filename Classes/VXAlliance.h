//
//  VXAlliance.h
//  VEXScore
//
//  Created by Conrad Kramer on 2/6/14.
//  Copyright (c) 2014 Conrad Kramer. All rights reserved.
//

#import "_VXAlliance.h"

typedef NS_ENUM(NSInteger, VXHangingState) {
    VXHangingStateNone,
    VXHangingStateLow,
    VXHangingStateHigh,
    VXHangingStateLowWithBall,
    VXHangingStateHighWithBall
};

typedef NS_ENUM(NSInteger, VXAutonomousState) {
    VXAutonomousStateLoss,
    VXAutonomousStateWin
};

@interface VXAlliance : _VXAlliance

@property (strong, nonatomic, readonly) NSNumber *score;

@property (nonatomic, readonly) NSInteger scoreValue;

@end
