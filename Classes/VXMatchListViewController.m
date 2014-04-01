//
//  VXMatchListViewController.m
//  VEXScore
//
//  Created by Conrad Kramer on 2/6/14.
//  Copyright (c) 2014 Conrad Kramer. All rights reserved.
//

#import "VXMatchListViewController.h"

#import "VXMatch.h"
#import "VXAlliance.h"

@interface VXMatchListViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

static NSString * const VXMatchCellIdentifier = @"VXMatchCellIdentifier";
static NSString * const VXMatchListCacheName = @"VXMatchListCache";

@implementation VXMatchListViewController

#pragma mark - UIViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = @"Matches";
        self.editing = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:VXMatchCellIdentifier];
    [self.tableView selectRowAtIndexPath:[self.fetchedResultsController indexPathForObject:self.selectedMatch] animated:nil scrollPosition:UITableViewScrollPositionNone];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        [self.navigationItem setLeftBarButtonItem:nil animated:animated];
        [self.navigationItem setRightBarButtonItem:self.editButtonItem animated:animated];
    } else {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createMatch)];
        [self.navigationItem setLeftBarButtonItem:self.editButtonItem animated:animated];
        [self.navigationItem setRightBarButtonItem:addButton animated:animated];
    }
}

#pragma mark - VXMatchListViewController

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:[VXMatch entityName] inManagedObjectContext:managedObjectContext];
    fetchRequest.fetchBatchSize = 20;
    fetchRequest.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:NSStringFromSelector(@selector(created)) ascending:YES] ];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:VXMatchListCacheName];
    self.fetchedResultsController.delegate = self;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error: Could not perform fetch: %@", error);
    }

    self.selectedMatch = (self.fetchedResultsController.sections.count ? [[self.fetchedResultsController.sections[0] objects] firstObject] : nil) ?: [VXMatch insertInManagedObjectContext:managedObjectContext];
    [self.tableView selectRowAtIndexPath:[self.fetchedResultsController indexPathForObject:self.selectedMatch] animated:nil scrollPosition:UITableViewScrollPositionNone];
}

- (NSManagedObjectContext *)managedObjectContext {
    return self.fetchedResultsController.managedObjectContext;
}

- (void)createMatch {
    [VXMatch insertInManagedObjectContext:self.managedObjectContext];

    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: Could not create match: %@", error);
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VXMatchCellIdentifier];

    VXMatch *match = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = match.created.description;

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController.sections[section] numberOfObjects];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        VXMatch *match = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([self.selectedMatch isEqual:match])
            self.selectedMatch = nil;
        [self.managedObjectContext deleteObject:match];

        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error: Could not delete match: %@", error);
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedMatch = [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
