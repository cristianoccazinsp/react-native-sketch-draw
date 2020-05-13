#import "React/RCTLog.h"
#import "React/RCTUtils.h"

#import "TextTool.h"
#import "Paint.h"


// TODO: Accept values from user input
#define TOOL_FONT_SIZE (35)
#define TOOL_INSTRUCTIONS (@"The following text will be added. After pressing add, press and hold on the screen to drag and drop the text.")


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

-(CGPoint)getDefaultPoint
{
    // align on center
    double x = self.touchView.bounds.origin.x + self.touchView.bounds.size.width / 2;
    
    double y = self.touchView.bounds.origin.y + self.touchView.bounds.size.height / 2;
    
    return CGPointMake(x, y);
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

-(BOOL)hasData
{
    if(prompted && drawn){
        return YES;
    }
    return NO;
}

-(void)clear
{
    drawn = NO;
    prompted = nil;
}

-(void)promptText
{
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
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    }];


    UIViewController *viewController = RCTPresentedViewController();

    if (viewController == nil) {
        RCTLogError(@"Tried to display alert view but there is no application window.");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController presentViewController:alert animated:NO completion:nil];
    });
}

-(void)setPrompted:(NSString *)text{
    prompted = text;
    
    [self drawPoint:[self getDefaultPoint]];
    
    [self.touchView setNeedsDisplay];
}

-(BOOL)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchView];
    
    startPoint = point;

    if(prompted == nil){
        [self promptText];
    }
    else{
        [self drawPoint:point];
        [self.touchView setNeedsDisplay];
    }
    
    return YES;

}

-(void)drawPoint:(CGPoint)point
{
    drawPoint = point;
    drawn = YES;
}

-(BOOL)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(prompted != nil){
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.touchView];
        [self drawPoint:point];
        [self.touchView setNeedsDisplay];
    }
    
    return YES;
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
        return NO;
    }
}

-(BOOL)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    return [self touchesEnded:touches withEvent:event];
}

@end
