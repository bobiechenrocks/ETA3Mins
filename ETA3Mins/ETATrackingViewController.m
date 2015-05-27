//
//  ETATrackingViewController.m
//  ETA3Mins
//
//  Created by Bobie Chen on 1/7/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import "ETATrackingViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ETATrackingViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>

/* UI ELements */
@property (weak, nonatomic) IBOutlet UILabel *labelDestination;
@property (weak, nonatomic) IBOutlet UILabel *labelETA;
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UILabel *labelDebug;
@property (weak, nonatomic) IBOutlet UISwitch *switchStickToUser;

/* Controls */
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLLocation* destinationLocation;
@property (nonatomic, strong) NSNumber* numETAMinutes;
@property (nonatomic, strong) NSString* phoneNumberString;
@property (nonatomic, strong) NSString* smsMessage;

@end

@implementation ETATrackingViewController {
    BOOL m_bZoomedFirstTime;
    UIBackgroundTaskIdentifier m_bgTask;
    NSTimer* m_checkLocationTimer;
    int m_checkLocationInterval;
    BOOL m_bStickToUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _prepareMapView];
    [self _prepareBackgroundTaskManager];
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
    
    UIBarButtonItem* fireBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Fire" style:UIBarButtonItemStylePlain target:self action:@selector(fireSMS)];
    self.navigationItem.rightBarButtonItem = fireBarButton;
}

- (void)_prepareMapView {
    m_bZoomedFirstTime = NO;
    m_bStickToUser = YES;
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
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.destinationLocation.coordinate radius:500*[self.numETAMinutes intValue]];
        [self.map addOverlay:circle];
    }
}

- (void)_registerDestinationRegion:(CLLocationCoordinate2D)destinationLocation2D andRadius:(NSUInteger)nRadius {
    CLCircularRegion* destinationRegion = [[CLCircularRegion alloc] initWithCenter:destinationLocation2D radius:nRadius identifier:@""];
    [self.locationManager startMonitoringForRegion:destinationRegion];
    
    [self _outputDebugMessage:@"Start monitoring"];
}

- (void)_startTracking {
    m_checkLocationInterval = 5;
    [self _prepareLocationManager];
}

- (void)_prepareLocationManager {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            self.locationManager.delegate = self;
            self.locationManager.pausesLocationUpdatesAutomatically = YES;
        }
        
        [self _registerDestinationRegion:self.destinationLocation.coordinate andRadius:500*[self.numETAMinutes intValue]];
        [self.locationManager startMonitoringSignificantLocationChanges];
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
    
    if (!m_bZoomedFirstTime) {
        MKCoordinateSpan span;
        span.latitudeDelta = 0.03;
        span.longitudeDelta = 0.03;
        region.span = span;
        
        /* delay adding pan-gesture recognizer after the map is zoomed at first time location-update */
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
        [panGesture setDelegate:self];
        [self.map addGestureRecognizer:panGesture];
        
        [self.locationManager stopUpdatingLocation];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            m_bZoomedFirstTime = YES;
            [self.locationManager startUpdatingLocation];
        });
    }
    else {
        region.span = self.map.region.span;
    }
    
    [self.map setRegion:region animated:YES];
    
    if (bPin) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _dropUserPin:location.coordinate];
        });
    }
}

- (void)_outputDebugMessage:(NSString*)debugMessage {
    self.labelDebug.text = debugMessage;
    [self.labelDebug sizeToFit];
}

- (void)_prepareBackgroundTaskManager {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
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
    [self.locationManager stopUpdatingLocation];
    NSArray* regionArray = [NSArray arrayWithArray:[[self.locationManager monitoredRegions] allObjects]];
    if ([regionArray count] > 0) {
        [self.locationManager stopMonitoringForRegion:regionArray[0]];
    }
    self.locationManager = nil;
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)stickToUserSwitched:(id)sender {
    m_bStickToUser = self.switchStickToUser.on;
    if (m_bStickToUser) {
        [self _zoomToCurrentLocation:self.locationManager.location withAnnotationPin:NO];
    }
}

- (void)fireSMS {
    [self _sendETAMessage];
}

