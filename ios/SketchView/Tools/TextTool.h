#import <UIKit/UIKit.h>
#import "SketchTool.h"
#import "ToolThickness.h"
#import "ToolColor.h"


// TODO: Accept values from user input
#define TOOL_FONT_SIZE (35)
#define TOOL_INSTRUCTIONS (@"The following text will be added. After pressing add, press and hold on the screen to drag and drop the text.")


@interface TextTool : SketchTool<ToolThickness, ToolColor>

@end
