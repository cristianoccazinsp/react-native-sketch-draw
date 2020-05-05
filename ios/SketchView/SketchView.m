#import "SketchView.h"
#import "PenSketchTool.h"
#import "EraserSketchTool.h"
#import "NSMutableArray+QueueStack.h"


@implementation SketchView
{
    SketchTool *currentTool;
    SketchTool *penTool;
    SketchTool *eraseTool;
    
    UIImage *incrementalImage;
    NSMutableArray *stack;
    NSInteger maxUndo;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initialize];
    return self;
}

- (void) initialize
{
    [self setMultipleTouchEnabled:NO];
    maxUndo = 10; // keep it small so we don't overflow our memory
    stack = [NSMutableArray array];
    penTool = [[PenSketchTool alloc] initWithTouchView:self];
    eraseTool = [[EraserSketchTool alloc] initWithTouchView:self];
    
    [self setToolType:SketchToolTypePen];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

-(void)setToolType:(SketchToolType) toolType
{
    switch (toolType) {
        case SketchToolTypePen:
            currentTool = penTool;
            break;
        case SketchToolTypeEraser:
            currentTool = eraseTool;
            break;
        default:
            currentTool = penTool;
            break;
    }
}

-(void)setMaxUndo:(NSInteger)max
{
    maxUndo = max;
    while([stack count] >= maxUndo){
        [stack queuePop];
    }
}

-(void)setToolColor:(UIColor *)rgba
{
    [(PenSketchTool *)penTool setToolColor:rgba];
}

-(void)setViewImage:(UIImage *)image
{
    if(incrementalImage != nil){
        // if stack full, remove oldest
        if([stack count] >= maxUndo){
            [stack queuePop];
        }
        
        [stack queuePush:incrementalImage];
    }
    incrementalImage = image;
    [self setNeedsDisplay];
}

-(void) clear
{
    incrementalImage = nil;
    [currentTool clear];
    [self setNeedsDisplay];
}

-(void) undo
{
    UIImage *prev = [stack stackPop];
    if(prev){
        incrementalImage = prev;
        [currentTool clear];
        [self setNeedsDisplay];
    }
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [incrementalImage drawInRect:rect];
    [currentTool render];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [currentTool touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [currentTool touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [currentTool touchesEnded:touches withEvent:event];
    [self takeSnapshot];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [currentTool touchesCancelled:touches withEvent:event];
    [self takeSnapshot];
}

-(void)takeSnapshot
{
    [self setViewImage:[self drawBitmap]];
    [currentTool clear];
}

-(UIImage *)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [self drawRect:self.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
