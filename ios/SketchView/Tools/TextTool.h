#import <UIKit/UIKit.h>
#import "SketchTool.h"
#import "ToolThickness.h"
#import "ToolColor.h"


@interface TextTool : SketchTool<ToolThickness, ToolColor>

-(void)promptText;

@end
