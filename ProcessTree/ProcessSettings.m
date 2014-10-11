//
//  ProcessSettings.m
//  ProcessExplorer
//
//  Created by salzmann on 01.10.14.
//
//

#import "ProcessSettings.h"

@implementation ProcessSettings
-(id)init
{
    self = [super self];
    [self setExpanded:YES];
    [self setIsNew:YES];
    [self setIsDead:NO];
    return self;
}
@end