#pragma mark - location-manager background task handler
- (void)_applicationDidEnterBackground:(NSNotification*)notification {
    if([self _isLocationServiceAvailable]==YES){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self _startCheckLocationTimer];
            [self _startBackgroundTask];
        });
    }
}

- (void)_applicationDidBecomeActive:(NSNotification*)notification {
    [self _stopBackgroundTask];
}

-(BOOL)_isLocationServiceAvailable
{
    if([CLLocationManager locationServicesEnabled]==NO ||
       [CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied ||
       [CLLocationManager authorizationStatus]==kCLAuthorizationStatusRestricted){
        return NO;
    }else{
        return YES;
    }
}

- (void)_startBackgroundTask {
    [self _stopBackgroundTask];
    UIBackgroundRefreshStatus bgRefreshStatus = [[UIApplication sharedApplication] backgroundRefreshStatus];
    m_bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        //in case bg task is killed faster than expected, try to start Location Service
        [self _timerEvent:m_checkLocationTimer];
    }];
}

- (void)_stopBackgroundTask {
    if(m_bgTask!=UIBackgroundTaskInvalid){
        [[UIApplication sharedApplication] endBackgroundTask:m_bgTask];
        m_bgTask = UIBackgroundTaskInvalid;
    }
}

- (void)_timerEvent:(NSTimer*)theTimer
{
    [self _stopCheckLocationTimer];
    [self.locationManager startUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
    
    // in iOS 7 we need to stop background task with delay, otherwise location service won't start
    [self performSelector:@selector(_stopBackgroundTask) withObject:nil afterDelay:1];
}

-(void)_startCheckLocationTimer {
    [self _stopCheckLocationTimer];
    m_checkLocationTimer = [NSTimer scheduledTimerWithTimeInterval:m_checkLocationInterval target:self selector:@selector(_timerEvent:) userInfo:NULL repeats:YES];
}

-(void)_stopCheckLocationTimer {
    if(m_checkLocationTimer){
        [m_checkLocationTimer invalidate];
        m_checkLocationTimer=nil;
    }
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
        /*
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        */
    }
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (!m_bZoomedFirstTime) {
        [self.locationManager stopUpdatingLocation];
    }
    if ((!m_bZoomedFirstTime || m_bStickToUser) && [locations count] > 0) {
        CLLocation* location = locations[0];
        [self _zoomToCurrentLocation:location withAnnotationPin:NO];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self _sendETAMessage];
    
    [self _outputDebugMessage:@"Entering region"];
}

- (void)_sendETAMessage {
    /* Let's send some SMS messages! */
    NSString* postString = [NSString stringWithFormat:@"to=%@&message=%@", self.phoneNumberString, self.smsMessage];
    NSData* postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* postLengthString = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://bobie-twilio.appspot.com/etaTwiMinutes"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLengthString forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:10.0f];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        /* maybe do something later */
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%ld", (long)httpResponse.statusCode);
            NSString* alertMessage = (httpResponse.statusCode == 200)? @"Approaching destination. Message sent." : @"Something wrong when sending message.";
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
                UILocalNotification* notification = [[UILocalNotification alloc] init];
                NSArray* oldNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
                if ([oldNotifications count] > 0) {
                    [[UIApplication sharedApplication] cancelAllLocalNotifications];
                }
                notification.alertBody = alertMessage;
                notification.fireDate = [NSDate date];
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            }
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ahoy" message:alertMessage delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    }];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"start region monitoring");
    
    [self _outputDebugMessage:@"Monitoring region"];
}

#pragma mark - gesture-recognizer on mapView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded){
        self.switchStickToUser.on = NO;
        [self stickToUserSwitched:nil];
    }
}

#pragma mark - MKMapViewDelegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay {
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor redColor];
    circleView.fillColor = [UIColor redColor];
    circleView.alpha = 0.3f;
    circleView.lineWidth = 2;
    
    return circleView;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.locationManager stopUpdatingLocation];
    NSArray* regionArray = [NSArray arrayWithArray:[[self.locationManager monitoredRegions] allObjects]];
    if ([regionArray count] > 0) {
        [self.locationManager stopMonitoringForRegion:regionArray[0]];
    }
    self.locationManager = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
