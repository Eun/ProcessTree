//
//  AppDelegate.h
//  ProcessExplorer
//
//  Created by salzmann on 30.09.14.
//
//

#import <Cocoa/Cocoa.h>
#import "ProcessDataSource.h"
#import "ProcessDataDelegate.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, ProcessDataSourceDelegate, ProcessDataDelegateDelegate>
{
    ProcessDataSource *processDataSource;
    ProcessDataDelegate *processDataDelegate;
}
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSToolbarItem *showTreeView;
@property (assign) IBOutlet NSToolbarItem *killProcess;
@property (assign) IBOutlet NSToolbarItem *infoProcess;
@end

