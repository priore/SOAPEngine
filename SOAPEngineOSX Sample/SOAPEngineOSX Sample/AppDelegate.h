//
//  AppDelegate.h
//  SOAPEngineOSX Sample
//
//  Created by Danilo Priore on 27/08/14.
//  Copyright (c) 2014 Danilo Priore. All rights reserved.
//

#include "MasterViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic,strong) IBOutlet MasterViewController *masterViewController;
@property (assign) IBOutlet NSWindow *window;

@end
