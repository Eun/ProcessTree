//
//  NSPointerArray+Extra.m
//  ProcessExplorer
//
//  Created by salzmann on 01.10.14.
//
//

#import "NSPointerArray+Extra.h"

@implementation NSPointerArray (Extra)
-(BOOL)containsPointer:(id)aPointer
{
    for (id ptr in self.allObjects)
    {
        if (ptr == aPointer)
            return YES;
    }
    return NO;
}
-(void)removePointerXXX:(id)aPointer
{
    for (NSUInteger i = self.count; i >= 1; --i)
    {
        id ptr = [self pointerAtIndex:i-1];
        if (ptr == aPointer)
        {
            [self removePointerAtIndex:i-1];
            return;
        }
    }
}

-(void)removeAllPointers
{
   while (self.count > 0)
       [self removePointerAtIndex:0];
}
@end
