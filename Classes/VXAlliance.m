//
//  VXAlliance.m
//  VEXScore
//
//  Created by Conrad Kramer on 2/6/14.
//  Copyright (c) 2014 Conrad Kramer. All rights reserved.
//

#import "VXAlliance.h"

#import "VXUtilities.h"

static NSInteger const VXAllianceMaximumBalls = 4;
static NSInteger const VXAllianceMaximumBuckys = 10;

@implementation VXAlliance

+ (NSSet *)keyPathsForValuesAffectingScore {
    return [self keyPathsForValuesAffectingScoreValue];
}

+ (NSSet *)keyPathsForValuesAffectingScoreValue {
    return VXKeyPathsFromSelectors(@selector(autonomous),
                                   @selector(redHanging),
                                   @selector(blueHanging),
                                   @selector(stashedBalls),
                                   @selector(stashedBuckys),
                                   @selector(scoredBalls),
                                   @selector(scoredBuckys),
                                   @selector(middleBalls),
                                   @selector(middleBuckys), nil);
}

- (NSNumber *)score {
    return @([self scoreValue]);
}

- (NSInteger)scoreValue {
    NSInteger autonomous = self.autonomousValue == VXAutonomousStateWin ? 10 : 0;
    NSInteger hanging = self.redHangingValue * 5 + self.blueHangingValue * 5;
    return ((self.stashedBallsValue * 10) +
            (self.stashedBuckysValue * 5) +
            (self.scoredBallsValue * 5) +
            (self.scoredBuckysValue * 2) +
            self.middleBallsValue +
            self.middleBuckysValue +
            autonomous +
            hanging);
}

- (BOOL)validateValue:(id *)ioValue forKey:(NSString *)key error:(NSError **)outError {
    NSMutableSet *ballKeyPaths = [VXKeyPathsFromSelectors(@selector(stashedBalls), @selector(scoredBalls), @selector(middleBalls), nil) mutableCopy];
    NSMutableSet *buckyKeyPaths = [VXKeyPathsFromSelectors(@selector(stashedBuckys), @selector(scoredBuckys), @selector(middleBuckys), nil) mutableCopy];
    id value = ioValue ? *ioValue : nil;

    if ([ballKeyPaths containsObject:key]) {
        [ballKeyPaths removeObject:key];
        NSMutableSet *ballValues = [NSMutableSet set];
        [ballKeyPaths enumerateObjectsUsingBlock:^(id obj, BOOL *stop) { [ballValues addObject:[self valueForKey:obj]]; }];
        NSNumber *maximumValue = @(VXAllianceMaximumBalls - [[ballValues valueForKeyPath:@"@sum.self"] integerValue]);
        if ([maximumValue compare:value] == NSOrderedAscending)
            *ioValue = maximumValue;
        return YES;
    } else if ([buckyKeyPaths containsObject:key]) {
        [buckyKeyPaths removeObject:key];
        NSMutableSet *buckyValues = [NSMutableSet set];
        [buckyKeyPaths enumerateObjectsUsingBlock:^(id obj, BOOL *stop) { [buckyValues addObject:[self valueForKeyPath:obj]]; }];
        __autoreleasing NSNumber *maximumValue = @(VXAllianceMaximumBuckys - [[buckyValues valueForKeyPath:@"@sum.self"] integerValue]);
        if ([maximumValue compare:value] == NSOrderedAscending)
            *ioValue = maximumValue;
        return YES;
    }

    return YES;
}

@end
