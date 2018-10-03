//
//  ViewController.m
//  AccelerometerDemo
//
//  Created by Mircea Popescu on 10/3/18.
//  Copyright © 2018 Mircea Popescu. All rights reserved.
//

#import "ViewController.h"
@import CoreMotion;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *staticLabel;
@property (weak, nonatomic) IBOutlet UILabel *dynamicLabel;
@property (weak, nonatomic) IBOutlet UIButton *staticButton;
@property (weak, nonatomic) IBOutlet UIButton *dynamicStartButton;
@property (weak, nonatomic) IBOutlet UIButton *dynamicStopButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) CMMotionManager *manager;

@property (assign, nonatomic) double x,y,z;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.staticLabel.text = @"No Data";
    self.dynamicLabel.text = @"No Data";
    self.staticButton.enabled = NO;
    self.dynamicStartButton.enabled = NO;
    self.dynamicStopButton.enabled = NO;
    
    self.x = 0.0;
    self.y = 0.0;
    self.z = 0.0;
    
    self.imageView.image = [UIImage imageNamed:@"Square image.jpg"];
    
    self.manager = [[CMMotionManager alloc] init];
    if(self.manager.accelerometerAvailable){
        self.staticButton.enabled = YES;
        self.dynamicStartButton.enabled = YES;
        [self.manager startAccelerometerUpdates];
    } else {
        self.staticLabel.text = @"No Accelerometer Available";
        self.dynamicLabel.text = @"No Accelerometer Available";
    }
}

- (IBAction)staticRequest:(id)sender {
    CMAccelerometerData *aData = self.manager.accelerometerData;
    if(aData != nil){
        CMAcceleration acceleration = aData.acceleration;
        self.staticLabel.text = [NSString stringWithFormat:@"x:%f\ny:%f\nz:%f", acceleration.x, acceleration.y, acceleration.z];
    }
}

- (IBAction)dynamicStart:(id)sender {
    self.dynamicStartButton.enabled = NO;
    self.dynamicStopButton.enabled = YES;
    
    self.manager.accelerometerUpdateInterval = 0.1;
    
    ViewController * __weak weakSelf = self;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [self.manager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *data, NSError *error) {
        //do work here
        double x = data.acceleration.x;
        double y = data.acceleration.y;
        double z = data.acceleration.z;
        
        self.x = .9 * self.x + .1 * x;
        self.y = .9 * self.y + .1 * y;
        self.z = .9 * self.z + .1 * z;
        
        double rotation = -atan2(self.x, -self.y);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
           // update UI here
            
            weakSelf.imageView.transform = CGAffineTransformMakeRotation(rotation);
            
            weakSelf.dynamicLabel.text = [NSString stringWithFormat:@"rotation: %f\nx:%f\ny:%f\nz:%f", rotation, self.x, self.y, self.z];
        }];
    }];
    
}

- (IBAction)dynamicStop:(id)sender {
    [self.manager stopAccelerometerUpdates];
    self.dynamicStartButton.enabled = YES;
    self.dynamicStopButton.enabled = NO;
}



@end
