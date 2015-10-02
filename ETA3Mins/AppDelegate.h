//
//  AppDelegate.h
//  ETA3Mins
//
//  Created by bobiechen on 1/6/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* const ETAShortcutTypeAtoptech          = @"com.bobiestudio.ETA3Mins.atoptech";
static NSString* const ETAShortcutTypeJustFire          = @"com.bobiestudio.ETA3Mins.justfire";
static NSString* const ETAShortcutNotificationAtoptech  = @"com.bobiestudio.ETA3Mins.notification.atoptech";
static NSString* const ETAShortcutNotificationJustFire  = @"com.bobiestudio.ETA3Mins.notification.justfire";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

