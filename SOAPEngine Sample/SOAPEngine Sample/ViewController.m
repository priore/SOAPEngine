//
//  ViewController.m
//  SOAPEngine Sample
//
//  Created by Danilo Priore on 20/11/12.
//  Copyright (c) 2012 Prioregorup.com. All rights reserved.
//
#define ALERT(msg) {UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"SOAPEngine Sample" message:msg delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];[alert show];}

#import "ViewController.h"
#import "MyObject.h"

@implementation ViewController

static UILabel *label;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    list = nil;
    
    soap = [[SOAPEngine alloc] init];
    soap.userAgent = @"SOAPEngine";
    soap.actionNamespaceSlash = YES;
    soap.delegate = self;
    
    // license for com.prioregroup.soapengine-sample bundle
    // *** not required on ios-simulator ***
    soap.licenseKey = @"eJJDzkPK9Xx+p5cOH7w0Q+AvPdgK1fzWWuUpMaYCq3r1mwf36Ocw6dn0+CLjRaOiSjfXaFQBWMi+TxCpxVF/FA==";
    
    // data encryption
    //soap.encryptionType = SOAP_ENCRYPT_AES256;
    //soap.encryptionPassword = "my-password";

    // WFC basicHttpBinding
    //soap.actionNamespaceSlash = NO;
    //soap.version = VERSION_WCF_1_1;

    // extra envelope definitions
    //soap.envelope = @"xmlns:tmp=\"http://tempuri.org/\"";
    
    // autenthication
    //soap.authorizationMethod = SOAP_AUTH_BASIC;
    //soap.username = @"my-username";
    //soap.password = @"my-password";
    
    // parameters with user-defined objects
    /*
    MyObject *myObject = [[MyObject alloc] init];
    myObject.name = @"Dan";
    myObject.reminder = [[MyRemider alloc] init];
    myObject.reminder.date = [NSDate date];
    myObject.reminder.description = @"support email: support@prioregroup.com";
    [soap setValue:myObject forKey:nil]; // forKey must be nil value
    */

    // SOAP service (asmx)
    [soap setValue:@"Genesis" forKey:@"BookName"];
    [soap setIntegerValue:1 forKey:@"chapter"];
    [soap requestURL:@"http://www.prioregroup.com/services/americanbible.asmx"
          soapAction:@"http://www.prioregroup.com/GetVerses"];
    
    // SOAP WFC service (svc)
    //[soap requestURL:@"http://your-domain/services/AmericanBible.svc"
    //      soapAction:@"http://your-domain/IAmericanBible/GetVerses"];
    
}

#pragma mark - SOPAEngine delegates

- (void)soapEngine:(SOAPEngine *)soapEngine didFailWithError:(NSError *)error {
    
    NSString *msg = [NSString stringWithFormat:@"ERROR: %@", error.localizedDescription];
    ALERT(msg);
}

- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {
    
    NSDictionary *result = [soapEngine dictionaryValue];
    list = [[NSMutableArray alloc] initWithArray:[result valueForKey:@"BibleBookChapterVerse"]];
    
    if (list.count > 0) {
        label = [[UILabel alloc] initWithFrame:(CGRect){0, 0, 320, 50}];
        label.backgroundColor = [UIColor yellowColor];
        [self.view addSubview:label];
        [label setText:[[list firstObject] valueForKey:@"BookTitle"]];

        [self.tableView reloadData];
    } else {
        
        NSLog(@"%@", stringXML);
        ALERT(@"No verses founded!");
        
    }
}

- (BOOL)soapEngine:(SOAPEngine *)soapEngine didReceiveResponseCode:(NSInteger)statusCode {

    // 200 is response Ok, 500 Server error
    // see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    // for more response codes
    if (statusCode != 200 && statusCode != 500) {
        NSString *msg = [NSString stringWithFormat:@"ERROR: received status code %li", (long)statusCode];
        ALERT(msg);
        
        return NO;
    }
    
    return YES;
}

- (NSMutableURLRequest*)soapEngine:(SOAPEngine *)soapEngine didBeforeSendingURLRequest:(NSMutableURLRequest *)request {
    
    // use this delegate for personalize the header of the request
    // eg: [request setValue:@"my-value" forHTTPHeaderField:@"my-header-field"];
    
    NSLog(@"%@", [request allHTTPHeaderFields]);

    NSString *xml = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    NSLog(@"%@", xml);
    
    return request;
}

- (NSString *)soapEngine:(SOAPEngine *)soapEngine didBeforeParsingResponseString:(NSString *)stringXML
{
    // use this delegate for change the xml response before parsing it.
    return stringXML;
}

- (void)soapEngine:(SOAPEngine *)soapEngine didReceiveDataSize:(NSUInteger)current total:(NSUInteger)total
{
    NSLog(@"Received %i bytes of %i bytes", current, total);
}

- (void)soapEngine:(SOAPEngine *)soapEngine didSendDataSize:(NSUInteger)current total:(NSUInteger)total
{
    NSLog(@"Sended %i bytes of %i bytes", current, total);
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row < list.count) {

        NSDictionary *data = [list objectAtIndex:indexPath.row];
        
        NSString *chapter_verse = [NSString stringWithFormat:@"Chapter %@ Verse %@", [data objectForKey:@"Chapter"], [data objectForKey:@"Verse"]];
        cell.textLabel.text = chapter_verse;
        
        cell.detailTextLabel.text = [data objectForKey:@"Text"];
    }
    
    return cell;
}

@end
