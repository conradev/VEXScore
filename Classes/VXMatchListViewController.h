//
//  VXMatchListViewController.h
//  VEXScore
//
//  Created by Conrad Kramer on 2/6/14.
//  Copyright (c) 2014 Conrad Kramer. All rights reserved.
//

@import UIKit;

@class VXMatch;

@interface VXMatchListViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) VXMatch *selectedMatch;

@end
