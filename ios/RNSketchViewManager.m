#import "RNSketchViewManager.h"

@implementation RNSketchViewManager

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}


RCT_CUSTOM_VIEW_PROPERTY(selectedTool, NSInteger, SketchViewContainer)
{
    SketchViewContainer *currentView = !view ? defaultView : view;
    [currentView.sketchView setToolType:[RCTConvert NSInteger:json]];
}


RCT_CUSTOM_VIEW_PROPERTY(toolColor, UIColor, SketchViewContainer)
{
    SketchViewContainer *currentView = !view ? defaultView : view;
    [currentView.sketchView setToolColor:[RCTConvert UIColor:json]];
}

RCT_CUSTOM_VIEW_PROPERTY(localSourceImagePath, NSString, SketchViewContainer)
{
    SketchViewContainer *currentView = !view ? defaultView : view;
    NSString *localFilePath = [RCTConvert NSString:json];
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentView openSketchFile:localFilePath];
    });
}

RCT_EXPORT_VIEW_PROPERTY(onSaveSketch, RCTDirectEventBlock);

RCT_EXPORT_MODULE(RNSketchView)

-(UIView *)view
{
    self.sketchViewContainer = [[[NSBundle bundleForClass:self.classForCoder] loadNibNamed:@"SketchViewContainer" owner:self options:nil] firstObject];
    return self.sketchViewContainer;
}

RCT_EXPORT_METHOD(saveSketch:(nonnull NSNumber *)reactTag toFormat:(NSString *)format toQuality:(NSInteger)quality) {
    dispatch_async(dispatch_get_main_queue(), ^{
        SketchFile *sketchFile = [self.sketchViewContainer saveToLocalCache:format toQuality:quality];
        [self _onSaveSketch:sketchFile];
    });
}

RCT_EXPORT_METHOD(clearSketch:(nonnull NSNumber *)reactTag) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.sketchViewContainer.sketchView clear];
    });
}

RCT_EXPORT_METHOD(changeTool:(nonnull NSNumber *)reactTag toolId:(NSInteger) toolId) {
    [self.sketchViewContainer.sketchView setToolType:toolId];
}

-(void)_onSaveSketch:(SketchFile *) sketchFile
{
    self.sketchViewContainer.onSaveSketch(@{
        @"localFilePath": sketchFile.localFilePath,
        @"imageWidth": [NSNumber numberWithFloat:sketchFile.size.width],
        @"imageHeight": [NSNumber numberWithFloat:sketchFile.size.height]
    });
}

@end
