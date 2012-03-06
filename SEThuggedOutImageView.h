//
//  SEThuggedOutImageView.h
//  SEThuggedOutImageView
//
//  Created by eric mark mendelson and bryn austin bellomy on 2/1/12.
//  Copyright (c) 2012 signals.io» (signalenvelope LLC). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEDraggable.h"

typedef void (^ gesture_response_block)(UIGestureRecognizer *gestureRecognizer);

#define kVelocityMultiplier

@class MachTimer2, SEDraggable, SEDraggableLocation;

@interface SEThuggedOutImageView : UIImageView <UIGestureRecognizerDelegate> {
  UITapGestureRecognizer *_tap;
  UIPinchGestureRecognizer *_pinch;
  gesture_response_block __unsafe_unretained _tapGestureResponseBlock; //__weak _tapGestureResponseBlock;
  gesture_response_block __unsafe_unretained _pinchGestureResponseBlock; //__weak _pinchGestureResponseBlock;

  
    //accel
  CGPoint currentPoint;
	CGPoint previousPoint;
	
	UIAcceleration *acceleration;
	CGFloat ballXVelocity;
	CGFloat ballYVelocity;
  @private
    MachTimer2 *_machTimer;
}

@property (nonatomic, strong, readwrite) UITapGestureRecognizer *tap;
@property (nonatomic, strong, readwrite) UIPinchGestureRecognizer *pinch;
@property (nonatomic, unsafe_unretained, readwrite) gesture_response_block tapGestureResponseBlock;
@property (nonatomic, unsafe_unretained, readwrite) gesture_response_block pinchGestureResponseBlock;
  //accel
@property (nonatomic, strong) UIAcceleration *acceleration;
@property CGPoint currentPoint;
@property CGPoint previousPoint;
@property CGFloat ballXVelocity;
@property CGFloat ballYVelocity;

- (void) draw;
- (id) initWithFrame:(CGRect)frame andImages:(NSMutableArray *)images;
- (UInt32) getCurrentFrameIndex;
- (void) setTapGestureIsActive:(BOOL)active;
- (void) setTapGestureActiveSurface:(UIView *)view;
- (void) setPinchGestureIsActive:(BOOL)active;
- (void) setPinchGestureActiveSurface:(UIView *)view;

@end