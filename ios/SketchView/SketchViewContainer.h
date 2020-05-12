#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>
#import "SketchView.h"
#import "SketchFile.h"

@interface SketchViewContainer : UIView

@property (unsafe_unretained, nonatomic) IBOutlet SketchView *sketchView;
@property (nonatomic, copy) RCTDirectEventBlock onSaveSketch;
@property (nonatomic, copy) RCTDirectEventBlock onDrawSketch;

-(SketchFile *)saveToLocalCache:(NSString *)format toQuality:(NSInteger)quality;
-(BOOL)openSketchFile:(NSString *)localFilePath;


@end
