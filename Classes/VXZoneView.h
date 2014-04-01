//
//  VXZoneView.h
//  VEXScore
//
//  Created by Conrad Kramer on 2/6/14.
//  Copyright (c) 2014 Conrad Kramer. All rights reserved.
//

@import UIKit;

@class VXZoneView, VXSteppingSlider;

@protocol VXZoneViewDelegate <NSObject>
@optional
- (void)zoneView:(VXZoneView *)zoneView ballSliderChangedValue:(float)value;
- (void)zoneView:(VXZoneView *)zoneView buckySliderChangedValue:(float)value;
@end

@interface VXZoneView : UIView

@property (weak, nonatomic) UILabel *nameLabel;

@property (weak, nonatomic) VXSteppingSlider *ballSlider;

@property (weak, nonatomic) VXSteppingSlider *buckySlider;

@property (weak, nonatomic) id<VXZoneViewDelegate> delegate;

@end
