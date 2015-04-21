//
//  BalancerView.m
//  Test
//
//  Created by ice on 14/11/26.
//  Copyright (c) 2014年 ice. All rights reserved.
//

#import "BalancerView.h"
#import <QuartzCore/QuartzCore.h>
#import "YLAudioPlayer.h"
#import "PTTheme.h"

static const CGFloat kBarMinPeakHeight = 6.0;
static const CGFloat kBarMaxPeakHeight = 12.0;

static const CFTimeInterval kMinBaseOscillationPeriod = 0.6;
static const CFTimeInterval kMaxBaseOscillationPeriod = 0.8;

@interface BalancerView ()
{
    NSMutableArray *subLayerArray;
    BOOL isAnimation;
}
@property (nonatomic,strong) Music *music;
@end

@implementation BalancerView

+(BalancerView *)instanceView
{
    BalancerView *view = [[BalancerView alloc] initWithFrame:CGRectMake(0 , 0, 20, 20)];
    return view;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    subLayerArray = [[NSMutableArray alloc] init];
    self.backgroundColor = [UIColor clearColor];
    self.strokeColor = [[PTThemeManager sharedTheme] navTintColor];
    
    self.layer.masksToBounds = YES;
    self.userInteractionEnabled = YES;
    self.music = nil;
    [self addNotification];
}

-(void)addNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stop:) name:STOP_BALANCER_ANIMATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(start:) name:START_BALANCER_ANIMATION object:nil];
    [self showSelf];
}

-(void)stop:(NSNotification *)noti
{
    [self stopAnimation];
}
-(void)start:(NSNotification *)noti
{
    @autoreleasepool {
        if ([self isNavPlay])
        {
            [self startAnimation];
        }
        else
        {
            if ([self.music isEqual:[noti object]]) {
                [self startAnimation];
            }
            else
            {
                [self stopAnimation];
            }
        }
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
    [self initLayer];
}

-(void)setSomething:(Music *)music
{
    self.music = music;
    if (music)
    {
        [self showSelf];
    }
}

-(void)showSelf
{
    @autoreleasepool {
        if ([self.music isEqual:[[YLAudioPlayer sharedAudioPlayer] currentPlayMusic]] && [YLAudioPlayer sharedAudioPlayer].isPlaying) {
            self.hidden = NO;
            [self startAnimation];
        }
        else
        {
            if (![self isNavPlay]) {
                self.hidden = YES;
                [self stopAnimation];
            }
            else
            {
                if ([YLAudioPlayer sharedAudioPlayer].isPlaying) {
                    [self startAnimation];
                }
            }
        }
        
    }
}

-(void)initLayer
{
    for (CALayer *layer in subLayerArray)
    {
        [layer removeFromSuperlayer];
    }
    [subLayerArray removeAllObjects];
    
    CGFloat w = self.bounds.size.width / 7.0f;
    CGFloat h = self.bounds.size.height;
    
    for (int i = 0; i < 7; i++)
    {
        if (i%2 == 0)
        {
            CGFloat offset = 0.5;
            switch (i ) {
                case 0:
                    offset = 0.5;
                    break;
                case 2:
                    offset =1;
                    break;
                case 4:
                    offset = 0.75;
                    break;
                case 6:
                    offset = 0.25;
                    break;
                    
                default:
                    break;
            }
            CALayer *layer = [[CALayer alloc] init];
            [layer setBackgroundColor:_strokeColor.CGColor];
            layer.anchorPoint = CGPointMake(0.0, 1.0); // At the bottom-left corner
            layer.position = CGPointMake(i*w, h); // In superview's coordinate
            layer.bounds = CGRectMake(0.0, 0.0, w, h*offset);// In its own coordinate
            [self.layer addSublayer:layer];
            [subLayerArray addObject:layer];
            
        }
    }
}

-(BOOL)isNavPlay
{
    if (!self.music)
    {
        return YES;
    }
    return NO;
}

-(void)startAnimation
{
    self.hidden = NO;
    for (CALayer *layer in subLayerArray)
    {
        if (![layer animationForKey:@"BoundsAnimation"])
        {
            CFTimeInterval basePeriod = kMinBaseOscillationPeriod + (drand48() * (kMaxBaseOscillationPeriod - kMinBaseOscillationPeriod));
            [self boundsAnimation:layer animationTime:basePeriod];
        }
    }
}

-(void)stopAnimation
{
    for (CALayer *layer in subLayerArray)
    {
        if ([layer animationForKey:@"BoundsAnimation"])
        {
            [layer removeAnimationForKey:@"BoundsAnimation"];
        }
    }
    if (![self isNavPlay]) {
        self.hidden = YES;
    }
    else
    {
        [self initLayer];
    }

}

-(void)boundsAnimation:(CALayer *)layer animationTime:(CGFloat)time
{
    CGFloat peakHeight = kBarMinPeakHeight + arc4random_uniform(kBarMaxPeakHeight - kBarMinPeakHeight + 1);
    
    CGRect toBounds = layer.bounds;
    toBounds.size.height = peakHeight;
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.fromValue = [NSValue valueWithCGRect:layer.bounds];
    CGRect toRect = layer.bounds;
    toRect.size.height = peakHeight;
    animation.toValue = [NSValue valueWithCGRect:toRect];
    animation.repeatCount = HUGE_VALF; // Forever
    animation.autoreverses = YES;
    animation.duration = (time / 2) * (kBarMaxPeakHeight / peakHeight);;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [layer addAnimation:animation forKey:@"BoundsAnimation"];
}

-(void)boundsAnimation:(CALayer *)layer
{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.fromValue = [NSValue valueWithCGRect:layer.bounds];
    CGRect toRect = layer.bounds;
    if (layer.bounds.size.height == self.bounds.size.height) {
        toRect.size.height = self.bounds.size.height/2;
    }
    else if (layer.bounds.size.height == self.bounds.size.height/2) {
        toRect.size.height = self.bounds.size.height*0.75;
    }
    else if (layer.bounds.size.height == self.bounds.size.height*0.25) {
        toRect.size.height = self.bounds.size.height/2;
    }
    else if (layer.bounds.size.height == self.bounds.size.height*0.75) {
        toRect.size.height = self.bounds.size.height/2;
    }
    animation.toValue = [NSValue valueWithCGRect:toRect];
    animation.repeatCount = HUGE_VALF; // Forever
    animation.autoreverses = YES;
    animation.duration = 0.6;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [layer addAnimation:animation forKey:@"BoundsAnimation"];
}

@end
