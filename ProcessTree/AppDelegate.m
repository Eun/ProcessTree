//
//  AppDelegate.m
//  ProcessExplorer
//
//  Created by salzmann on 30.09.14.
//
//

#import "AppDelegate.h"


@implementation AppDelegate
@synthesize showTreeView;
@synthesize killProcess;
@synthesize infoProcess;



- (void)awakeFromNib
{
    processDataSource = [[ProcessDataSource alloc] initWithOutlineView:_outlineView];
    [_outlineView setDataSource:processDataSource];
    [processDataSource setDelegate: self];
    processDataDelegate = [[ProcessDataDelegate alloc] initWithOutlineView:_outlineView];
    [_outlineView setDelegate:processDataDelegate];
    [processDataDelegate setDelegate:self];
    
    [self UpdateToolBar];
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    [processDataSource RefreshProcessList:YES];
    [NSTimer scheduledTimerWithTimeInterval:1 target:processDataSource selector:@selector(RefreshProcessList) userInfo:nil repeats:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (void) UpdateToolBar
{
    if ([processDataSource isFlatView])
    {
       
        [showTreeView setEnabled:YES];
    }
    else
    {
        [showTreeView setEnabled:NO];
    }
    
    if ([_outlineView selectedRow] > -1)
    {
        [killProcess setEnabled:YES];
        [infoProcess setEnabled:YES];
    }
    else
    {
        [killProcess setEnabled:NO];
        [infoProcess setEnabled:NO];
    }
    
}

-(IBAction)ShowProcessTree:(id)sender
{
    [processDataSource showTreeView];
    [self UpdateToolBar];
}

-(IBAction)KillSelectedProcess:(id)sender
{
    if ([_outlineView selectedRow] > -1)
    {
        Process *process = [_outlineView itemAtRow:[_outlineView selectedRow]];
        [_outlineView selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
        kill([process pid], SIGKILL);
    }
    [self UpdateToolBar];
}

-(IBAction)InfoSelectedProcess:(id)sender
{
    if ([_outlineView selectedRow] > -1)
    {
        
    }
    [self UpdateToolBar];
}

-(IBAction)SearchProcess:(NSSearchField*)sender
{
    [processDataSource setSearch: [sender stringValue]];
    [self UpdateToolBar];
}
-(void)viewSwitched
{
    [self UpdateToolBar];
}

-(void)selectionDidChange:(NSNotification*)notification
{
    [self UpdateToolBar];
}

@end
