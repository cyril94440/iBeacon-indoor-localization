//
//  StepNotif.h
//  pedometer
//
//  Created by Thomas Theissier on 18/11/2013.
//  Copyright (c) 2013 Thomas Theissier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@protocol StepDelegate;

@interface StepNotif : NSObject{
    
    CMMotionManager *motionManager;
    NSOperationQueue *queue;
}


+ (StepNotif*)sharedStepNotif;

@property(nonatomic,assign) id<StepDelegate> delegate;

@property int stepCount;
@property float St;
@property float Yt;

@property float St2;
@property float Yt2;
@property int stepCount2;

@property BOOL reachMax;
@property BOOL reachMin;
@property int timer;

-(void)startMonitoring;
-(void)computeEWMA2:(CMAcceleration) acceleration;

@end

@protocol StepDelegate <NSObject>
@optional

-(void)newStep;
-(void)newStep2;

@end