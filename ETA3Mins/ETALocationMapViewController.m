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
@property (nonatomic, strong) CLLocation* pinnedLocation;

@end

@implementation ETALocationMapViewController {
    BOOL m_bZoomedFirstTime;
    CLLocation* m_pinnedLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _prepareMapView];
    [self _prepareInitialLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = @"Hold To Pin";
    
    UIBarButtonItem* cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnCancelClicked)];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    
    UIBarButtonItem* doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDoneClicked)];
    self.navigationItem.rightBarButtonItem = doneBarButton;
}

- (void)_prepareMapView {
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleMapViewLongPress:)];
    [self.map addGestureRecognizer:longPress];
}

- (void)_prepareInitialLocation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(provideDefaultLocation)]) {
        self.specifiedInitialLocation = [self.delegate provideDefaultLocation];
    }
    
    if (self.specifiedInitialLocation) {
        self.pinnedLocation = self.specifiedInitialLocation;
        [self _zoomToCurrentLocation:self.specifiedInitialLocation withAnnotationPin:YES];
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

- (void)_zoomToCurrentLocation:(CLLocation*)location withAnnotationPin:(BOOL)bPin{
    MKCoordinateRegion region;
    region.center = location.coordinate;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    region.span = span;
    
    [self.map setRegion:region animated:YES];
    
    m_bZoomedFirstTime = YES;
    
    if (bPin) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _dropUserPin:location.coordinate];
        });
    }
}

- (void)_dropUserPin:(CLLocationCoordinate2D)location2D {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = location2D;
    for (id annotation in self.map.annotations) {
        [self.map removeAnnotation:annotation];
    }
    [self.map addAnnotation:point];
    
    self.pinnedLocation = [[CLLocation alloc] initWithLatitude:location2D.latitude longitude:location2D.longitude];
}

#pragma mark - button functions & IBActions
- (void)btnCancelClicked {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)btnDoneClicked {
    if (self.pinnedLocation && self.delegate && [self.delegate respondsToSelector:@selector(ETALocationMapView:didSelectedLocation:)]) {
        [self.delegate ETALocationMapView:self didSelectedLocation:self.pinnedLocation];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleMapViewLongPress:(UIGestureRecognizer*)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [recognizer locationInView:self.map];
    CLLocationCoordinate2D touchMapCoordinate = [self.map convertPoint:touchPoint toCoordinateFromView:self.map];
    
    [self _dropUserPin:touchMapCoordinate];
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
            [self _zoomToCurrentLocation:location withAnnotationPin:NO];
        }
        else {

        }
    }
    
    [self.locationManager stopUpdatingLocation];
}

@end
