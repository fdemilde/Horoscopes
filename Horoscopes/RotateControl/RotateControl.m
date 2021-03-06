//
//  RotateControl.m
//  FCSHoroscope
//
//  Created by Danh Nguyen on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RotateControl.h"
#import "SMCLove.h"
#import <QuartzCore/QuartzCore.h>
#define DEGREES_TO_RADIANS(x) (x*3.141593)/180
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (SCREEN_MAX_LENGTH == 736.0)

#define UNHIGHLIGHT_IMAGE_COLOR [UIColor colorWithRed:133.0/255.0 green:124.0/255.0 blue:173.0/255.0 alpha:1]

static float deltaAngle;
static int CLOVER_IMAGE_TAG = 100;
static int CLOVER_SYMBOL_TAG = 101;

@interface RotateControl()
@property (nonatomic) BOOL isRotatingWheel;
@property (nonatomic, strong) NSThread *thread;
- (void)drawWheel;
- (float) calculateDistanceFromCenter:(CGPoint)point;
- (void) buildClovesEven;
- (void) buildClovesOdd;
- (UIImageView *) getCloveByValue:(int)value;
- (Horoscope *) getCloveName:(int)position;
- (void)unhighlightAllSigns;
- (void)highlightSelectedSign;
-(void) playRotationAnimation:(NSNumber*) _initialVelocity;
@end

@implementation RotateControl
@synthesize isRotatingWheel = _isRotatingWheel;
@synthesize delegate, container, numberOfSections, startTransform, cloves, currentValue;
@synthesize horoscopeSigns = _horoscopeSigns;
@synthesize thread = _thread;


- (id) initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)sectionsNumber andArray:(NSMutableArray*)horoscopes andCurrentSign: (NSString *)sign{
    
    if ((self = [super initWithFrame:frame])) {
		self.delegate = del;
        self.numberOfSections = sectionsNumber;
        self.horoscopeSigns = horoscopes;
        self.currentValue = [self getValueBySignName:(sign)];
        [self drawWheel];
        
        
	}
    return self;
}

