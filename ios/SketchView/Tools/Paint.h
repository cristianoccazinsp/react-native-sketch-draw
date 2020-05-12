#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Paint : NSObject

@property UIColor *color;
@property CGFloat thickness;

-(instancetype)initWithPathPaint:(Paint *) pathPaint;

@end
