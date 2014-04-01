//
//  VXasd.m
//  VEXScore
//
//  Created by Conrad Kramer on 2/7/14.
//  Copyright (c) 2014 Conrad Kramer. All rights reserved.
//

#import "VXUtilities.h"

inline NSString * VXKeyPathFromSelectors(SEL selector, ...) {
    if (!selector)
        return nil;
    NSMutableArray *selectors = [NSMutableArray array];
    va_list args;
    va_start(args, selector);
    SEL arg = selector;
    do {
        [selectors addObject:NSStringFromSelector(arg)];
    } while((arg = va_arg(args, SEL)));
    va_end(args);
    return [selectors componentsJoinedByString:@"."];
}

inline NSSet * VXKeyPathsFromSelectors(SEL selector, ...) {
    if (!selector)
        return nil;
    NSMutableSet *selectors = [NSMutableSet set];
    va_list args;
    va_start(args, selector);
    SEL arg = selector;
    do {
        [selectors addObject:NSStringFromSelector(arg)];
    } while((arg = va_arg(args, SEL)));
    va_end(args);
    return [selectors copy];
}
