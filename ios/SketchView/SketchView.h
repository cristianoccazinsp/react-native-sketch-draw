#import <UIKit/UIKit.h>
#import "Paint.h"
#import "SketchTool.h"

@interface SketchView : UIView

-(void) clear;
-(void) undo;
-(void)setToolType:(SketchToolType) toolType;
-(void)setToolColor:(NSMutableDictionary *)rgba;
-(void)setViewImage:(UIImage *)image;
-(void)setMaxUndo:(NSInteger)max;

@end
