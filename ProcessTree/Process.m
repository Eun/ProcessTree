//
//  Process.m
//  ProcessExplorer
//
//  Created by salzmann on 30.09.14.
//
//

#import "Process.h"

#include <pwd.h>
#include <libproc.h>
#include <errno.h>

@implementation Process
@synthesize name;
@synthesize username;
@synthesize path;




-(id)initWithKInfoProc:(kinfo_proc*)info
{
    self = [super init];
    [self setSubProcesses:nil];
    [self setPid: info->kp_proc.p_pid];
    name = [[NSString alloc] initWithFormat: @"%s",info->kp_proc.p_comm];
    [self setPpid: info->kp_eproc.e_ppid];
    [self setSettings:[[ProcessSettings alloc] init]];
    [self setUserid:info->kp_eproc.e_ucred.cr_uid];
    [self setCpu:10.1];
    [self setParent:nil];
   
    struct passwd *p_user = getpwuid(info->kp_eproc.e_ucred.cr_uid);
    if (p_user)
    {
        if (p_user->pw_name != nil)
        {
            username = [[NSString alloc] initWithFormat: @"%s",p_user->pw_name];
        }
        else
        {
            username = [[NSString alloc] initWithString:@""];
        }
        
     }
    else
    {
        username = [[NSString alloc] initWithString:@""];
    }
    
    char pathbuf[PROC_PIDPATHINFO_MAXSIZE] = "";

    int ret = proc_pidpath (info->kp_proc.p_pid, pathbuf, sizeof(pathbuf));
    if (ret > 0) {
        path = [[NSString alloc] initWithFormat: @"%s", pathbuf];
    }
    else
    {
        NSLog(@"proc_pidpath: %d: %s", errno, strerror(errno));
        path = nil;
    }
    

    
    return self;
}

-(BOOL)hasSubProcesses
{
    if (_subProcesses == nil)
    {
        return NO;
    }
    if ([_subProcesses count] == 0)
    {
        return NO;
    }
    return YES;
}

-(NSUInteger)getSubProcessesCount
{
    if (_subProcesses == nil)
    {
        return 0;
    }
    return [_subProcesses count];
}
-(void)addSubProcess:(Process*)subProcess
{
    if (_subProcesses == nil)
    {
        _subProcesses = [[NSPointerArray alloc] init];
    }
    [_subProcesses addPointer:subProcess];
}
-(void)RemoveAllSubProcesses
{
    if (_subProcesses != nil)
    {
        [_subProcesses release];
        _subProcesses = [[NSPointerArray alloc] init];
    }
}
-(void)dealloc
{
    if (_subProcesses != nil)
    {
        [_subProcesses release];
        _subProcesses = nil;
    }
    if (name != nil)
    {
        [name release];
        name = nil;
    }
    if (username != nil)
    {
        [username release];
        username = nil;
    }
    if (path != nil)
    {
        [path release];
        path = nil;
    }
    if (_settings != nil)
    {
        [_settings release];
        _settings = nil;
    }
    [super dealloc];
}


+ (void) merge:(NSPointerArray*)arr first:(NSUInteger)first mid:(NSUInteger)mid last:(NSUInteger)last compareFunc:(SEL)compareFunc sortOrder:(NSInteger)sortOrder
{
    NSPointerArray *tempArr = [[NSPointerArray alloc] init];
    NSUInteger indexA = first;
    NSUInteger indexB = mid;
    
    while (indexA < mid && indexB < last) {
        Process *numA = [arr pointerAtIndex:indexA];
        Process *numB = [arr pointerAtIndex:indexB];
        
        if ((NSComparisonResult)[[Process class] performSelector:compareFunc withObject:numA withObject:numB] == sortOrder)
        {
            [tempArr addPointer:numA];
            indexA++;
        }
        else {
            [tempArr addPointer:numB];
            indexB++;
        }
    }
    
    while (indexA < mid) {
        [tempArr addPointer:[arr pointerAtIndex:indexA]];
        indexA++;
    }
    
    while (indexB < last) {
        [tempArr addPointer:[arr pointerAtIndex:indexB]];
        indexB++;
    }
    
    indexA = first;
    
    for (NSUInteger i = 0; i < tempArr.count; i++) {
        [arr replacePointerAtIndex:indexA withPointer:[tempArr pointerAtIndex:i]];
        indexA++;
    }
}

+(void) merge_sort:(NSPointerArray*)arr first:(NSUInteger)first last:(NSUInteger)last compareFunc:(SEL)compareFunc sortOrder:(NSInteger)sortOrder
{
    if (first + 1 < last) {
        NSUInteger mid = (first + last) / 2;
        [Process merge_sort:arr first:first last:mid compareFunc:compareFunc sortOrder:sortOrder];
        [Process merge_sort:arr first:mid last:last compareFunc:compareFunc sortOrder:sortOrder];
        [Process merge:arr first:first mid:mid last:last compareFunc:compareFunc sortOrder:sortOrder];
    }
}

+(void) mergeSort:(NSPointerArray*)arr compareFunc:(SEL)compareFunc sortOrder:(NSInteger)sortOrder
{
    [self merge_sort:arr first:0 last:[arr count] compareFunc:compareFunc sortOrder:sortOrder];
}

+(NSComparisonResult) compareProcessName:(Process*)a withProcess:(Process*)b
{
    return [[a name] caseInsensitiveCompare:[b name]];
}

+(NSComparisonResult) compareUserName:(Process*)a withProcess:(Process*)b
{
    return [[a username] caseInsensitiveCompare:[b username]];
}

+(NSComparisonResult) compareUserID:(Process*)a withProcess:(Process*)b
{
    if ([a userid] < [b userid])
        return NSOrderedAscending;
    else if ([a userid] > [b userid])
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

+(NSComparisonResult) comparePid:(Process*)a withProcess:(Process*)b
{
    if ([a pid] < [b pid])
        return NSOrderedAscending;
    else if ([a pid] > [b pid])
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

+(NSComparisonResult) compareCPU:(Process*)a withProcess:(Process*)b
{
    if ([a cpu] < [b cpu])
        return NSOrderedAscending;
    else if ([a cpu] > [b cpu])
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

@end
