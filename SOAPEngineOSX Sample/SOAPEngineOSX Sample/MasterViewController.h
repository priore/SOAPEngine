//
//  MasterViewController.h
//  SOAPEngineOSX Sample
//
//  Created by Danilo Priore on 27/08/14.
//  Copyright (c) 2014 Danilo Priore. All rights reserved.
//

#import <SOAPEngineOSX/SOAPEngine.h>

@interface MasterViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, SOAPEngineDelegate>
{
    NSMutableArray *list;
}

@property (nonatomic, weak) IBOutlet NSTextField *bookTitle;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@end
