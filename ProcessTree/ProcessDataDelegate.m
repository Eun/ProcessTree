//
//  ProcessDataDelegate.m
//  ProcessExplorer
//
//  Created by salzmann on 30.09.14.
//
//

#import "ProcessDataDelegate.h"
#import "ProcessCellView.h"
#import "Process.h"
#import "ProcessSettings.h"
#import "ProcessDataSource.h"

@implementation ProcessDataDelegate

- (id)initWithOutlineView:(NSOutlineView*)aOutlineView
{
    self = [super init];
    _outlineView = aOutlineView;
    return self;
}
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(Process*)item {
    NSTableCellView *cellView = [outlineView makeViewWithIdentifier:[tableColumn identifier] owner:self];
    if ([[tableColumn identifier] isEqualToString: COLUMN_PROCESS])
    {
        [[(ProcessCellView*)cellView textField] setStringValue: [item name]];
        
        
        if ([item path] != nil)
        {
            
            NSUInteger index = [[item path] rangeOfString:@".app/" options:NSCaseInsensitiveSearch].location;
            NSImage *image;
            if (index == NSNotFound)
            {
                image = [[NSWorkspace sharedWorkspace] iconForFile:[item path]];
            }
            else
            {
                NSString *p = [[item path] substringToIndex:index+5];
                image = [[NSWorkspace sharedWorkspace] iconForFile:p];
            }
             [[(ProcessCellView*)cellView imageView] setImage:image];
        }
        else
        {
            [[(ProcessCellView*)cellView imageView] setImage:[NSImage imageNamed:NSImageNameApplicationIcon]];
        }
        
    }
    else if ([[tableColumn identifier] isEqualToString: COLUMN_PID])
    {
        NSTextField *textField = [[cellView subviews] objectAtIndex:0];
        [textField setStringValue: [NSString stringWithFormat:@"%d", [item pid]]];
    }
    else if ([[tableColumn identifier] isEqualToString: COLUMN_USER])
    {
        NSTextField *textField = [[cellView subviews] objectAtIndex:0];
        [textField setStringValue: [NSString stringWithFormat:@"%@ (%d)", [item username], [item userid]]];
    }
    else if ([[tableColumn identifier] isEqualToString: COLUMN_CPU])
    {
        NSTextField *textField = [[cellView subviews] objectAtIndex:0];
        [textField setStringValue: [NSString stringWithFormat:@"%2.1f", [item cpu]]];
    }
    return cellView;
}

- (void)outlineView:(NSOutlineView *)outlineView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    Process *process = [outlineView itemAtRow:row];
    if ([[process settings] isNew])
    {
        [rowView setBackgroundColor:[NSColor greenColor]];
        [rowView setAlphaValue:0];
        [[NSAnimationContext currentContext] setDuration:.9];
        [[rowView animator] setBackgroundColor:[NSColor clearColor]];
        [[rowView animator] setAlphaValue:1.0];
    }
    else if ([[process settings] isDead])
    {
        [rowView setBackgroundColor:[NSColor redColor]];
        [rowView setAlphaValue:1];
        [[NSAnimationContext currentContext] setDuration:.9];
        [[rowView animator] setBackgroundColor:[NSColor clearColor]];
        [[rowView animator] setAlphaValue:0];
    }

}


- (void)outlineView:(NSOutlineView *)outlineView :(NSTableRowView *)rowView forRow:(NSInteger)row
{
    Process *process = [outlineView itemAtRow:row];
    //NSLog(@"didAddRowView");
    //NSTableRowView *view = [outlineView rowViewAtRow:row makeIfNecessary:YES];
    if ([[process settings] isNew])
    {
        [rowView setAlphaValue:0];
        //[rowView setBackgroundColor: [NSColor clearColor]];
        [[NSAnimationContext currentContext] setDuration:0.5];
        //[[rowView animator] setBackgroundColor:[NSColor redColor]];
        [[rowView animator] setAlphaValue:1.0];
    }
    //[rowView setBackgroundColor: [NSColor blueColor]];
    
}

- (void)outlineView:(NSOutlineView *)outlineView didClickTableColumn:(NSTableColumn *)tableColumn
{
    Process *selectedProcess = nil;
    // store the current selected row
    if ([_outlineView selectedRow] > -1)
    {
        selectedProcess = [_outlineView itemAtRow: [_outlineView selectedRow]];
    }
    
    ProcessDataSource* dataSource = [_outlineView dataSource];
    if ([dataSource isFlatView] == NO)
    {
        [dataSource showFlatView];
    }
    [dataSource setSortColumn:tableColumn];
    
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
    

}

- (void)outlineViewItemWillExpand:(NSNotification *)notification
{
    Process *process = [[notification userInfo] objectForKey:@"NSObject"];
    [[process settings] setExpanded:YES];
    for (Process *subProcess in [process subProcesses])
    {
        if ([[subProcess settings] expanded])
            [_outlineView expandItem:subProcess];
        else
            [_outlineView collapseItem:subProcess];
    }
}

- (void)outlineViewItemWillCollapse:(NSNotification *)notification
{
    
    ProcessDataSource* dataSource = [_outlineView dataSource];
    Process *process = [[notification userInfo] objectForKey:@"NSObject"];
    Process *parent = [dataSource FindPIDInList:[process ppid]];
    BOOL visible = YES;
    while (parent != nil && [parent pid] != 0 && [parent ppid] > 0 )
    {
        if ([[parent settings] expanded] == NO)
        {
            visible = NO;
            break;
        }
        parent = [dataSource FindPIDInList:[parent ppid]];
    }
    
    if (visible)
    {
        [[process settings] setExpanded:NO];
    }
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    [[self delegate] selectionDidChange:notification];
}

@end
