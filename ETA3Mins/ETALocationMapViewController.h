//
//  ETALocationMapViewController.h
//  ETA3Mins
//
//  Created by bobiechen on 1/6/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol ETALocationMapDelegate;

@interface ETALocationMapViewController : UIViewController

@property (nonatomic, weak) id<ETALocationMapDelegate>delegate;

@end


@protocol ETALocationMapDelegate <NSObject>

@optional
- (CLLocation*)provideDefaultLocation;
- (void)ETALocationMapView:(ETALocationMapViewController*)ETALocationMapView didSelectedLocation:(CLLocation*)location;

@end