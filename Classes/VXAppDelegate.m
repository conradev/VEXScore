//
//  VXAppDelegate.m
//  VEXScore
//
//  Created by Conrad Kramer on 2/6/14.
//  Copyright (c) 2014 Conrad Kramer. All rights reserved.
//

@import CoreData;

#import "VXAppDelegate.h"

#import "VXMatchListViewController.h"
#import "VXMatchViewController.h"

@interface VXAppDelegate () <UISplitViewControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) VXMatchListViewController *matchListViewController;

@property (strong, nonatomic) VXMatchViewController *matchViewController;

@end

@implementation VXAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    VXMatchListViewController *matchListViewController = [[VXMatchListViewController alloc] init];
    [matchListViewController addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedMatch)) options:NSKeyValueObservingOptionNew context:NULL];
    matchListViewController.managedObjectContext = self.managedObjectContext;
    self.matchListViewController = matchListViewController;

    self.matchViewController = [[VXMatchViewController alloc] init];
    self.matchViewController.match = matchListViewController.selectedMatch;

    UINavigationController *listNavController = [[UINavigationController alloc] initWithRootViewController:self.matchListViewController];
    UINavigationController *matchNavController = [[UINavigationController alloc] initWithRootViewController:self.matchViewController];

    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    splitViewController.presentsWithGesture = NO;
    splitViewController.viewControllers = @[ listNavController, matchNavController ];
    splitViewController.delegate = self;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = splitViewController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self.matchListViewController removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedMatch))];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.matchViewController.match = [change[NSKeyValueChangeNewKey] isEqual:[NSNull null]] ? nil : change[NSKeyValueChangeNewKey];
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    [self.matchViewController.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self.matchViewController.navigationItem setLeftBarButtonItem:nil animated:YES];
}

#pragma mark - VXAppDelegate

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext == nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }

    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel == nil) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"VEXScore" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator == nil) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"VEXScore.sqlite"];

        @try {
            [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil];
        }
        @catch (NSException *exception) {
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
            if ([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil] == nil) {
                [exception raise];
            }
        }
    }

    return _persistentStoreCoordinator;
}

@end
