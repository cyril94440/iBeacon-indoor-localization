//
//  ViewController.m
//  Loc
//
//  Created by Cyril Trosset on 15/10/2013.
//  Copyright (c) 2013 Cyril Trosset. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "circleView.h"

/* Display & calcul adjustments */
#define COEFSTEP 0.7
#define DELTA_Y 200


/* CONFIGURE THIS PART */
#define STEP 0.5
#define _d 7.26
#define _i 3.71856
#define _j 3.9

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _n = 0;
    
    
    // Place the beacons at the right place
    _scaleFactor = ([UIScreen mainScreen].bounds.size.width) / _d;
    
    CGRect frame = _beacon1.frame;
    frame.origin.y += DELTA_Y;
    _beacon1.frame = frame;
    
    frame = _beacon2.frame;
    frame.origin.x = (_d*_scaleFactor)-(frame.size.width/2);
    frame.origin.y += DELTA_Y;
    _beacon2.frame = frame;
    
    frame = _beacon3.frame;
    frame.origin.x = (_i*_scaleFactor)-(frame.size.width/2);
    frame.origin.y = (_j*_scaleFactor)-(frame.size.height/2);
    frame.origin.y += DELTA_Y;
    _beacon3.frame = frame;
    
    _manager = [CLLocationManager new];
    _manager.delegate = self;
    [_manager startUpdatingHeading];
    
    _stepPoint = CGPointMake(0, 0);
    
    // Step detection
    [StepNotif sharedStepNotif].delegate = self;
    [[StepNotif sharedStepNotif] startMonitoring];
    
    
    // Beacons monitoring
    _beaconManager = [[ESTBeaconManager alloc] init];
    _beaconManager.delegate = self;
    _beaconManager.avoidUnknownStateBeacons = YES;
    
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initRegionWithIdentifier:@"EstimoteSampleRegion"];
    [region peripheralDataWithMeasuredPower:@(-64)];
    
    [_beaconManager startRangingBeaconsInRegion:region];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if([beacons count] >= 3)
    {
        float d1,d2,d3;
        
        for(ESTBeacon *beacon in beacons)
        {
            if(beacon.ibeacon.minor.integerValue == 3)
                d1 = beacon.ibeacon.accuracy;
            else if(beacon.ibeacon.minor.integerValue == 2)
                d2 = beacon.ibeacon.accuracy;
            else if(beacon.ibeacon.minor.integerValue == 1)
                d3 = beacon.ibeacon.accuracy;
        }
        
        if(_n++==0)
        {
            _avD1=d1;_avD2=d2;_avD3=d3;
        }
        else
        {
            float alpha = 0.4;
            _avD1 = (d1*alpha) + ((1-alpha)*_avD1);
            _avD2 = (d2*alpha) + ((1-alpha)*_avD2);
            _avD3 = (d3*alpha) + ((1-alpha)*_avD3);
            
        }
        
        [self reDrawWithNewDistances:d1 andDistance:d2 andDistance:d3];
        [self reDrawBackGroundPoint:[self calculateCoordonateWithDistance:d1 andDistance:d2 andDistance:d3]];
        
        CGPoint point = [self calculateCoordonateWithDistance:_avD1 andDistance:_avD2 andDistance:_avD3];
        [self reDrawPoint:point];
    }
}

