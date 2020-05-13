#import "SketchTool.h"

@implementation SketchTool

-(instancetype)initWithTouchView:(UIView *) touchView
{
    self = [super init];
    self.touchView = touchView;
    return self;
}

-(BOOL)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self doesNotRecognizeSelector:_cmd];
    
    return YES;
}

-(BOOL)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self doesNotRecognizeSelector:_cmd];
    
    return YES;
}

-(BOOL)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self doesNotRecognizeSelector:_cmd];

    return YES;
}

-(BOOL)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self doesNotRecognizeSelector:_cmd];

    return YES;
}

-(void)render
{
    [self doesNotRecognizeSelector:_cmd];
}

-(void)clear
{
    [self doesNotRecognizeSelector:_cmd];
}

-(BOOL)hasData
{
    return NO;
}

-(void)promptData
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
