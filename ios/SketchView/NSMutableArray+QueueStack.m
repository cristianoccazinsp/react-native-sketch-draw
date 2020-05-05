#import "NSMutableArray+QueueStack.h"


@implementation NSMutableArray (QueueStack)
-(id)queuePop {
  @synchronized(self)
  {
    if ([self count] == 0) {
        return nil;
    }

    id queueObject = [self objectAtIndex:0];

    [self removeObjectAtIndex:0];

    return queueObject;
  }
}

-(void)queuePush:(id)anObject {
  @synchronized(self)
  {
    [self addObject:anObject];
  }
}

-(id)stackPop {
  @synchronized(self)
  {
    id lastObject = [self lastObject];

    if (lastObject)
        [self removeLastObject];

    return lastObject;
  }
}

-(void)stackPush:(id)obj {
  @synchronized(self)
  {
    [self addObject: obj];
  }
}
@end
