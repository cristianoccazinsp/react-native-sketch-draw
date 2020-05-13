#import "SketchView.h"
#import "PenSketchTool.h"
#import "EraserSketchTool.h"
#import "RectangleTool.h"
#import "ArrowTool.h"
#import "TextTool.h"
#import "NSMutableArray+QueueStack.h"
#import "SketchViewContainer.h"


@implementation SketchView
{
    SketchTool *currentTool;
    PenSketchTool *penTool;
    EraserSketchTool *eraseTool;
    RectangleTool *rectangleTool;
    ArrowTool *arrowTool;
    TextTool *textTool;
    
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
    rectangleTool = [[RectangleTool alloc] initWithTouchView:self];
    arrowTool = [[ArrowTool alloc] initWithTouchView:self];
    textTool = [[TextTool alloc] initWithTouchView:self];
    
    [self setToolType:SketchToolTypePen];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

-(void)setToolType:(SketchToolType) toolType
{
    if(currentTool){
        [currentTool clear];
        [self setNeedsDisplay];
    }
    
    switch (toolType) {
        case SketchToolTypePen:
            currentTool = penTool;
            break;
        case SketchToolTypeEraser:
            currentTool = eraseTool;
            break;
        case SketchToolTypeRectangle:
            currentTool = rectangleTool;
            break;
        case SketchToolTypeArrow:
            currentTool = arrowTool;
            break;
        case SketchToolTypeText:
            currentTool = textTool;
            break;
        default:
            currentTool = penTool;
            break;
    }
}

-(void)setMaxUndo:(NSInteger)max
{
    maxUndo = max;
    NSUInteger initialSize = [stack count];
    while([stack count] >= maxUndo){
        [stack queuePop];
    }
    
    if(initialSize != [stack count]){
        [self onDrawSketch];
    }
}

// keep pen tool as the source of truth
// but set all that might need use color
-(void)setToolColor:(UIColor *)rgba
{
    [penTool setToolColor:rgba];
    [rectangleTool setToolColor:rgba];
    [arrowTool setToolColor:rgba];
    [textTool setToolColor:rgba];
}

-(UIColor *)getToolColor
{
    return [penTool getToolColor];
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
    // if prev image is null,
    // add a dummy stack element so we can undo it too
    else{
        [stack queuePush:[NSNull null]];
    }
    
    incrementalImage = image;
    [self setNeedsDisplay];
    [self onDrawSketch];
}

-(void) clear
{
    stack = [NSMutableArray array];
    incrementalImage = nil;
    [currentTool clear];
    [self setNeedsDisplay];
    [self onDrawSketch];
}

-(void) undo
{
    UIImage *prev = [stack stackPop];
    if(prev && (prev != [NSNull null])){
        incrementalImage = prev;
    }
    else{
        incrementalImage = nil;
    }
    
    [currentTool clear];
    [self setNeedsDisplay];
    [self onDrawSketch];
    
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
    if([currentTool touchesEnded:touches withEvent:event]){
        [self takeSnapshot];
    }
    
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if([currentTool touchesCancelled:touches withEvent:event]){;
        [self takeSnapshot];
    }
}

-(void)takeSnapshot
{
    [self setViewImage:[self drawBitmap]];
    [currentTool clear];
}

-(void)onDrawSketch
{
    // get container view
    SketchViewContainer * parent = (SketchViewContainer *)self.superview;
    
    if(parent){
        parent.onDrawSketch(@{
            @"stackCount": @([stack count])
        });
    }
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
