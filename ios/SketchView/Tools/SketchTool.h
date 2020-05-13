#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SketchToolType) {
    SketchToolTypePen,
    SketchToolTypeEraser,
    SketchToolTypeRectangle,
    SketchToolTypeArrow,
    SketchToolTypeText
};

@interface SketchTool : NSObject

@property UIView *touchView;

-(instancetype)initWithTouchView:(UIView *) touchView;

-(BOOL)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(BOOL)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(BOOL)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(BOOL)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(void)render;
-(void)clear;

// Implement this to hint that the tool has pending data
// and it should commit before clearing / switching
-(BOOL)hasData;

@end
