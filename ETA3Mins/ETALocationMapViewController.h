//
//  ETALocationMapViewController.h
//  ETA3Mins
//
//  Created by bobiechen on 1/6/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol ETALocationMapDelegate <NSObject>

@optional
- (CLLocationCoordinate2D*)provideDefaultLocation;

@end

@interface ETALocationMapViewController : UIViewController

@property (nonatomic, weak) id<ETALocationMapDelegate>delegate;

@end
