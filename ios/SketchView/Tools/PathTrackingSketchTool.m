#import "PathTrackingSketchTool.h"

@implementation PathTrackingSketchTool

-(instancetype)initWithTouchView:(UIView *)touchView
{
    self = [super initWithTouchView:touchView];
    self.path = [UIBezierPath bezierPath];
    return self;
}

-(void)clear
{
    [_path removeAllPoints];
}

-(BOOL)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchView];
    [_path moveToPoint:point];
    
    return YES;
}

-(BOOL)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchView];
    [_path addLineToPoint:point];
    [self.touchView setNeedsDisplay];
    
    return YES;
}

-(BOOL)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchView];
    [_path addLineToPoint:point];
    [self.touchView setNeedsDisplay];

    return YES;
}

-(BOOL)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    return [self touchesEnded:touches withEvent:event];
}

@end
