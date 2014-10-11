//
//  ProcessSettings.h
//  ProcessExplorer
//
//  Created by salzmann on 01.10.14.
//
//

#import <Foundation/Foundation.h>

@interface ProcessSettings : NSObject
@property (assign) BOOL expanded;
@property (assign) BOOL isNew;
@property (assign) BOOL isDead;
-(id)init;
@end
