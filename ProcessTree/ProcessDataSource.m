//
//  ProcessDataSource.m
//  ProcessExplorer
//
//  Created by salzmann on 30.09.14.
//
//

#import "ProcessDataSource.h"
#import "Process.h"
#import "ProcessSettings.h"
#import "NSPointerArray+Extra.h"

@implementation ProcessDataSource
@synthesize flatProcesses;

- (id)initWithOutlineView:(NSOutlineView*)aOutlineView
{
    self = [super init];
    _outlineView = aOutlineView;
    flatView = [[NSUserDefaults standardUserDefaults] boolForKey:@"flatView"];
    flatProcesses = [[NSPointerArray alloc] init];
    return self;
}

- (void)RefreshProcessList
{
    [self RefreshProcessList:NO];
}

- (void)RefreshProcessList:(BOOL)firstTime
{
    kinfo_proc *mylist = NULL;
    size_t mycount = 0;
    
    // store the current scroll position
    NSRect visibleRect = [_outlineView visibleRect];
    
    Process *selectedProcess = nil;
    // store the current selected row
    if ([_outlineView selectedRow] > -1)
    {
        selectedProcess = [_outlineView itemAtRow: [_outlineView selectedRow]];
    }
    
    
    
    GetBSDProcessList(&mylist, &mycount);
    
    // prepare sort
    SEL compareFunc = nil;
    NSComparisonResult sortOrder = 0;
    if (flatView == YES && sortColumn != nil)
    {
        compareFunc = [self GetCompareFuncForTableColumn:sortColumn];
        sortOrder = (sortAscending) ? NSOrderedAscending : NSOrderedDescending;
    }
    
    
    // add all items
    for (NSUInteger i = mycount; i>=1; --i) {
        kinfo_proc *currentProcess = &mylist[i-1];
        
        Process *process = [self FindProcInList: currentProcess];
        if (process == nil)
        {
            process = [[Process alloc] initWithKInfoProc:currentProcess];
            if (compareFunc == nil)
            {
                [flatProcesses addPointer:process];
            }
            else
            {
                BOOL hasInserted = NO;
                for (NSUInteger i = 0; i < [flatProcesses count]; ++i)
                {
                    Process* processEmbed = [flatProcesses pointerAtIndex:i];
                    if ((NSComparisonResult)[[Process class] performSelector:compareFunc withObject:process withObject:processEmbed] == sortOrder)
                    {
                        [flatProcesses insertPointer:process atIndex:i];
                        hasInserted = YES;
                        break;
                    }
                }
                if (hasInserted == NO)
                {
                    [flatProcesses addPointer:process];
                }
            }
            
            if (firstTime == YES)
            {
                [[process settings] setIsNew:NO];
            }
            
        }
        else
        {
            [[process settings] setIsNew:NO];
        }
    }
    
    
    


    
    // mark & delete all processes that are not in the list
    for (NSUInteger j = [flatProcesses count]; j >= 1; --j)
    {
        Process *process = [flatProcesses pointerAtIndex:j-1];
        BOOL processExists = NO;
        for (NSUInteger i = mycount; i>=1; --i) {
            kinfo_proc *currentProcess = &mylist[i-1];
            if ([process pid] == currentProcess->kp_proc.p_pid)
            {
                processExists = YES;
                break;
            }
        }
        if (processExists == NO)
        {
            // remove all dead processes
            if ([[process settings] isDead])
            {
                // remove all references
                for (Process* parentProcess in flatProcesses)
                {
                    [[parentProcess subProcesses] removePointerXXX:process];
                }
                [process release];
                [flatProcesses removePointerAtIndex:j-1];
            }
            else
            {
                [[process settings] setIsDead:YES];
            }
        }
    }
    
    
    free(mylist);
    
    if (flatView == NO)
    {
        // resolve childs
        for (NSUInteger i = [flatProcesses count]; i >= 1; --i)
        {
            Process *process = [flatProcesses pointerAtIndex:i-1];
            if ([process pid] == 0 || [process ppid] < 0)
            {
                continue;
            }
            else
            {
                Process *parent = [self FindPIDInList: [process ppid]];
                if (parent != nil)
                {
                    if (![[parent subProcesses] containsPointer:process])
                    {
                        [parent addSubProcess:process];
                        [process setParent: parent];
                    }
                }
            }
        }
    }
    
    
    // remove processes based on the search
    // remember all processes that match, all others will be removed
    if (searchStr != nil)
    {
        NSPointerArray *processesAfterSearch = [[NSPointerArray alloc] init];
        for (NSUInteger j = [flatProcesses count]; j >= 1; --j)
        {
            Process *process = [flatProcesses pointerAtIndex:j-1];
            if ([[process name] rangeOfString:searchStr options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [processesAfterSearch addPointer:process];
                if (flatView == NO)
                {
                    for(;;)
                    {
                        Process *parent = [process parent];
                        if (parent == nil)
                            break;
                        if ([processesAfterSearch containsPointer: parent] == NO)
                        {
                            [processesAfterSearch addPointer:parent];
                        }
                        process = parent;
                    }
                }
                
            }
        }
        
        if ([processesAfterSearch count] > 0)
        {
            for (NSUInteger i = [flatProcesses count]; i >= 1; --i)
            {
                Process *process = [flatProcesses pointerAtIndex:i-1];
                if ([processesAfterSearch containsPointer:process] == NO)
                {
                    [flatProcesses removePointerAtIndex:i-1];
                    [process release];
                }
            }
            
            // remove missing references
            
            for (NSUInteger i = [flatProcesses count]; i >= 1; --i)
            {
                Process *process = [flatProcesses pointerAtIndex:i-1];
                if ([process hasSubProcesses])
                {
                    for (NSUInteger j = [[process subProcesses] count]; j >= 1; --j)
                    {
                        Process *subprocess = [[process subProcesses] pointerAtIndex:j-1];
                        if ([flatProcesses containsPointer:subprocess] == NO)
                        {
                            [[process subProcesses] removePointerAtIndex:j-1];
                        }
                    }
                }
            }
        }
        else
        {
            [flatProcesses removeAllPointers];
        }
        [processesAfterSearch release];
    }
    [_outlineView reloadData];
    [self ExpandItems];
    
    // restore selection
    if (selectedProcess != nil)
    {
        // restore selection & scroll
        NSInteger selectedRow =  [_outlineView rowForItem:selectedProcess];
        if (selectedRow > -1)
        {
            [_outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
            [_outlineView scrollRowToVisible:selectedRow];
        }
    }
    // restore scroll position if there was no process
    [_outlineView scrollRectToVisible:visibleRect];

}


-(void)ExpandItems
{
    for (Process *process in flatProcesses)
    {
        if ([[process settings] expanded])
            [_outlineView expandItem:process expandChildren:YES];
        else
            [_outlineView collapseItem:process collapseChildren:YES];
    }
}


- (Process*) FindPIDInList:(pid_t)pid
{
    for (NSUInteger j = [flatProcesses count]; j >= 1; --j)
    {
        Process* subprocess = [flatProcesses pointerAtIndex:j-1];
        if ([subprocess pid] == pid)
        {
            return subprocess;
        }
    }
    return nil;
}

- (Process*) FindProcInList:(kinfo_proc*)proc
{
    for (NSUInteger j = [flatProcesses count]; j >= 1; --j)
    {
        Process* subprocess = [flatProcesses pointerAtIndex:j-1];
        if ([subprocess pid] == proc->kp_proc.p_pid &&
            [subprocess ppid] == proc->kp_eproc.e_ppid &&
            !strncmp([[subprocess name] UTF8String], proc->kp_proc.p_comm, MAXCOMLEN+1))
        {
            return subprocess;
        }
    }
    return nil;
}

-(NSInteger)GetRootCount
{
    NSInteger count = 0;
    for (Process *process in flatProcesses)
    {
        if ([process pid] == 0 || [process ppid] < 0 )
        {
            count++;
        }
    }
    return count;
}

-(Process*)GetRootItem:(NSInteger)index
{
    NSInteger count = 0;
    for (Process *process in flatProcesses)
    {
        if ([process pid] == 0 || [process ppid] < 0 )
        {
            if (count == index)
            {
                return process;
            }
            count++;
        }
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(Process*)item
{
    if (flatView == NO)
    {
        return ([item hasSubProcesses]);
    }
    else
    {
        return NO;
    }
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(Process*)item
{
    if (item == nil)
    {
        if (flatView == NO)
        {
            return [self GetRootCount];
        }
        else
        {
            return [flatProcesses count];
        }
    }
    else
    {
        if (flatView == NO)
        {
            return [item getSubProcessesCount];
        }
        else
        {
            return 0;
        }
    }
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(Process*)item
{
    if (item == nil)
    {
        if (flatView == NO)
        {
            return [self GetRootItem:index];
        }
        else
        {
            return [flatProcesses pointerAtIndex:index];
        }
    }
    else
    {
        if (flatView == NO)
        {
            return [[item subProcesses] pointerAtIndex:index];
        }
        else
        {
            return nil;
        }
        
    }
}

- (void) showView:(BOOL)isFlat
{
    // store the current scroll position
    NSRect visibleRect = [_outlineView visibleRect];
    
    Process *selectedProcess = nil;
    // store the current selected row
    if ([_outlineView selectedRow] > -1)
    {
        selectedProcess = [_outlineView itemAtRow: [_outlineView selectedRow]];
    }
    
    flatView = isFlat;
    [self setSortColumn:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:flatView forKey:@"flatView"];
    [prefs synchronize];
    [_outlineView reloadData];
    
    if (isFlat == NO)
    {
        [self ExpandItems];
    }
    
    if (selectedProcess != nil)
    {
        // restore selection & scroll
        NSInteger selectedRow =  [_outlineView rowForItem:selectedProcess];
        if (selectedRow > -1)
        {
            [_outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
            [_outlineView scrollRowToVisible:selectedRow];
        }
        else
        {
            // restore scroll position if row was not found
            [_outlineView scrollRectToVisible:visibleRect];
        }
    }
    else
    {
        // restore scroll position if there was no process
        [_outlineView scrollRectToVisible:visibleRect];
    }


    
    [[self delegate] viewSwitched];

}

- (void) showTreeView
{
    [self showView:NO];
}

- (void) showFlatView
{
    [self showView:YES];
}

- (BOOL) isFlatView
{
    return flatView;
}

- (void) setSortColumn:(NSTableColumn*)tableColumn
{
    if (tableColumn == sortColumn)
        sortAscending = !sortAscending;
    else
        sortAscending = YES;
    sortColumn = tableColumn;
    for (NSTableColumn *column in [_outlineView tableColumns])
    {
        [_outlineView setIndicatorImage:nil inTableColumn:column];
    }
    
    if (tableColumn != nil)
    {
        if (sortAscending == YES)
            [_outlineView setIndicatorImage:[NSImage imageNamed:@"NSAscendingSortIndicator"] inTableColumn:tableColumn];
        else
            [_outlineView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:tableColumn];
        [self SortData:tableColumn ascending:sortAscending];
    }
    
}

- (SEL) GetCompareFuncForTableColumn:(NSTableColumn*)tableColumn
{
    SEL compareFunc;
    
    if ([[tableColumn identifier] isEqualToString: COLUMN_PROCESS])
    {
        compareFunc = @selector(compareProcessName:withProcess:);
    }
    else if ([[tableColumn identifier] isEqualToString: COLUMN_PID])
    {
        compareFunc = @selector(comparePid:withProcess:);
    }
    else if ([[tableColumn identifier] isEqualToString: COLUMN_USER])
    {
        compareFunc = @selector(compareUserID:withProcess:);
    }
    else if ([[tableColumn identifier] isEqualToString: COLUMN_CPU])
    {
        compareFunc = @selector(compareCPU:withProcess:);
    }
    return compareFunc;
}

- (void) SortData:(NSTableColumn*)tableColumn ascending:(BOOL)ascending
{
    [Process mergeSort:[self flatProcesses] compareFunc:[self GetCompareFuncForTableColumn: tableColumn] sortOrder:(ascending) ? NSOrderedAscending : NSOrderedDescending];
    [_outlineView reloadData];
}

- (void) setSearch:(NSString*)aSearchStr
{
    if (aSearchStr != nil)
    {
        if ([aSearchStr length] > 0)
        {
            if (searchStr == nil)
                [searchStr release];
            searchStr = [aSearchStr copy];
        }
        else
            searchStr = nil;
    }
    [_outlineView reloadData];
}



static int GetBSDProcessList(kinfo_proc **procList, size_t *procCount)
// Returns a list of all BSD processes on the system.  This routine
// allocates the list and puts it in *procList and a count of the
// number of entries in *procCount.  You are responsible for freeing
// this list (use "free" from System framework).
// On success, the function returns 0.
// On error, the function returns a BSD errno value.
{
    int                 err;
    kinfo_proc *        result;
    bool                done;
    static const int    name[] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    // Declaring name as const requires us to cast it when passing it to
    // sysctl because the prototype doesn't include the const modifier.
    size_t              length;
    
    //    assert( procList != NULL);
    //    assert(*procList == NULL);
    //    assert(procCount != NULL);
    
    *procCount = 0;
    
    // We start by calling sysctl with result == NULL and length == 0.
    // That will succeed, and set length to the appropriate length.
    // We then allocate a buffer of that size and call sysctl again
    // with that buffer.  If that succeeds, we're done.  If that fails
    // with ENOMEM, we have to throw away our buffer and loop.  Note
    // that the loop causes use to call sysctl with NULL again; this
    // is necessary because the ENOMEM failure case sets length to
    // the amount of data returned, not the amount of data that
    // could have been returned.
    
    result = NULL;
    done = false;
    do {
        assert(result == NULL);
        
        // Call sysctl with a NULL buffer.
        
        length = 0;
        err = sysctl( (int *) name, (sizeof(name) / sizeof(*name)) - 1,
                     NULL, &length,
                     NULL, 0);
        if (err == -1) {
            err = errno;
        }
        
        // Allocate an appropriately sized buffer based on the results
        // from the previous call.
        
        if (err == 0) {
            result = malloc(length);
            if (result == NULL) {
                err = ENOMEM;
            }
        }
        
        // Call sysctl again with the new buffer.  If we get an ENOMEM
        // error, toss away our buffer and start again.
        
        if (err == 0) {
            err = sysctl( (int *) name, (sizeof(name) / sizeof(*name)) - 1,
                         result, &length,
                         NULL, 0);
            if (err == -1) {
                err = errno;
            }
            if (err == 0) {
                done = true;
            } else if (err == ENOMEM) {
                assert(result != NULL);
                free(result);
                result = NULL;
                err = 0;
            }
        }
    } while (err == 0 && ! done);
    
    // Clean up and establish post conditions.
    
    if (err != 0 && result != NULL) {
        free(result);
        result = NULL;
    }
    *procList = result;
    if (err == 0) {
        *procCount = length / sizeof(kinfo_proc);
    }
    
    assert( (err == 0) == (*procList != NULL) );
    
    return err;
}

- (void)dealloc
{
    if (searchStr != nil)
    {
        [searchStr release];
        searchStr = nil;
    }
    [super dealloc];
}

@end
