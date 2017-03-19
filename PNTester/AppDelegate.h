//
//  AppDelegate.h
//  PNTester
//
//  Created by Pradnyesh Gore on 3/19/17.
//  Copyright © 2017 Pradnyesh Gore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

