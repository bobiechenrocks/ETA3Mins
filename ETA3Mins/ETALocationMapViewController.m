//
//  ETALocationMapViewController.m
//  ETA3Mins
//
//  Created by bobiechen on 1/6/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import "ETALocationMapViewController.h"
#import <MapKit/MapKit.h>

@interface ETALocationMapViewController () <CLLocationManagerDelegate>

/* UI Elements */
@property (weak, nonatomic) IBOutlet MKMapView *map;

/* Controls */
@property (nonatomic, strong) CLLocation* specifiedInitialLocation;
@property (nonatomic, strong) CLLocationManager* locationManager;

@end

@implementation ETALocationMapViewController {
    BOOL m_bZoomedFirstTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _prepareInitialLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = @"Select Location";
    
    UIBarButtonItem* cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnCancelClicked)];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    
    UIBarButtonItem* doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDoneClicked)];
    self.navigationItem.rightBarButtonItem = doneBarButton;
}

- (void)_prepareInitialLocation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(provideDefaultLocation)]) {
        self.specifiedInitialLocation = [self.delegate provideDefaultLocation];
    }
    
    [self _prepareLocationManager];
}

- (void)_prepareLocationManager {
    m_bZoomedFirstTime = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            self.locationManager.delegate = self;
        }
        [self.locationManager startUpdatingLocation];
    });
}

- (void)_zoomToCurrentLocation:(CLLocation*)currentLocation {
    MKCoordinateRegion region;
    region.center = currentLocation.coordinate;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    region.span = span;
    
    [self.map setRegion:region];
    
    m_bZoomedFirstTime = YES;
}

#pragma mark - button functions
- (void)btnCancelClicked {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)btnDoneClicked {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        /* pass selected location via delegate */
    }];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Please enable location service in the device preferences"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if (status == kCLAuthorizationStatusNotDetermined) {
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (!m_bZoomedFirstTime && [locations count] > 0) {
        if (!self.specifiedInitialLocation) {
            CLLocation* location = locations[0];
            [self _zoomToCurrentLocation:location];
        }
        else {
            [self _zoomToCurrentLocation:self.specifiedInitialLocation];
        }
    }
    
    [self.locationManager stopUpdatingLocation];
}

@end
