//
//  AppDelegate.m
//  PNTester
//
//  Created by Pradnyesh Gore on 3/19/17.
//  Copyright © 2017 Pradnyesh Gore. All rights reserved.
//

@import UserNotifications;

#import "AppDelegate.h"
#import <UserNotifications/UNUserNotificationCenter.h>


@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>

@end

@implementation AppDelegate

const NSString* kGCMMessageIDKey = @"gcm.message_id";


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// Configure notfication center.
	[UNUserNotificationCenter currentNotificationCenter].delegate = self;
	UNAuthorizationOptions authOptions =
					UNAuthorizationOptionAlert |
					UNAuthorizationOptionSound|
					UNAuthorizationOptionBadge;
	[[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:
						authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
						}];
	[FIRMessaging messaging].remoteMessageDelegate = self;
	[[UIApplication sharedApplication] registerForRemoteNotifications];
	
	// Configure firebase
	[FIRApp configure];
	
	// token observer
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
												 name:kFIRInstanceIDTokenRefreshNotification object:nil];

	return YES;
}

- (void)applicationReceivedRemoteMessage:(nonnull FIRMessagingRemoteMessage *)remoteMessage
{
	NSLog(@"Received Remote Message %@", remoteMessage);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	// If you are receiving a notification message while your app is in the background,
	// this callback will not be fired till the user taps on the notification launching the application.
	// TODO: Handle data of notification
	
	// Print message ID.
	if (userInfo[kGCMMessageIDKey])
	{
		NSLog(@"Message ID: %@ didReceiveRemoteNotification", userInfo[kGCMMessageIDKey]);
	}
	
	// Print full message.
	NSLog(@"%@", userInfo);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
													   fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	// If you are receiving a notification message while your app is in the background,
	// this callback will not be fired till the user taps on the notification launching the application.
	// TODO: Handle data of notification
	
	// Print message ID.
	if (userInfo[kGCMMessageIDKey]) {
		NSLog(@"Message ID: %@ didReceiveRemoteNotification", userInfo[kGCMMessageIDKey]);
	}
	
	// Print full message.
	NSLog(@"%@", userInfo);
	
	completionHandler(UIBackgroundFetchResultNewData);
}


// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
	   willPresentNotification:(UNNotification *)notification
		 withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
	// Print message ID.
	NSDictionary *userInfo = notification.request.content.userInfo;
	if (userInfo[kGCMMessageIDKey])
	{
		NSLog(@"Message ID: %@ willPresentNotification", userInfo[kGCMMessageIDKey]);
	}
	
	// Print full message.
	NSLog(@"%@", userInfo);
	
	// Change this to your preferred presentation option
	completionHandler(UNNotificationPresentationOptionAlert);
}


// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
		 withCompletionHandler:(void (^)())completionHandler
{
	NSDictionary *userInfo = response.notification.request.content.userInfo;
	if (userInfo[kGCMMessageIDKey])
	{
		NSLog(@"Message ID: %@ didReceiveNotificationResponse", userInfo[kGCMMessageIDKey]);
	}
	
	// Print full message.
	NSLog(@"%@", userInfo);
	
	completionHandler();
}


//// FCM
- (void)tokenRefreshNotification:(NSNotification *)notification
{
	// Note that this callback will be fired everytime a new token is generated, including the first
	// time. So if you need to retrieve the token as soon as it is available this is where that
	// should be done.
	NSString *refreshedToken = [[FIRInstanceID instanceID] token];
	
	NSLog(@"InstanceID Refreshed token: %@", refreshedToken);
	
	// Connect to FCM since connection may have failed when attempted before having a token.
	[self connectToFcm];
	
	// TODO: If necessary send token to application server.
}


- (void)connectToFcm
{
	// Won't connect since there is no token
	if (![[FIRInstanceID instanceID] token])
	{
		return;
	}
	
	// Disconnect previous FCM connection if it exists.
	[[FIRMessaging messaging] disconnect];
	
	[[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error)
	{
		if (error != nil) {
			NSLog(@"Unable to connect to FCM. %@", error);
		} else {
			NSLog(@"Connected to FCM.");
		}
		NSLog(@"Instance ID :%@", [[FIRInstanceID instanceID] token]);
	}];
}

////////
////////
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"Unable to register for remote notifications: %@", error);
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSLog(@"APNs token retrieved: %@", deviceToken);
	
	// With swizzling disabled you must set the APNs token here.
	// [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[[FIRMessaging messaging] disconnect];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[self connectToFcm];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"PNTester"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
