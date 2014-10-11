//
//  ProcessDataSource.h
//  ProcessExplorer
//
//  Created by salzmann on 30.09.14.
//
//

#import <Cocoa/Cocoa.h>
#import "Process.h"

#define COLUMN_PROCESS @"ProcessColumn"
#define COLUMN_PID @"PIDColumn"
#define COLUMN_USER @"UserColumn"
#define COLUMN_CPU @"CPUColumn"

@protocol ProcessDataSourceDelegate <NSObject>
- (void)viewSwitched;
@end


@interface ProcessDataSource : NSObject <NSOutlineViewDataSource>
{
    NSOutlineView *_outlineView;
    BOOL flatView;
    NSTableColumn *sortColumn;
    BOOL sortAscending;
    NSString *searchStr;
}
@property (assign) NSPointerArray *flatProcesses;
@property (nonatomic, retain) IBOutlet id<ProcessDataSourceDelegate> delegate;
- (id)initWithOutlineView:(NSOutlineView*)aOutlineView;
- (Process*) FindPIDInList:(pid_t)pid;
- (void) showTreeView;
- (void) showFlatView;
- (BOOL) isFlatView;
- (void) setSortColumn:(NSTableColumn*)tableColumn;
- (void) RefreshProcessList;
- (void) RefreshProcessList:(BOOL)firstTime;
- (void) setSearch:(NSString*)aSearchStr;
@end

