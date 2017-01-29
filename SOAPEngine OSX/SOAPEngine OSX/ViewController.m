//
//  ViewController.m
//  SOAPEngine OSX
//
//  Created by Danilo Priore on 29/01/17.
//  Copyright © 2017 Danilo Priore. All rights reserved.
//
#define tagVerseTitle   1
#define tagVerseText    2

#import "ViewController.h"

@implementation ViewController

- (void)loadView
{
    [super loadView];
    
    list = [NSMutableArray new];
    
    SOAPEngine *soap = [[SOAPEngine alloc] init];
    soap.licenseKey = @"eJJDzkPK9Xx+p5cOH7w0Q+AvPdgK1fzWWuUpMaYCq3r1mwf36Ocw6dn0+CLjRaOiSjfXaFQBWMi+TxCpxVF/FA==";
    soap.delegate = self;
    soap.actionNamespaceSlash = YES;
    
    // WFC basicHttpBinding
    //soap.version = VERSION_WCF_1_1;
    //soap.version = VERSION_1_2;
    
    // extra envelope definitions
    //soap.envelope = @"xmlns:tmp=\"http://tempuri.org/\"";
    
    // autenthication
    /*
     soap.authorizationMethod = SOAP_AUTH_WSSECURITY;
     soap.username = @"pippo";
     soap.password = @"pippo";
     */
    
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
    
    // encryption/decryption
    //soap.encryptionType = SOAP_ENCRYPT_3DES;
    //soap.encryptionPassword = @"my-password";
    
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
    
    // SOAP service from WSDL
    //[soap requestWSDL:@"http://www.prioregroup.com/services/americanbible.asmx?wsdl"
    //        operation:@"GetVerses"];
    
    // SOAP WFC service (svc)
    //[soap requestURL:@"http://www.prioregroup.com/services/AmericanBible.svc"
    //      soapAction:@"http://www.prioregroup.com/IAmericanBible/GetVerses"];
    
    // w3schools Celsius to Fahrenheit
    /*
     [soap setValue:@"30" forKey:@"Celsius"];
     [soap requestURL:@"http://www.w3schools.com/webservices/tempconvert.asmx"
     soapAction:@"http://www.w3schools.com/webservices/CelsiusToFahrenheit"
     complete:^(NSInteger statusCode, NSString *stringXML) {
     
        NSLog(@"Result: %f", [soap floatValue]);
     
     } failWithError:^(NSError *error) {
     
        NSLog(@"%@", error);
     }];
     */
    
    // WebServiceX example
    /*
     soap.actionNamespaceSlash = NO;
     [soap setValue:@"Roma" forKey:@"CityName"];
     [soap setValue:@"Italy" forKey:@"CountryName"];
     [soap requestURL:@"http://www.webservicex.com/globalweather.asmx"
     soapAction:@"http://www.webserviceX.NET/GetWeather"
     completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict) {
     
        NSLog(@"Result: %@", dict);
     
     } failWithError:^(NSError *error) {
     
        NSLog(@"%@", error);
     }];
     */
}

#pragma mark - SOAPEngine Delegate

- (void)soapEngine:(SOAPEngine *)soapEngine didFailWithError:(NSError *)error
{
    NSString *msg = [NSString stringWithFormat:@"ERROR: %@", error.localizedDescription];
    NSAlert *alert = [NSAlert new];
    [alert setMessageText:msg];
    [alert runModal];
}

- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML dictionary:(NSDictionary *)dict
{
    list = [[NSMutableArray alloc] initWithArray:[dict valueForKey:@"BibleBookChapterVerse"] ?: [dict valueForKeyPath:@"BibleBookChapterVerseEncrypted"]];
    
    if (list.count > 0) {
        
        self.bookTitle.stringValue = [[list firstObject] valueForKey:@"BookName"];
        [self.tableView reloadData];
        
    } else {
        
        NSLog(@"%@", stringXML);
        
        NSAlert *alert = [NSAlert new];
        [alert setMessageText:@"No verses founded!"];
        [alert runModal];
    }
}

- (BOOL)soapEngine:(SOAPEngine *)soapEngine didReceiveResponseCode:(NSInteger)statusCode
{
    // 200 is response Ok, 500 Server error
    // see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    // for more response codes
    if (statusCode != 200 && statusCode != 500) {
        
        NSString *msg = [NSString stringWithFormat:@"ERROR: received status code %li", (long)statusCode];
        
        NSAlert *alert = [NSAlert new];
        [alert setMessageText:msg];
        [alert runModal];
        
        return NO;
    }
    
    return YES;
}

- (NSMutableURLRequest *)soapEngine:(SOAPEngine *)soapEngine didBeforeSendingURLRequest:(NSMutableURLRequest *)request
{
    NSLog(@"%@", [request allHTTPHeaderFields]);
    
    NSString *xml = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    NSLog(@"%@", xml);
    
    return request;
}

#pragma mark - TableView Delegate and DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [list count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if ([tableColumn.identifier isEqualToString:@"VerseColumn"]) {
        
        NSDictionary *dict = [list objectAtIndex:row];
        NSTextField *verseLabel = [cellView viewWithTag:tagVerseTitle];
        NSTextField *verseText = [cellView viewWithTag:tagVerseText];
        
        NSString *chapter_verse = [NSString stringWithFormat:@"Chapter %@ Verse %@", [dict objectForKey:@"Chapter"], [dict objectForKey:@"Verse"]];
        verseLabel.stringValue = chapter_verse;
        verseText.stringValue = [dict objectForKey:@"Text"];
    }
    
    return cellView;
}


@end
