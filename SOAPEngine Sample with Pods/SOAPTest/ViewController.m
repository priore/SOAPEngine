//
//  ViewController.m
//  SOAPTest
//
//  Created by Danilo Priore on 21/08/15.
//  Copyright (c) 2015 Danilo Priore. All rights reserved.
//

#import "ViewController.h"
#import <SOAPEngine64/SOAPEngine.h>

@interface ViewController ()

@property (nonatomic, strong) SOAPEngine *soap;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.soap = [[SOAPEngine alloc] init];
    [self.soap setValue:@"Genesis" forKey:@"BookName"];
    [self.soap setIntegerValue:1 forKey:@"chapter"];
    [self.soap requestURL:@"http://www.prioregroup.com/services/americanbible.asmx"
               soapAction:@"http://www.prioregroup.com/GetVerses"
   completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict) {
       
       NSLog(@"%@", dict);
       
   } failWithError:^(NSError *error) {
       
       NSLog(@"%@", error);
       
   }];
}

- (void)dealloc
{
    self.soap = nil;
}

@end
