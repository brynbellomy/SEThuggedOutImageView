//
//  SEThuggedOutImageView.m
//  SEThuggedOutImageView
//
//  Created by eric mark mendelson and bryn austin bellomy on 2/1/12.
//  Copyright (c) 2012 signals.io» (signalenvelope LLC). All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <math.h>
#import "Alexis.h"
#import "SEThuggedOutImageView.h"
#import "MachTimer2.h"
#import "SEDraggableLocation.h"

@implementation SEThuggedOutImageView

@synthesize tap = _tap;
@synthesize pinch = _pinch;
@synthesize pinchGestureResponseBlock = _pinchGestureResponseBlock;
@synthesize tapGestureResponseBlock = _tapGestureResponseBlock;
@synthesize currentPoint;
@synthesize previousPoint;
@synthesize acceleration;
@synthesize ballXVelocity;
@synthesize ballYVelocity;

- (id) initWithFrame:(CGRect)frame andImages:(NSMutableArray *)images {
  if (self = [super initWithFrame:frame]) {
    // accel
		ballXVelocity = 0.0f;
		ballYVelocity = 0.0f;
    
    _machTimer = [[MachTimer2 alloc] init];
    self.animationImages = images;
    self.animationDuration = 10;
    self.animationRepeatCount = 0;
    
    [self startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(imageInitializationDidComplete:)
                                   userInfo:nil
                                    repeats:NO];
    
    // add tap gesture
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    _tap.delegate = self;
      
    // add pinch gesture
    _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
    _pinch.delegate = self;
    
    [self addGestureRecognizer:_pinch];
    [self addGestureRecognizer:_tap];
    [self setUserInteractionEnabled:YES];
  }
  return self;
}

- (void) dealloc {
  self.tap.delegate = nil;
  self.pinch.delegate = nil;
}

- (void) setTapGestureIsActive:(BOOL)active {
  self.tap.enabled = active;
}

- (void) setTapGestureActiveSurface:(UIView *)view {
  if ([self.gestureRecognizers containsObject:self.tap])
    [self removeGestureRecognizer:self.tap];
  [view addGestureRecognizer:self.tap];
}

- (void) setPinchGestureIsActive:(BOOL)active {
  self.pinch.enabled = active;
}

- (void) setPinchGestureActiveSurface:(UIView *)view {
  if ([self.gestureRecognizers containsObject:self.pinch])
    [self removeGestureRecognizer:self.pinch];
  [view addGestureRecognizer:self.pinch];
}

- (void) imageInitializationDidComplete:(NSTimer *)theTimer {
  [self stopAnimating];
  self.alpha = 1.0f;
}

- (UInt32) getCurrentFrameIndex {
  Float64 seconds = [_machTimer elapsedSec];
  UInt32  frameNum = floor(seconds * ((UInt32)kNumTotalAlexisFrames / (Float32)kAlexisAnimationDurationInSeconds));
  frameNum = frameNum % kNumTotalAlexisFrames; // make sure we never exceed totalFrames
  return frameNum;
}

- (void) startAnimating {
  //if (self.isAnimating || self.animationImages == nil || self.animationImages.count <= 1)
  //  return;

  //self.image = nil;
  
  [_machTimer start];
  [super startAnimating];
}

- (void) stopAnimating {
  //if (!self.isAnimating || self.animationImages == nil || self.animationImages.count <= 1)
  //  return;
  
  UInt32 frameNum = [self getCurrentFrameIndex];
  
  UIImage *pausedImage = [self.animationImages objectAtIndex:frameNum];
  [super stopAnimating];
  self.image = pausedImage;
  
  NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:self.animationImages.count];
  int index = frameNum;
  for (int a = 0; a <= self.animationImages.count; a++, index++) {
    if (index >= self.animationImages.count)
      index = 0; // continue from beginning
    UIImage *tempImage = [self.animationImages objectAtIndex:index];
    [tempArray addObject:tempImage];
  }
  
  self.animationImages = tempArray;
  self.animationDuration = kAlexisAnimationDurationInSeconds;
  self.animationRepeatCount = 0;
}

- (void) tapped:(UIGestureRecognizer *)localTap {
  if (!self.isAnimating)
    [self startAnimating];
  else
    [self stopAnimating];
    
  if (self.tapGestureResponseBlock)
    self.tapGestureResponseBlock(localTap);
}

- (void) pinched:(UIPinchGestureRecognizer *)localPinch {
  self.transform = CGAffineTransformScale(self.transform,
                                          localPinch.scale,
                                          localPinch.scale);
  if (self.pinchGestureResponseBlock)
    self.pinchGestureResponseBlock(localPinch);
    
  localPinch.scale = 1;
}

- (void) drawRect:(CGRect)rect {
    // Drawing code
  [self.image drawAtPoint:currentPoint];
}

- (CGPoint) currentPoint {
  return currentPoint;
}

- (void) setCurrentPoint:(CGPoint)newPoint {
  previousPoint = currentPoint;
  currentPoint =  newPoint;
  
  if(currentPoint.x < 0){
    currentPoint.x = 0;
    ballXVelocity = 0;
  }
  
  if(currentPoint.y < 0){
    currentPoint.y = 0;
    ballYVelocity = 0;
  }
  
  
  if(currentPoint.x > self.bounds.size.width - self.image.size.width){
    currentPoint.x = self.bounds.size.width - self.image.size.width;
    ballXVelocity = 0;
  }
  
  if(currentPoint.y > self.bounds.size.width - self.image.size.width){
    currentPoint.y = self.bounds.size.width - self.image.size.width;
    ballYVelocity = 0;
  }
  
  CGRect currentImageRect = CGRectMake(currentPoint.x , currentPoint.y, 
                                       currentPoint.x + self.image.size.width,
                                       currentPoint.y + self.image.size.height);
  
  CGRect previousImageRect = CGRectMake(previousPoint.x , previousPoint.y, 
                                        previousPoint.x + self.image.size.width,
                                        previousPoint.y + self.image.size.height);
  [self setNeedsDisplayInRect:CGRectUnion(currentImageRect,previousImageRect)];
}


- (void) draw {
  static NSDate *lastDrawTime;
  
  if(lastDrawTime != nil){
    NSTimeInterval secondsSinceLastDraw = -([lastDrawTime timeIntervalSinceNow]);
    
    ballYVelocity = ballYVelocity + -(acceleration.y * secondsSinceLastDraw);
    ballXVelocity = ballXVelocity + acceleration.x * secondsSinceLastDraw;
    
    CGFloat xAcceleration = secondsSinceLastDraw * ballXVelocity * 500;
    CGFloat yAcceleration = secondsSinceLastDraw * ballYVelocity * 500;
    
    self.currentPoint = CGPointMake(self.currentPoint.x + xAcceleration,
                                    self.currentPoint.y +yAcceleration);
  }
  lastDrawTime = [[NSDate alloc] init];
}

@end
