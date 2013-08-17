//
//  ViewController.m
//  SOAPEngine Sample
//
//  Created by Danilo Priore on 20/11/12.
//  Copyright (c) 2012 Prioregorup.com. All rights reserved.
//
#define ALERT(msg) {UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"SOAPEngine Sample" message:msg delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];[alert show];[alert release];}

#import "ViewController.h"
#import "MyObject.h"

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    soap = [[SOAPEngine alloc] init];
    soap.userAgent = @"SOAPEngine";
    soap.delegate = self;
    
    // extra envelope tag attributes
    soap.envelope = @"xmlns:tmp=\"http://temp.org\"";
    
    // autenthication
    soap.authorizationMethod = SOAP_AUTH_BASIC;
    soap.username = @"my-username";
    soap.password = @"my-password";
    
    // simple parameters
    [soap setValue:@"Genesis" forKey:@"BookTitle"];
    [soap setIntegerValue:1 forKey:@"chapter"];
    
    // or with user-defined objects
    /*
    MyObject *myObject = [[MyObject alloc] init];
    myObject.name = @"Dan";
    myObject.reminder = [[MyRemider alloc] init];
    myObject.reminder.date = [NSDate date];
    myObject.reminder.description = @"support email: support@prioregroup.com";
    [soap setValue:myObject forKey:nil]; // forKey must be nil value
    */
    
    [soap requestURL:@"http://www.webservicex.net/BibleWebservice.asmx" soapAction:@"http://www.webserviceX.NET/GetBibleWordsByBookTitleAndChapter"];
}

#pragma mark - SOPAEngine delegates

- (void)soapEngine:(SOAPEngine *)soapEngine didFailWithError:(NSError *)error {
    
    NSString *msg = [NSString stringWithFormat:@"ERROR: %@", error.localizedDescription];
    ALERT(msg);
}

- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {
    
    NSDictionary *result = [soapEngine dictionaryValue];
    list = [result valueForKeyPath:@"NewDataSet.Table"];
    [self.tableView reloadData];
}

- (BOOL)soapEngine:(SOAPEngine *)soapEngine didReceiveResponseCode:(int)statusCode {

    // 200 is response Ok, 500 Server error
    if (statusCode != 200 && statusCode != 500) {
        NSString *msg = [NSString stringWithFormat:@"ERROR: received status code %i", statusCode];
        ALERT(msg);
    }
    
    // see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    // form more response codes

    return YES;
}

- (NSMutableURLRequest*)soapEngine:(SOAPEngine *)soapEngine didBeforeSendingURLRequest:(NSMutableURLRequest *)request {
    
    NSLog(@"%@", [request allHTTPHeaderFields]);

    NSString *xml = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    NSLog(@"%@", xml);
    
    return request;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"The Bible - Genesis";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *data = [list objectAtIndex:indexPath.row];
    
    NSString *chapter_verse = [NSString stringWithFormat:@"Chapter %@ Verse %@", [data objectForKey:@"Chapter"], [data objectForKey:@"Verse"]];
    cell.textLabel.text = chapter_verse;
    
    cell.detailTextLabel.text = [data objectForKey:@"BibleWords"];
    
    return cell;
}

-(void)dealloc {
    
    [soap release];
    [list release];
    [super dealloc];
}

@end
