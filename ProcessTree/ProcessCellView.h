//
//  ProcessCellView.h
//  ProcessExplorer
//
//  Created by salzmann on 30.09.14.
//
//

#import <Cocoa/Cocoa.h>

@interface ProcessCellView : NSTableCellView
@property(weak) IBOutlet NSImageView *imageView;
@property(weak) IBOutlet NSTextField *textField;
@end
