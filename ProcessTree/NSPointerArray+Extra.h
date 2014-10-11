//
//  NSPointerArray+Extra.h
//  ProcessExplorer
//
//  Created by salzmann on 01.10.14.
//
//

#import <Foundation/NSPointerArray.h>

@interface NSPointerArray (Extra)
-(BOOL)containsPointer:(id)aPointer;
-(void)removePointerXXX:(id)aPointer;
-(void)removeAllPointers;
@end