-(void)reDrawWithNewDistances:(float)beaconD1 andDistance:(float)beaconD2 andDistance:(float)beaconD3
{
    
    [_circle1 removeFromSuperview];
    _circle1 = [[circleView alloc] initWithFrame:CGRectMake(-beaconD1*_scaleFactor, -beaconD1*_scaleFactor+DELTA_Y, beaconD1*2*_scaleFactor, beaconD1*2*_scaleFactor)];
    _circle1.color = [UIColor redColor];
    [self.view addSubview:_circle1];
    
    [_circle2 removeFromSuperview];
    _circle2 = [[circleView alloc] initWithFrame:CGRectMake((_beacon2.frame.origin.x+_beacon2.frame.size.width/2)-beaconD2*_scaleFactor, (_beacon2.frame.origin.y+_beacon2.frame.size.height/2)-beaconD2*_scaleFactor, beaconD2*2*_scaleFactor, beaconD2*2*_scaleFactor)];
    _circle2.color = [UIColor blueColor];
    [self.view addSubview:_circle2];
    
    [_circle3 removeFromSuperview];
    _circle3 = [[circleView alloc] initWithFrame:CGRectMake((_beacon3.frame.origin.x+_beacon3.frame.size.width/2)-beaconD3*_scaleFactor, (_beacon3.frame.origin.y+_beacon3.frame.size.height/2)-beaconD3*_scaleFactor, beaconD3*2*_scaleFactor, beaconD3*2*_scaleFactor)];
    _circle3.color = [UIColor greenColor];
    [self.view addSubview:_circle3];
}
-(void)reDrawPoint:(CGPoint)point
{
    CGPoint drawPoint = point;
    
    if(!(_stepPoint.x == 0 && _stepPoint.y == 0))
    {
        drawPoint.x = ((float)_stepPoint.x * COEFSTEP) + ((float)point.x * (1-COEFSTEP));
        drawPoint.y = ((float)_stepPoint.y * COEFSTEP) + ((float)point.y * (1-COEFSTEP));
    }
    
    _x = drawPoint.x;
    _y = drawPoint.y;
    
    UIImageView *newDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BLACK_DOT.gif"]];
    
    CGRect frame;
    frame = _dot.frame;
    frame.origin.x = (drawPoint.x*_scaleFactor)-(frame.size.width/2);
    frame.origin.y = (drawPoint.y*_scaleFactor)-(frame.size.height/2)+DELTA_Y;
    newDot.frame = frame;
    
    frame = _perfect.frame;
    frame.origin.x = 3.801*_scaleFactor;
    frame.origin.y = 0.64*_scaleFactor+DELTA_Y;
    _perfect.frame = frame;
    
    if(_pointsArray==nil)
        _pointsArray = [NSMutableArray new];
    
    //NSLog(@"%lf\t%lf",3.721-_x,1.905-_y);
    //printf("%f\t%f\n",_x,_y);
    
    [_pointsArray addObject:newDot];
    
    [self.view addSubview:newDot];
    
    [self performSelector:@selector(goThroughArray) withObject:nil afterDelay:0];
}
-(void)goThroughArray
{
    float opacity = 1;
    int j=0;
    for(long i=[_pointsArray count]-1;i>=0;i--)
    {
        UIImageView *view = _pointsArray[i];
        if(j==0){
            view.image = [UIImage imageNamed:@"rsz_red-dot-md.png"];
            j++;
        }
        else if(j==1)
        {
            view.image = [UIImage imageNamed:@"rsz_black_dot.png"];
            j++;
        }
        view.alpha = opacity;
        
        if(opacity>0)
            opacity-=0.05;
        
        if(opacity==0)
            [view removeFromSuperview];
    }
}
-(void)reDrawBackGroundPoint:(CGPoint)point
{
    CGRect frame;
    frame = _dotBackGround.frame;
    frame.origin.x = (point.x*_scaleFactor)-(frame.size.width/2);
    frame.origin.y = (point.y*_scaleFactor)-(frame.size.height/2)+DELTA_Y;
    _dotBackGround.frame = frame;
}
#pragma mark - StepDelegate
-(void)newStep2
{
    //NSLog(@"HEADING : %f",_heading);
    
    
    float deltaX = STEP * sin(_heading * M_PI / 180);
    float deltaY = STEP * cos(_heading * M_PI / 180);
    
    //NSLog(@"DELTA X : %lf",deltaX);
    //NSLog(@"DELTA Y : %lf",-deltaY);
    
    _stepPoint.x = _x + deltaX;
    _stepPoint.y = _y - deltaY;
    
    _n = 0;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,500,800)];
    view.backgroundColor = [UIColor redColor];
    view.alpha = 0.4;
    [self.view addSubview:view];
    
    [UIView animateWithDuration:0.4 animations:^{
        view.alpha = 0;
    }completion:^(BOOL finished){
        [view removeFromSuperview];
    }];
}
-(CGPoint)calculateCoordonateWithDistance:(float)r1 andDistance:(float)r2 andDistance:(float)r3
{
    float x = ((r1*r1)-(r2*r2)+(_d*_d))/(2*_d);
    float y = (((r1*r1)-(r3*r3)+(_i*_i)+(_j*_j))/(2*_j))-((_i/_j)*x);
    //float z = sqrt(((r1*r1)-(x*x)+(y*y)));
    
    CGPoint point = CGPointMake(x, y);
    
    return point;
}
#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    _heading = newHeading.trueHeading;
}
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager{
    return YES;
}

@end
