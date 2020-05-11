//
//  SketchViewContainer.m
//  Sketch
//
//  Created by Keshav on 06/04/17.
//  Copyright © 2017 Particle41. All rights reserved.
//

#import "SketchViewContainer.h"

@implementation SketchViewContainer


-(BOOL)openSketchFile:(NSString *)localFilePath
{
    UIImage *image = [UIImage imageWithContentsOfFile:localFilePath];
    if(image) {
        [self.sketchView setViewImage:image];
        return YES;
    }
    return NO;
}

-(SketchFile *)saveToLocalCache:(NSString*)format toQuality:(NSInteger)quality
{
    UIImage *image = [SketchViewContainer imageWithView:self];
    
    NSURL *tempDir = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *fileURL;
    
    if ([format isEqualToString:@"PNG"]) {
        NSString *fileName = [NSString stringWithFormat:@"sketch_%@.png", [[NSUUID UUID] UUIDString]];
        fileURL = [tempDir URLByAppendingPathComponent:fileName];
        
        NSData *imageData = UIImagePNGRepresentation(image);
        [imageData writeToURL:fileURL atomically:YES];
        
    }
    else{
        NSString *fileName = [NSString stringWithFormat:@"sketch_%@.jpg", [[NSUUID UUID] UUIDString]];
        fileURL = [tempDir URLByAppendingPathComponent:fileName];
        
        NSData *imageData = UIImageJPEGRepresentation(image, quality / 100.0);
        [imageData writeToURL:fileURL atomically:YES];        
    }
    
    
    SketchFile *sketchFile = [[SketchFile alloc] init];
    sketchFile.localFilePath = [fileURL path];
    sketchFile.size = [image size];
    return sketchFile;
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
