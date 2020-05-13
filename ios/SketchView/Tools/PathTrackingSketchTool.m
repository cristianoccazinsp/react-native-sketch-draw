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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchView];
    [_path moveToPoint:point];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchView];
    [_path addLineToPoint:point];
    [self.touchView setNeedsDisplay];
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
    [self touchesEnded:touches withEvent:event];

    return YES;
}

@end
