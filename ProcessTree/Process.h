//
//  Process.h
//  ProcessExplorer
//
//  Created by salzmann on 30.09.14.
//
//

#import <Foundation/Foundation.h>
#import "ProcessSettings.h"
#import "NSPointerArray+Extra.h"
#include <sys/sysctl.h>


typedef struct kinfo_proc kinfo_proc;

@interface Process : NSObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, assign) uid_t userid;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, assign) pid_t pid;
@property (nonatomic, assign) pid_t ppid;
@property (nonatomic, assign) Process *parent;
@property (nonatomic, assign) float cpu;
@property (nonatomic, assign) NSPointerArray *subProcesses;
@property (assign) ProcessSettings *settings;
-(id)initWithKInfoProc:(kinfo_proc*)info;
-(BOOL)hasSubProcesses;
-(NSUInteger)getSubProcessesCount;
-(void)addSubProcess:(Process*)subProcess;
-(void)RemoveAllSubProcesses;
+(NSComparisonResult) compareProcessName:(Process*)a withProcess:(Process*)b;
+(NSComparisonResult) compareUserName:(Process*)a withProcess:(Process*)b;
+(NSComparisonResult) compareUserID:(Process*)a withProcess:(Process*)b;
+(NSComparisonResult) comparePid:(Process*)a withProcess:(Process*)b;
+(NSComparisonResult) compareCPU:(Process*)a withProcess:(Process*)b;
+(void) mergeSort:(NSPointerArray*)arr compareFunc:(SEL)compareFunc sortOrder:(NSInteger)sortOrder;
@end
