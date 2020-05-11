#import <React/RCTBridge.h>
#import "RNSketchViewManager.h"
#import <React/RCTUIManager.h>


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

RCT_CUSTOM_VIEW_PROPERTY(maxUndo, NSInteger, SketchViewContainer)
{
    SketchViewContainer *currentView = !view ? defaultView : view;
    [currentView.sketchView setMaxUndo:[RCTConvert NSInteger:json]];
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
RCT_EXPORT_VIEW_PROPERTY(onDrawSketch, RCTDirectEventBlock);

RCT_EXPORT_MODULE(RNSketchView)

-(UIView *)view
{
    return [[[NSBundle bundleForClass:self.classForCoder] loadNibNamed:@"SketchViewContainer" owner:self options:nil] firstObject];
}

RCT_EXPORT_METHOD(saveSketch:(nonnull NSNumber *)reactTag toFormat:(NSString *)format toQuality:(NSInteger)quality) {
    
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, SketchViewContainer *> *viewRegistry) {
        SketchViewContainer *view = viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[SketchViewContainer class]]) {
            RCTLogError(@"Cannot find SketchViewContainer with tag #%@", reactTag);
            return;
        }
        SketchFile *sketchFile = [view saveToLocalCache:format toQuality:quality];
        [self _onSaveSketch:sketchFile withContainer:view];
    }];
}

RCT_EXPORT_METHOD(clearSketch:(nonnull NSNumber *)reactTag) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, SketchViewContainer *> *viewRegistry) {
        SketchViewContainer *view = viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[SketchViewContainer class]]) {
            RCTLogError(@"Cannot find SketchViewContainer with tag #%@", reactTag);
            return;
        }
        [view.sketchView clear];
    }];
}

RCT_EXPORT_METHOD(undoSketch:(nonnull NSNumber *)reactTag) {
    
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, SketchViewContainer *> *viewRegistry) {
        SketchViewContainer *view = viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[SketchViewContainer class]]) {
            RCTLogError(@"Cannot find SketchViewContainer with tag #%@", reactTag);
            return;
        }
        [view.sketchView undo];
    }];
}

RCT_EXPORT_METHOD(changeTool:(nonnull NSNumber *)reactTag toolId:(NSInteger) toolId) {
    
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, SketchViewContainer *> *viewRegistry) {
        SketchViewContainer *view = viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[SketchViewContainer class]]) {
            RCTLogError(@"Cannot find SketchViewContainer with tag #%@", reactTag);
            return;
        }
        [view.sketchView setToolType:toolId];
    }];
}

-(void)_onSaveSketch:(SketchFile *) sketchFile withContainer:(SketchViewContainer*)container
{
    container.onSaveSketch(@{
        @"localFilePath": sketchFile.localFilePath,
        @"imageWidth": [NSNumber numberWithFloat:sketchFile.size.width],
        @"imageHeight": [NSNumber numberWithFloat:sketchFile.size.height]
    });
}

@end
