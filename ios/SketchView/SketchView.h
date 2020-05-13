#import <UIKit/UIKit.h>
#import "Paint.h"
#import "SketchTool.h"

@interface SketchView : UIView

-(void) clear;
-(void) undo;
-(void) commit;
-(void) promptData;
-(void)setToolType:(SketchToolType) toolType;
-(void)setToolColor:(UIColor *)rgba;
-(UIColor *)getToolColor;
-(void)setViewImage:(UIImage *)image;
-(void)setMaxUndo:(NSInteger)max;

@end
