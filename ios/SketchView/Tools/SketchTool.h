#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SketchToolType) {
    SketchToolTypePen,
    SketchToolTypeEraser,
    SketchToolTypeRectangle,
    SketchToolTypeArrow
};

@interface SketchTool : NSObject

@property UIView *touchView;

-(instancetype)initWithTouchView:(UIView *) touchView;

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(void)render;
-(void)clear;

@end
