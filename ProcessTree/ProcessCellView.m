//
//  ProcessCellView.m
//  ProcessExplorer
//
//  Created by salzmann on 30.09.14.
//
//

#import "ProcessCellView.h"

@implementation ProcessCellView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    /*NSRect bounds = [self bounds];
    
    [[[NSColor brownColor] colorWithAlphaComponent:alpha] set];
    
    
    
    [NSBezierPath fillRect:bounds];
    

    if (alpha >=0)
    {
        if (dispatch == NO)
        {
            alpha=alpha - 0.2;
            dispatch = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setNeedsDisplay:YES];
                dispatch = NO;
            });
        }
    }*/
}


@end
