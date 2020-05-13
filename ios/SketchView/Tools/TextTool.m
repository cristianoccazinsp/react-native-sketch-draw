#import "React/RCTLog.h"
#import "React/RCTUtils.h"

#import "TextTool.h"
#import "Paint.h"


@implementation TextTool{
    Paint *paint;
    CGPoint startPoint;
    BOOL drawn;
    NSString *prompted;
    CGPoint drawPoint;
}


-(instancetype)initWithTouchView:(UIView *)touchView
{
    self = [super initWithTouchView:touchView];

    paint = [[Paint alloc] init];

    [self setToolColor:[UIColor blackColor]];
    [self setToolThickness:5];

    drawn = NO;
    prompted = nil;

    return self;
}


-(void)render
{
    if(drawn && prompted != nil){
        [paint.color setStroke];

        // add some sanity checks
        double width = MAX(self.touchView.bounds.size.width - drawPoint.x, 1);
        double height = MAX(self.touchView.bounds.size.height - drawPoint.y, 1);

        CGRect rect = CGRectMake(drawPoint.x, drawPoint.y, width, height);

        [prompted drawInRect:rect withAttributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:TOOL_FONT_SIZE],
            NSForegroundColorAttributeName : paint.color
        }];
    }
}

-(void)setToolThickness:(CGFloat)thickness
{
    paint.thickness = thickness;
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
    drawPoint = CGPointMake(0, 0);
    drawn = NO;
    prompted = nil;
}

-(void)setPrompted:(NSString *)text{
    prompted = text;
    drawPoint = CGPointMake(0, 0); // so user is forced to move it
    [self drawPoint:drawPoint];
    [self.touchView setNeedsDisplay];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchView];
    
    startPoint = point;

    if(prompted == nil){
        // do nothing, handle text on press out
        // we will display a placeholder in the meantime
    }
    else{
        drawPoint = point;
        [self drawPoint:point];
        [self.touchView setNeedsDisplay];
    }

}

-(void)drawPoint:(CGPoint)point
{
    drawPoint = point;
    drawn = YES;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(prompted != nil){
        if ([touches count] == 1)
        {
            UITouch *touch = [touches anyObject];
            CGPoint point = [touch locationInView:self.touchView];
            [self drawPoint:point];
            [self.touchView setNeedsDisplay];
        }
    }
}

-(BOOL)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(prompted != nil){
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.touchView];
        [self drawPoint:point];
        [self.touchView setNeedsDisplay];

        return YES;
    }
    else{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Add Text" message:TOOL_INSTRUCTIONS preferredStyle:UIAlertControllerStyleAlert];

        __weak UIAlertController *weakAlert = alert;
        __weak __typeof(self) weakSelf = self;
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSString *text = [weakAlert.textFields.firstObject text];
            
            if(text && ([text length] > 0)){
                [weakSelf setPrompted:text];
            }
        }];

        [alert addAction:defaultAction];

        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Text...";
        }];


        UIViewController *viewController = RCTPresentedViewController();

        if (viewController == nil) {
          RCTLogError(@"Tried to display alert view but there is no application window.");
          return NO;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController presentViewController:alert animated:YES completion:nil];
        });
        
        return NO;
    }
}

-(BOOL)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];

    return NO;
}

@end
