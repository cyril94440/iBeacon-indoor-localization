//
//  StepNotif.m
//  pedometer
//
//  Created by Thomas Theissier on 18/11/2013.
//  Copyright (c) 2013 Thomas Theissier. All rights reserved.
//

#import "StepNotif.h"
#define RANGE 0.1

@implementation StepNotif

+ (StepNotif *)sharedStepNotif
{
    static dispatch_once_t pred;
    static StepNotif *_stepNotif = nil;
    
    dispatch_once(&pred, ^{ _stepNotif = [[self alloc] init]; });
    return _stepNotif;
}

-(void)startMonitoring{
    _stepCount = 0;
    _timer = 0;
    motionManager = [[CMMotionManager alloc] init];
    motionManager.accelerometerUpdateInterval  = 1.0/10.0; // Update at 10Hz
    if (motionManager.accelerometerAvailable) {
        //NSLog(@"Accelerometer avaliable");
        queue = [NSOperationQueue currentQueue];
        [motionManager startAccelerometerUpdatesToQueue:queue
                                            withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                CMAcceleration acceleration = accelerometerData.acceleration;
                                                
                                                [self computeEWMA2:acceleration];
                                            }];
        
        
        
    }
}


-(void)computeEWMA2:(CMAcceleration) acceleration{
    
    _Yt2 = sqrtf(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z);
    
    float alpha = 0.1;//2/(_stepCount-1);
    _St2 = alpha * _Yt2 + (1 - alpha) * _St2;
    
    // SI Yt passe En haut et déjà passé en bas OU Inversement
    if( (_Yt2 > (_St2+RANGE) && _reachMin)){ //|| (_reachMax && _Yt2 < (_St2-RANGE))
        
         if(_delegate!=nil && [_delegate respondsToSelector:@selector(newStep2)])
             [self.delegate newStep2];
        
        _stepCount2++;
        _reachMax = NO;
        _reachMin = NO;
        _timer = 0;
    }
    else if (_Yt2 < (_St2-RANGE))// Si juste Passé en Bas
        _reachMin = YES;
    
    /*
    else if (_Yt2 > (_St2+RANGE))// Si juste Passé en Haut
        _reachMax = YES;
     */
    
    if(_reachMax || _reachMin)//Compte si extremum atteint, incr _timer;
        _timer++;
    if(_timer > 10){//Après N time, réinit _timer et _reachMax/Min
        _timer = 0;
        _reachMax = NO;
        _reachMin = NO;
    }
}

@end
