//
//  VXSteppingSlider.m
//  VEXScore
//
//  Created by Conrad Kramer on 2/6/14.
//  Copyright (c) 2014 Conrad Kramer. All rights reserved.
//

#import "VXSteppingSlider.h"

@implementation VXSteppingSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.step = 1.0f;
    }
    return self;
}

- (void)setValue:(float)value animated:(BOOL)animated {
    [super setValue:(roundf(value / self.step) * self.step) animated:animated];
}

@end
