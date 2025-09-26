//
//  ViewController.h
//  SOAPEngine OSX
//
//  Created by Danilo Priore on 29/01/17.
//  Copyright © 2017 Danilo Priore. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SOAPEngine.h"

@interface ViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, SOAPEngineDelegate>
{
    NSMutableArray *list;
    SOAPEngine *soap;
}

@property (nonatomic, weak) IBOutlet NSTextField *bookTitle;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@end

