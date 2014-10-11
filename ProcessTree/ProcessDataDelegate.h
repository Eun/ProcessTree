//
//  ProcessDataDelegate.h
//  ProcessExplorer
//
//  Created by salzmann on 30.09.14.
//
//

#import <Cocoa/Cocoa.h>


@protocol ProcessDataDelegateDelegate <NSObject>
- (void)selectionDidChange:(NSNotification*)notification;
@end

@interface ProcessDataDelegate : NSObject <NSOutlineViewDelegate>
{
    NSOutlineView *_outlineView;
}
@property (nonatomic, retain) IBOutlet id<ProcessDataDelegateDelegate> delegate;
- (id)initWithOutlineView:(NSOutlineView*)aOutlineView;
@end
