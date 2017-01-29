//
//  ViewController.m
//  SOAPEngine iOS
//
//  Created by Danilo Priore on 29/01/17.
//  Copyright © 2017 Danilo Priore. All rights reserved.
//

#import "ViewController.h"
#import <SOAPEngine64/SOAPEngine.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, SOAPEngineDelegate>
{
    NSMutableArray *list;
    
    IBOutlet UITableView *tableView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    list = nil;
    
    SOAPEngine *soap = [[SOAPEngine alloc] init];
    soap.licenseKey = @"eJJDzkPK9Xx+p5cOH7w0Q+AvPdgK1fzWWuUpMaYCq3r1mwf36Ocw6dn0+CLjRaOiSjfXaFQBWMi+TxCpxVF/FA==";
    soap.delegate = self;
    
    // WFC basicHttpBinding
    //soap.version = VERSION_WCF_1_1;
    
    // extra envelope definitions
    //soap.envelope = @"xmlns:tmp=\"http://tempuri.org/\"";
    
    // autenthication
    //soap.authorizationMethod = SOAP_AUTH_BASIC;
    //soap.username = @"my-username";
    //soap.password = @"my-password";
    
    // encryption/decryption
    //soap.encryptionType = SOAP_ENCRYPT_AES256;
    //soap.encryptionPassword = @"my-password";
    
    [soap setValue:@"Genesis" forKey:@"BookName"];
    [soap setValue:@(1) forKey:@"chapter"];
    [soap requestURL:@"http://www.prioregroup.com/services/americanbible.asmx"
          soapAction:@"http://www.prioregroup.com/GetVerses"];
    
    // PAYPAL associates a set of API credentials with a specific PayPal account
    // you can generate credentials from this https://developer.paypal.com/docs/classic/api/apiCredentials/
    // and convert to a p12 use : openssl pkcs12 -export -in cert_key_pem.txt -inkey cert_key_pem.txt -out paypal_cert.p12
    /*
     soap.authorizationMethod = SOAP_AUTH_PAYPAL;
     soap.username = @"support_api1.prioregroup.com";
     soap.password = @"R39K4JWD9V58ZEU6";
     soap.clientCerficateName = @"paypal_cert.p12";
     soap.clientCertificatePassword = @"priore";
     soap.responseHeader = YES;
     [soap setValue:@"0" forKey:@"paypal:ReturnAllCurrencies"]; // use paypal for urn:ebay:api:PayPalAPI namespace
     [soap setValue:@"119.0" forKey:@"paypal1:Version"]; // use paypal1 for urn:ebay:apis:eBLBaseComponents namespace
     // certificate : https://api.paypal.com/2.0/ sandbox https://api.sandbox.paypal.com/2.0/
     // signature : https://api-3t.paypal.com/2.0/ sandbox https://api-3t.sandbox.paypal.com/2.0/
     [soap requestURL:@"https://api.paypal.com/2.0/"
     soapAction:@"GetBalance" completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict) {
        NSLog(@"%@", dict);
     } failWithError:^(NSError *error) {
        NSLog(@"%@", error);
     }];
     */
    
    // SOAP WFC service (svc)
    //[soap requestURL:@"http://www.prioregroup.com/services/AmericanBible.svc"
    //      soapAction:@"http://www.prioregroup.com/IAmericanBible/GetVerses"];
}

#pragma mark - SOPAEngine delegates

- (void)soapEngine:(SOAPEngine *)soapEngine didFailWithError:(NSError *)error {
    
    NSString *msg = [NSString stringWithFormat:@"ERROR: %@", error.localizedDescription];
    NSLog(@"%@", msg);
}

- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {
    
    NSDictionary *result = [soapEngine dictionaryValue];
    list = [[NSMutableArray alloc] initWithArray:[result valueForKey:@"BibleBookChapterVerse"] ?: [result valueForKeyPath:@"BibleBookChapterVerseEncrypted"]];
    
    if (list.count > 0) {
        [tableView reloadData];
    } else {
        
        NSLog(@"%@", stringXML);
        NSLog(@"No verses founded!");
        
    }
}

- (BOOL)soapEngine:(SOAPEngine *)soapEngine didReceiveResponseCode:(NSInteger)statusCode {
    
    // 200 is response Ok, 500 Server error
    // see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    // for more response codes
    if (statusCode != 200 && statusCode != 500) {
        NSString *msg = [NSString stringWithFormat:@"ERROR: received status code %li", (long)statusCode];
        NSLog(@"%@", msg);
        
        return NO;
    }
    
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

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
