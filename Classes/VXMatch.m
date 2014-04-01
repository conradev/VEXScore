//
//  VXMatch.m
//  VEXScore
//
//  Created by Conrad Kramer on 2/6/14.
//  Copyright (c) 2014 Conrad Kramer. All rights reserved.
//

#import "VXMatch.h"
#import "VXAlliance.h"

@implementation VXMatch

- (void)awakeFromInsert {
    [super awakeFromInsert];

    self.created = [NSDate date];
    self.red = [VXAlliance insertInManagedObjectContext:self.managedObjectContext];
    self.blue = [VXAlliance insertInManagedObjectContext:self.managedObjectContext];
}

@end
