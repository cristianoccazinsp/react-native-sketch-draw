#include <math.h>
#import "ArrowTool.h"
#import "Paint.h"


#define POINTER_LINE_LENGTH (20)


@implementation ArrowTool{
    UIBezierPath *path;
    Paint *paint;
    CGPoint startPoint;
    BOOL moved;
}


-(instancetype)initWithTouchView:(UIView *)touchView
{
    self = [super initWithTouchView:touchView];

    path = [UIBezierPath bezierPath];
    paint = [[Paint alloc] init];
    moved = NO;

    [self setToolColor:[UIColor blackColor]];
    [self setToolThickness:5];

    [path setLineCapStyle:kCGLineCapRound];
    [path setLineJoinStyle:kCGLineJoinRound];

    return self;
}

// since we re-draw the path every time
// we need to update its settings
-(void)setPathSettings
{
    [path setLineWidth:paint.thickness];
    [path setLineCapStyle:kCGLineCapRound];
    [path setLineJoinStyle:kCGLineJoinRound];
}

-(void)render
{
    [paint.color setStroke];
    [path stroke];
}

-(void)setToolThickness:(CGFloat)thickness
{
    paint.thickness = thickness;
    [path setLineWidth:paint.thickness];
}

-(CGFloat)getToolThickness
{
    return paint.thickness;
}

-(void)setToolColor:(UIColor *)color
{
    paint.color = color;
}

-(UIColor *)getToolColor
{
    return paint.color;
}

-(void)clear
{
    moved = NO;
    [path removeAllPoints];
}

-(BOOL)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchView];
    startPoint = point;

    path = [UIBezierPath bezierPath];
    [self setPathSettings];
    moved = NO;
    
    return YES;
}

-(void)setPathRect:(CGPoint)point
{
    path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:point];

    double arrowAngle = M_PI / 4;
    double startEndAngle = atan((point.y - startPoint.y) / (point.x - startPoint.x)) + ((point.x - startPoint.x) < 0 ? M_PI : 0);

    CGPoint arrowLine1 = CGPointMake(point.x + POINTER_LINE_LENGTH * cos(M_PI - startEndAngle + arrowAngle), point.y - POINTER_LINE_LENGTH * sin(M_PI - startEndAngle + arrowAngle));

    CGPoint arrowLine2 = CGPointMake(point.x + POINTER_LINE_LENGTH * cos(M_PI - startEndAngle - arrowAngle), point.y - POINTER_LINE_LENGTH * sin(M_PI - startEndAngle - arrowAngle));

    [path addLineToPoint:arrowLine1];
    [path moveToPoint:point];
    [path addLineToPoint:arrowLine2];

    [self setPathSettings];
}

-(BOOL)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    moved = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchView];
    [self setPathRect:point];
    [self.touchView setNeedsDisplay];
    
    return YES;
}

-(BOOL)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchView];
    
    if(!moved){
        [self.touchView setNeedsDisplay];
        return NO;
    }
    
    [self setPathRect:point];
    [self.touchView setNeedsDisplay];
    return YES;
}

-(BOOL)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    return [self touchesEnded:touches withEvent:event];
}

@end
