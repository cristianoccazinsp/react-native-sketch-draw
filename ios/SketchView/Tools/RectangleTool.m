#import "RectangleTool.h"
#import "Paint.h"


@implementation RectangleTool{
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
    // we can use negative width/height and it works fine
    path = [UIBezierPath bezierPathWithRect:CGRectMake(startPoint.x, startPoint.y, point.x - startPoint.x, point.y - startPoint.y)];

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
