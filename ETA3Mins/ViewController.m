//
//  ViewController.m
//  ETA3Mins
//
//  Created by bobiechen on 1/6/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import "ViewController.h"
#import "ETALocationMapViewController.h"

@interface ViewController ()

/* UI Elements*/
@property (weak, nonatomic) IBOutlet UITextField *textDestination;
@property (weak, nonatomic) IBOutlet UISlider *slideETA;
@property (weak, nonatomic) IBOutlet UILabel *textETA;
@property (weak, nonatomic) IBOutlet UITextField *textNumber;
@property (weak, nonatomic) IBOutlet UITextField *textMessage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_prepareMainView {
}

#pragma mark - button functions & IBActions
- (IBAction)onETASlided:(id)sender {
    UISlider* etaSlider = (UISlider*)sender;
    NSUInteger minutes = (NSUInteger)(etaSlider.value * 10.0) + 1;
    if (minutes > 10) {
        minutes = 10;
    }
    
    CGRect frame = self.textETA.frame;
    CGFloat originalLeft = frame.origin.x + frame.size.width;
    
    self.textETA.text = [NSString stringWithFormat:@"%lu", (NSUInteger)(etaSlider.value)];
    
//    [self.textETA sizeToFit];
    frame = self.textETA.frame;
    frame.origin.x = originalLeft - frame.size.width;
//    self.textETA.frame = frame;
}

- (IBAction)btnMapViewClicked:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ETALocationMapViewController* mapVC = [storyboard instantiateViewControllerWithIdentifier:@"ETALocationMapViewController"];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:mapVC];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (IBAction)btnStartTrackingClicked:(id)sender {
}

- (IBAction)btnSaveConfigClicked:(id)sender {
}

- (IBAction)btnLoadConfigClicked:(id)sender {
}

@end
