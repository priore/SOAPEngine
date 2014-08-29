//
//  ViewController.h
//  SOAPEngine Sample
//
//  Created by Danilo Priore on 20/11/12.
//  Copyright (c) 2012 Prioregorup.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SOAPEngine/SOAPEngine.h>

@interface ViewController : UITableViewController <SOAPEngineDelegate>
{
    SOAPEngine *soap;
    NSMutableArray *list;
}

@end
