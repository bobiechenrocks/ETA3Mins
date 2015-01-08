//
//  ETATrackingViewController.m
//  ETA3Mins
//
//  Created by Bobie Chen on 1/7/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import "ETATrackingViewController.h"
#import <MapKit/MapKit.h>

@interface ETATrackingViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

/* UI ELements */
@property (weak, nonatomic) IBOutlet UILabel *labelDestination;
@property (weak, nonatomic) IBOutlet UILabel *labelETA;
@property (weak, nonatomic) IBOutlet MKMapView *map;

/* Controls */
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLLocation* destinationLocation;
@property (nonatomic, strong) NSNumber* numETAMinutes;
@property (nonatomic, strong) NSString* phoneNumberString;
@property (nonatomic, strong) NSString* smsMessage;

@end

@implementation ETATrackingViewController {
    BOOL m_bZoomedFirstTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _prepareMapView];
    [self _prepareToStart];
    [self _startTracking];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = @"Tracking";
    
    UIBarButtonItem* stopBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(btnStopClicked)];
    self.navigationItem.leftBarButtonItem = stopBarButton;
}

- (void)_prepareMapView {
    self.map.delegate = self;
}

- (void)_prepareToStart {
    /* get info from the delegate */
    if (self.delegate && [self.delegate respondsToSelector:@selector(provideTrackingTaskInfo)]) {
        NSDictionary* trackingTaskInfo = [self.delegate provideTrackingTaskInfo];
        if (!trackingTaskInfo) {
            return;
        }
        
        self.destinationLocation = trackingTaskInfo[@"destination"];
        self.numETAMinutes = trackingTaskInfo[@"eta"];
        self.phoneNumberString = trackingTaskInfo[@"number"];
        self.smsMessage = trackingTaskInfo[@"message"];
        
        self.labelDestination.text = [NSString stringWithFormat:@"%3.5f, %3.5f", self.destinationLocation.coordinate.latitude, self.destinationLocation.coordinate.longitude];
        self.labelETA.text = [NSString stringWithFormat:@"%d Minutes", [self.numETAMinutes intValue]];
        
        [self _dropUserPin:self.destinationLocation.coordinate];
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.destinationLocation.coordinate radius:1000];
        [self.map addOverlay:circle];
    }
}

- (void)_startTracking {
    [self _prepareLocationManager];
}

- (void)_prepareLocationManager {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            self.locationManager.delegate = self;
        }
        [self.locationManager startUpdatingLocation];
    });
}

- (void)_dropUserPin:(CLLocationCoordinate2D)location2D {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = location2D;
    for (id annotation in self.map.annotations) {
        [self.map removeAnnotation:annotation];
    }
    [self.map addAnnotation:point];
}

- (void)_zoomToCurrentLocation:(CLLocation*)location withAnnotationPin:(BOOL)bPin {
    MKCoordinateRegion region;
    region.center = location.coordinate;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.03;
    span.longitudeDelta = 0.03;
    region.span = span;
    
    [self.map setRegion:region animated:YES];
    
    m_bZoomedFirstTime = YES;
    
    if (bPin) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _dropUserPin:location.coordinate];
        });
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - button functions
- (IBAction)userLocationClicked:(id)sender {
    [self _zoomToCurrentLocation:self.locationManager.location withAnnotationPin:NO];
}

- (IBAction)destinationLocationClicked:(id)sender {
    [self _zoomToCurrentLocation:self.destinationLocation withAnnotationPin:NO];
}

- (void)btnStopClicked {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
        CLLocation* location = locations[0];
        [self _zoomToCurrentLocation:location withAnnotationPin:NO];
    }
}

#pragma mark - MKMapViewDelegate
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor redColor];
    circleView.lineWidth = 2;
    
    return circleView;
}

@end
