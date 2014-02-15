//
//  ViewController.h
//  Loc
//
//  Created by Cyril Trosset on 15/10/2013.
//  Copyright (c) 2013 Cyril Trosset. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "circleView.h"
#import "ESTBeaconManager.h"
#import "StepNotif.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<ESTBeaconManagerDelegate,StepDelegate,CLLocationManagerDelegate>
{
    
    __weak IBOutlet UIImageView *_beacon1;
    __weak IBOutlet UIImageView *_beacon2;
    __weak IBOutlet UIImageView *_beacon3;
    
    __weak IBOutlet UIImageView *_dot;
    __weak IBOutlet UIImageView *_dotBackGround;
    
    float _x;
    float _y;
    
    __weak IBOutlet UIImageView *_perfect;
    float _scaleFactor;
    
    circleView *_circle1;
    circleView *_circle2;
    circleView *_circle3;
    
    ESTBeaconManager *_beaconManager;
    
    float _avD1;
    float _avD2;
    float _avD3;
    
    float _n;
    
    CLLocationManager *_manager;
    NSOperationQueue *_queue;
    
    double _heading;
    
    CGPoint _stepPoint;
    
    NSMutableArray *_pointsArray;
    
}


@end