- (void) drawWheel {
    container = [[UIView alloc] initWithFrame:self.frame];
    CGFloat angleSize = 2*M_PI/numberOfSections;
    for (int i = 0; i < numberOfSections; i++) {
        //get the sign
        Horoscope *horoscope = [self.horoscopeSigns objectAtIndex:i];
        UIImageView *im = [[UIImageView alloc] init];
        im.backgroundColor = [UIColor blueColor];
        im.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        im.layer.position = CGPointMake(container.bounds.size.width/2.0, container.bounds.size.height/2.0); 

        
        im.transform = CGAffineTransformMakeRotation(angleSize*i);
        // TODO: Binh changed, remove alpha
//        im.alpha = minAlphavalue;
        im.tag = i;
        
        // Frame is hardcode for 568h screen, now calculate for each screen size
        // (130, 60, 60, 60)
        int clovePosX = [self getPositionXBaseOnScreen:133];
        int clovePosY = [self getPositionYBaseOnScreen:60];
        UIImageView *cloveImage = [[UIImageView alloc] initWithFrame:CGRectMake(clovePosX, clovePosY, 60, 60)];
        cloveImage.image = [[horoscope getIcon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cloveImage.tintColor = UNHIGHLIGHT_IMAGE_COLOR;
        cloveImage.contentMode = UIViewContentModeCenter;
        cloveImage.transform = CGAffineTransformMakeRotation(120*M_PI/180);
        cloveImage.tag = CLOVER_IMAGE_TAG;
        [im addSubview:cloveImage];
        // (66, 33, 30, 30)
        int symbolPosX = [self getPositionXBaseOnScreen:80];
        int symbolPosY = [self getPositionYBaseOnScreen:33];
        if(IS_IPHONE_6){
            symbolPosX = [self getPositionXBaseOnScreen:78];
            symbolPosY = [self getPositionYBaseOnScreen:33];
        }
        UIImageView *symbol = [[UIImageView alloc] initWithFrame:CGRectMake(symbolPosX, symbolPosY, 30, 30)];
        symbol.image = [[horoscope getSymbol] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        symbol.tintColor = UNHIGHLIGHT_IMAGE_COLOR;
        symbol.transform = CGAffineTransformMakeRotation(120*M_PI/180);
        symbol.tag = CLOVER_SYMBOL_TAG;
        symbol.contentMode = UIViewContentModeCenter;
        
        [im addSubview:symbol];
        // when create wheel, highlight default selected sign
        if (i == currentValue) {
//            cloveImage.image = [horoscope getIconSelected];
//            symbol.image = [horoscope getSymbolSelected];
            cloveImage.tintColor = [UIColor whiteColor];
            symbol.tintColor = [UIColor whiteColor];
        }
        
        [container addSubview:im];
    }
    
    container.userInteractionEnabled = NO;
    [self addSubview:container];
        
    cloves = [NSMutableArray arrayWithCapacity:numberOfSections];
    
    if (numberOfSections % 2 == 0) {
        
        [self buildClovesEven];
        
    } else {
        
        [self buildClovesOdd];
        
    }
    
    [self.delegate wheelDidChangeValue:[self getCloveName:currentValue] becauseOf:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
    //[pan setCancelsTouchesInView:NO];
}

- (double)lengthFrom:(CGPoint)pointA toPoint:(CGPoint)pointB
{
    double dx = pointA.x - pointB.x;
    double dy = pointA.y - pointB.y;
    return sqrt(dx*dx + dy*dy);
}

#pragma mark - Handle gestures

- (void)handleTap:(UITapGestureRecognizer*)recognizer
{
    CGPoint touchPoint = [recognizer locationInView:self];
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        if(self.isRotatingWheel)//if the wheel is rotating, then we stop it
        {
            self.isRotatingWheel = NO;
            return;
        }
        //otherwise
        CGPoint p1 = CGPointMake(container.center.x, 0);
        int selected = [self lengthFrom:p1 toPoint:touchPoint] / [self getHoroscopeSignArea];
        
        if(selected >= 1 && fabs(p1.x-touchPoint.x) > ([self getHoroscopeSignArea] / 2)) //if we touch on the sign
        {
            [self unhighlightSelectedSign];
            if(touchPoint.x > p1.x) //touch on the right
            {
                currentValue = (currentValue + selected) % 12;
                selected *= -1;
            }
            else 
            {
                currentValue -= selected;
                if(currentValue < 0) currentValue += 12;
            }
            //do the animation
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            CGAffineTransform t = CGAffineTransformRotate(container.transform, selected*M_PI/6);
            container.transform = t;
            [UIView commitAnimations];
            //set alpha to make it focus
            [self highlightSelectedSign];
            //notify the delegate
            [self.delegate wheelDidChangeValue:[self getCloveName:currentValue] becauseOf:NO];
        }
        else //user selected the sign => save and go back
        {
            
            [self.delegate doneSelectedSign];
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer*)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [recognizer velocityInView:self];
        
//        DebugLog(@"SELECTED:%f,%f",velocity.x,velocity.y);
        
        CGFloat radians = atan2f(container.transform.b, container.transform.a);
        CGFloat newVal = 0.0;
        for (SMClove *c in cloves) {
            if (c.minValue > 0 && c.maxValue < 0) { // anomalous case
                if (c.maxValue > radians || c.minValue < radians) {
                    if (radians > 0) { // we are in the positive quadrant
                        newVal = radians - M_PI;
                    } else { // we are in the negative one
                        newVal = M_PI + radians;                    
                    }
                    currentValue = c.value;
                }
            }
            else if (radians > c.minValue && radians < c.maxValue) {
                newVal = radians - c.midValue;
                currentValue = c.value;
            }
        }
        
        if(fabs(velocity.x) > 1200) //do the rotate animation
        {
            container.transform = CGAffineTransformRotate(container.transform, -newVal);
            
            //unhighlight all icons
            [self unhighlightAllSigns];
            [self.delegate wheelDidChangeValue:nil becauseOf:NO];
            //do the animation
            self.isRotatingWheel = YES;//flag
//            [self.thread start];
            float modified_velocity= velocity.x;
            if(modified_velocity>1200){modified_velocity= 150;}
            if(modified_velocity<-1200){modified_velocity= -150;}
            
            
            [NSThread detachNewThreadSelector:@selector(playRotationAnimation:) toTarget:self withObject:[NSNumber numberWithDouble:modified_velocity]];
        } else {
            currentValue = (currentValue + 8) % 12;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            CGAffineTransform t = CGAffineTransformRotate(container.transform, -newVal);
            container.transform = t;
            [UIView commitAnimations];
            [self highlightSelectedSign];
            [self.delegate wheelDidChangeValue:[self getCloveName:currentValue] becauseOf:NO];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) //dragging
    {
        CGPoint pt = [recognizer locationInView:self];
        float dx = pt.x  - container.center.x;
        float dy = pt.y  - container.center.y;
        float ang = atan2(dy,dx);
        float angleDifference = deltaAngle - ang;
        container.transform = CGAffineTransformRotate(startTransform, -angleDifference);
        [self unhighlightAllSigns];
        CGFloat radians = atan2f(container.transform.b, container.transform.a);
        CGFloat newVal = 0.0;
        for (SMClove *c in cloves) {
            if (c.minValue > 0 && c.maxValue < 0) { // anomalous case
                if (c.maxValue > radians || c.minValue < radians) {
                    if (radians > 0) { // we are in the positive quadrant
                        newVal = radians - M_PI;
                    } else { // we are in the negative one
                        newVal = M_PI + radians;                    
                    }
                    currentValue = c.value;
                }
            }
            else if (radians > c.minValue && radians < c.maxValue) {
                newVal = radians - c.midValue;
                currentValue = c.value;
            }
        }
        currentValue = (currentValue + 8) % 12;
        [self highlightSelectedSign];
    }
    else if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        if(self.isRotatingWheel)//if the wheel is rotating, then we stop it
        {
            self.isRotatingWheel = NO;
            return;
        }
        [self unhighlightAllSigns];
        CGPoint touchPoint = [recognizer locationInView:self];
        float dx = touchPoint.x - container.center.x;
        float dy = touchPoint.y - container.center.y;
        deltaAngle = atan2(dy,dx); 
        startTransform = container.transform;            
    }
}

- (void)playRotationAnimation:(NSNumber*) _initialVelocity{
    

//    double currentVelocity = fabs([_initialVelocity doubleValue])/10/3;
    double currentVelocity = 0.5;
    // we random decelerationFactor so everytime we spin the wheel will give different result
//    float decelerationFactor= [self randFloatBetween:0.025 and:0.008] ; //change this to determine how fast the wheel will slow down , default 0.015,
    while (currentVelocity > 0.0023 && self.isRotatingWheel) {
        currentVelocity *= 0.9972;
        
        double netRotation = currentVelocity;
        if([_initialVelocity doubleValue] < 0) netRotation *= -1;
		NSNumber *_rotation = [NSNumber numberWithFloat:((netRotation * M_PI) / 180)];
		[self performSelectorOnMainThread:@selector(rotateWheelView:) withObject:_rotation waitUntilDone:YES];
		[NSThread sleepForTimeInterval:1/60];
    }
    [self performSelectorOnMainThread:@selector(animationStopped) withObject:nil waitUntilDone:YES];

}

- (void)rotateWheelView:(NSNumber *)_rotation {
	double rotation = [_rotation doubleValue];
    if(fabs(rotation)>=0.2 && fabs(rotation)<1.3) rotation*=-1;
	container.transform = CGAffineTransformRotate(container.transform, rotation);
}

- (void)animationStopped{
    self.isRotatingWheel = NO;
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    CGFloat newVal = 0.0;
    for (SMClove *c in cloves) {
        if (c.minValue > 0 && c.maxValue < 0) { // anomalous case
            if (c.maxValue > radians || c.minValue < radians) {
                if (radians > 0) { // we are in the positive quadrant
                    newVal = radians - M_PI;
                } else { // we are in the negative one
                    newVal = M_PI + radians;                    
                }
                currentValue = c.value;
            }
        }
        else if (radians > c.minValue && radians < c.maxValue) {
            newVal = radians - c.midValue;
            currentValue = c.value;
        }
    }
    currentValue = (currentValue + 8) % 12;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    container.transform = CGAffineTransformRotate(container.transform, -newVal);
    [UIView commitAnimations];
    [self highlightSelectedSign];
    [self.delegate wheelDidChangeValue:[self getCloveName:currentValue] becauseOf:NO];

}

-(void) autoRollToSign:(NSString*)_sign{
    [self unhighlightSelectedSign];
    int index = [self getValueBySignName:(_sign)];
    int selectedChange = currentValue - index;
    currentValue = index;
    //do the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    CGAffineTransform t = CGAffineTransformRotate(container.transform, selectedChange*M_PI/6);
    container.transform = t;
    [UIView commitAnimations];
    //set alpha to make it focus
    [self highlightSelectedSign];
    //notify the delegate
    [self.delegate wheelDidChangeValue:[self getCloveName:currentValue] becauseOf:YES];
}


#pragma mark - Helper methods

- (void)unhighlightAllSigns
{
    for (int i=0; i<12; i++) {
//        Horoscope *horoscope = [self.horoscopeSigns objectAtIndex:i];
        UIImageView *im = [self getCloveByValue:i];
        UIImageView *signImage = (UIImageView*)[im viewWithTag:CLOVER_IMAGE_TAG];
//        signImage.image = [horoscope getIcon];
        signImage.tintColor = UNHIGHLIGHT_IMAGE_COLOR;
        
        UIImageView *iconImage = (UIImageView*)[im viewWithTag:CLOVER_SYMBOL_TAG];
//        iconImage.image = [horoscope getSymbol];
        iconImage.tintColor = UNHIGHLIGHT_IMAGE_COLOR;
        
    }
}

- (void)unhighlightSelectedSign
{
//    Horoscope *horoscope = [self.horoscopeSigns objectAtIndex:currentValue];
    UIImageView *im = [self getCloveByValue:currentValue];
    
    UIImageView *signImage = (UIImageView*)[im viewWithTag:CLOVER_IMAGE_TAG];
    signImage.tintColor = UNHIGHLIGHT_IMAGE_COLOR;
    
    UIImageView *iconImage = (UIImageView*)[im viewWithTag:CLOVER_SYMBOL_TAG];
    iconImage.tintColor = UNHIGHLIGHT_IMAGE_COLOR;
}

- (void)highlightSelectedSign
{
//    NSLog(@"highlightSelectedSign highlightSelectedSign");
    UIImageView *im = [self getCloveByValue:currentValue];
    
    UIImageView *signImage = (UIImageView*)[im viewWithTag:CLOVER_IMAGE_TAG];
    signImage.tintColor = [UIColor whiteColor];
    
    UIImageView *iconImage = (UIImageView*)[im viewWithTag:CLOVER_SYMBOL_TAG];
    iconImage.tintColor = [UIColor whiteColor];
}

- (UIImageView *) getCloveByValue:(int)value {
    
    UIImageView *res;
    
    NSArray *views = [container subviews];
    
    for (UIImageView *im in views) {
        
        if (im.tag == value)
            res = im;
        
    }
    
    return res;
    
}

- (void) buildClovesEven {
    
    CGFloat fanWidth = M_PI*2/numberOfSections;
    CGFloat mid = 0;
    
    for (int i = 0; i < numberOfSections; i++) {
        
        SMClove *clove = [[SMClove alloc] init];
        clove.midValue = mid;
        clove.minValue = mid - (fanWidth/2);
        clove.maxValue = mid + (fanWidth/2);
        clove.value = i;
        
        
        if (clove.maxValue-fanWidth < - M_PI) {
            
            mid = M_PI;
            clove.midValue = mid;
            clove.minValue = fabsf(clove.maxValue);
            
        }
        
        mid -= fanWidth;
        
        
//        DebugLog(@"cl is %@", clove);
        
        [cloves addObject:clove];
        
    }
    
}

- (void) buildClovesOdd {
    
    CGFloat fanWidth = M_PI*2/numberOfSections;
    CGFloat mid = 0;
    
    for (int i = 0; i < numberOfSections; i++) {
        
        SMClove *clove = [[SMClove alloc] init];
        clove.midValue = mid;
        clove.minValue = mid - (fanWidth/2);
        clove.maxValue = mid + (fanWidth/2);
        clove.value = i;
        
        mid -= fanWidth;
        
        if (clove.minValue < - M_PI) {
            
            mid = -mid;
            mid -= fanWidth; 
            
        }
        
        
        [cloves addObject:clove];
        
//        DebugLog(@"cl is %@", clove);
        
    }
    
}

- (float)calculateDistanceFromCenter:(CGPoint)point {
    
    CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
	float dx = point.x - center.x;
	float dy = point.y - center.y;
	return sqrt(dx*dx + dy*dy);
    
}

- (Horoscope *) getCloveName:(int)position {
    Horoscope *selected = [self.horoscopeSigns objectAtIndex:position];
    return selected;
}

-(float) randFloatBetween:(float)low and:(float)high
{
    float diff = high - low;
    return (((float) rand() / RAND_MAX) * diff) + low;
}

- (float)getPositionYBaseOnScreen:(int)pos568h{
    float percent = [[UIScreen mainScreen] bounds].size.height / 568;
    float result = pos568h * percent;
    if(percent != 1) { result += 10; }
    return result;
}

- (float)getPositionXBaseOnScreen:(int)pos568h{
    return pos568h * ([[UIScreen mainScreen] bounds].size.width/320);
}

- (float)getHoroscopeSignArea{
    // because 4 sign will be displayed at the same time
    float result = [[UIScreen mainScreen] bounds].size.width / 4;
    return result;
}

- (int)getValueBySignName:(NSString *)sign{
    int index = 0;
    for (int i = 0; i < _horoscopeSigns.count; i++){
        Horoscope* horo = _horoscopeSigns[i];
        if([horo.sign compare:sign] == 0){
            index = i;
        }
    }
    return index;
    
}
@end
