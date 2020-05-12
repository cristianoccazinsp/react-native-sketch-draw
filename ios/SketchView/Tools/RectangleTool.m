//
//  PathTrackingSketchTool.m
//  Sketch
//
//  Created by Keshav on 08/04/17.
//  Copyright © 2017 Particle41. All rights reserved.
//

#import "RectangleTool.h"
#import "Paint.h"


@implementation RectangleTool{
    UIBezierPath *path;
    Paint *paint;
    CGPoint startPoint;
}


-(instancetype)initWithTouchView:(UIView *)touchView
{
    self = [super initWithTouchView:touchView];
    
    path = [UIBezierPath bezierPath];
    paint = [[Paint alloc] init];
    
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
    [path removeAllPoints];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchView];
    startPoint = point;
    
    // use some min width/height for clarity
    path = [UIBezierPath bezierPathWithRect:CGRectMake(startPoint.x, startPoint.y, 10, 10)];
    
    [self setPathSettings];
    [self.touchView setNeedsDisplay];
}

-(void)setPathRect:(CGPoint)point
{
    // we can use negative width/height and it works fine
    path = [UIBezierPath bezierPathWithRect:CGRectMake(startPoint.x, startPoint.y, point.x - startPoint.x, point.y - startPoint.y)];
    
    [self setPathSettings];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1)
    {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.touchView];
        [self setPathRect:point];
        [self.touchView setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchView];
    [self setPathRect:point];
    [self.touchView setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

@end
