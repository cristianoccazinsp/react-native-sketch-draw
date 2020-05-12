#import "Paint.h"

@implementation Paint


-(instancetype)initWithPathPaint:(Paint *) pathPaint
{
    self = [super init];
    self.color = [UIColor colorWithCGColor:[pathPaint.color CGColor]];
    self.thickness = pathPaint.thickness;
    return self;
}


@end
