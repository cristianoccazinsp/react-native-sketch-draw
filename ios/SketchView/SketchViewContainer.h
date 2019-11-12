//
//  SketchViewContainer.h
//  Sketch
//
//  Created by Keshav on 06/04/17.
//  Copyright © 2017 Particle41. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>
#import "SketchView.h"
#import "SketchFile.h"

@interface SketchViewContainer : UIView

@property (unsafe_unretained, nonatomic) IBOutlet SketchView *sketchView;
@property (nonatomic, copy) RCTDirectEventBlock onSaveSketch;

-(SketchFile *)saveToLocalCache:(NSString *)format toQuality:(NSInteger)quality;
-(BOOL)openSketchFile:(NSString *)localFilePath;


@end
