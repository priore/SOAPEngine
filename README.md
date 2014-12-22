**SOAPEngine**
================

This generic `SOAP` client allows you to access web services using a your `iOS` app and `Mac OS X` app.

With this Framework you can create iPhone, iPad and Mac OS X apps that supports SOAP Client Protocol. This framework able executes methods at remote web services with SOAP standard protocol.

## Features
* Support both 2001 (v1.1) and 2003 (v1.2) `XML` schema.
* Support array, array of structs and dictionary.
* Support user-defined object. Capable of serializing complex data types and array of complex data types, even multi-level embedded structs.
* Supports `ASMX` Services, `WCF` Services (`svc`) and now also the `WSDL` definitions.
* Encrypt/Decrypt data without SSL security.
* An example of service and how to use it is included in source code.

## Requirements for iOS
* iOS 5.1.1, and later
* `XCode` 5.0 or later
* Security.framework
* Foundation.framework
* UIKit.framework
* libxml2.dylib

## Requirements for Mac OS X
* OS X 10.9 and later
* `XCode` 5.0 or later
* Security.framework
* Foundation.framework
* AppKit.framework
* Cocoa.framework
* libxml2.dylib

## Limitations
* for `WCF` services, only supports basic http bindings (`<basicHttpBinding>`).
* in `Mac OS X` unsupported image objects (instead you can use the `NSData`).

## How to use

with delegates :

``` objective-c
	#import <SOAPEngine/SOAPEngine.h>

	// standard soap service (.asmx)
	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	soap.delegate = self; // use SOAPEngineDelegate

	// each single value
	[soap setValue:@"my-value1" forKey:@"Param1"];
	[soap setIntegerValue:1234 forKey:@"Param2"];
	// service url without ?WSDL, and you can search the soapAction in the WSDL
	[soap requestURL:@"http://www.my-web.com/my-service.asmx" soapAction:@"http://www.my-web.com/My-Method-name"];
 
	#pragma mark - SOAPEngine Delegates

	- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {

	        NSDictionary *result = [soapEngine dictionaryValue];
        	// read data from a dataset table
        	NSArray *list = [result valueForKeyPath:@"NewDataSet.Table"];
	}
```

with block programming :

``` objective-c
	#import <SOAPEngine/SOAPEngine.h>
	
	// TODO: your user object
	MyClass myObject = [[MyClass alloc] init];
	
	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	soap.version = VERSION_WCF_1_1; // WCF service (.svc)
	
	// service url without ?WSDL, and you can search the soapAction in the WSDL
	[soap requestURL:@"http://www.my-web.com/my-service.svc"
		  soapAction:@"http://www.my-web.com/my-interface/my-method"
			   value:myObject
			complete:^(NSInteger statusCode, NSString *stringXML) {
		    	NSDictionary *result = [soap dictionaryValue];
				NSLog(@"%@", result);
			} failWithError:^(NSError *error) {
				NSLog(@"%@", error);
			}];
```	

directly from WSDL :

``` objective-c
	#import <SOAPEngine/SOAPEngine.h>
	
	// TODO: your user object
	MyClass myObject = [[MyClass alloc] init];
	
	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	
	// service url with WSDL, and operation (method name) without tempuri
	[soap requestWSDL:@"http://www.my-web.com/my-service.amsx?wsdl"
		    operation:@"my-method-name"
			    value:myObject
			completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict) {

              NSLog(@"Result: %@", dict);

			} failWithError:^(NSError *error) {

				NSLog(@"%@", error);
			}];
```	

with notifications :

``` objective-c
	#import <SOAPEngine/SOAPEngine.h>

	// TODO: your user object
	MyClass myObject = [[MyClass alloc] init];
	
	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	soap.version = VERSION_WCF_1_1; // WCF service (.svc)
		
    [[NSNotificationCenter defaultCenter] addObserver:self 
    									     selector:@selector(soapEngineDidFinishLoading:) 
    									         name:SOAPEngineDidFinishLoadingNotification 
    									       object:nil];
	
	// service url without ?WSDL, and you can search the soapAction in the WSDL
	[soap requestURL:@"http://www.my-web.com/my-service.svc" 
		  soapAction:@"http://www.my-web.com/my-interface/my-method"
		  	   value:myObject];
	
	#pragma mark - SOAPEngine Notifications
	
	- (void)soapEngineDidFinishLoading:(NSNotification*)notification
	{
    	SOAPEngine *engine = notification.object; // SOAPEngine object
    	NSDictionary *result = [engine dictionaryValue];
    	NSLog(@"%@", result);
	}
```	

settings for soap authentication :

``` objective-c
	#import <SOAPEngine/SOAPEngine.h>

	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	
	// authorization
	soap.authorizationMethod = SOAP_AUTH_BASIC; // basic auth
	soap.username = @"my-username";
	soap.password = @"my-password";
	
	// TODO: your code here...
	
```	

encryption/decryption data without SSL/HTTPS :

``` objective-c
	#import <SOAPEngine/SOAPEngine.h>

	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	soap.encryptionType = SOAP_ENCRYPT_AES256; // or SOAP_ENCRYPT_3DES
	soap.encryptionPassword = @"my-password";

	// TODO: your code here...
	
```	
W3Schools example :

``` objective-c
	SOAPEngine *soap = [[SOAPEngine alloc] init];
    soap.actionNamespaceSlash = YES;

    // w3schools Celsius to Fahrenheit
    [soap setValue:@"30" forKey:@"Celsius"];
    [soap requestURL:@"http://www.w3schools.com/webservices/tempconvert.asmx"  
        soapAction:@"http://www.w3schools.com/webservices/CelsiusToFahrenheit" 
        complete:^(NSInteger statusCode, NSString *stringXML) {

        NSLog(@"Result: %f", [soap floatValue]);

    } failWithError:^(NSError *error) {

        NSLog(@"%@", error);
    }];
	
```	

WebServiceX example :

``` objective-c
	SOAPEngine *soap = [[SOAPEngine alloc] init];
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
          	
```	

PAYPAL example :

``` objective-c
	SOAPEngine *soap = [[SOAPEngine alloc] init];

    // PAYPAL associates a set of API credentials with a specific PayPal account
    // you can generate credentials from this https://developer.paypal.com/docs/classic/api/apiCredentials/
    // and convert to a p12 from terminal use :
    // openssl pkcs12 -export -in cert_key_pem.txt -inkey cert_key_pem.txt -out paypal_cert.p12
    soap.authorizationMethod = SOAP_AUTH_PAYPAL;
    soap.username = @"support_api1.your-username";
    soap.password = @"your-api-password";
    soap.clientCerficateName = @"paypal_cert.p12";
    soap.clientCertificatePassword = @"certificate-password";
    soap.responseHeader = YES;
    // use paypal for urn:ebay:api:PayPalAPI namespace
    [soap setValue:@"0" forKey:@"paypal:ReturnAllCurrencies"];
    // use paypal1 for urn:ebay:apis:eBLBaseComponents namespace
    [soap setValue:@"119.0" forKey:@"paypal1:Version"]; // ns:Version in WSDL file
    // certificate : https://api.paypal.com/2.0/ sandbox https://api.sandbox.paypal.com/2.0/
    // signature : https://api-3t.paypal.com/2.0/ sandbox https://api-3t.sandbox.paypal.com/2.0/
    [soap requestURL:@"https://api.paypal.com/2.0/"
          soapAction:@"GetBalance" completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict) {
          
        NSLog(@"Result: %@", dict);
        
    } failWithError:^(NSError *error) {
    
        NSLog(@"%@", error);
    }];
          	
```	

## Install in your apps

1. add -lxml2 in Build Settings --> Other Linker Flags.
![Other Linker Flags](/screen/otherlinkerflags.png)

2. add /usr/include/libxml2 in Build Settings --> Header Search Paths.
![Header Search Paths](/screen/headersearchpaths.png)

3. add SOAPEngine.framework (for 32-bit apps) or SOAPEngine64.framework (for 64-bit apps) or SOAPEngineOSX.framework (for Mac OS X apps).
4. add Security.framework.
5. add AppKit.framework (only for Mac OS X apps, not required for iOS apps).
![Frameworks](/screen/frameworks.png)

6. in your class, use #import <SOAPEngine/SOAPEngine.h> (both iOS or Mac OS X apps).
![import](/screen/codeimport.png)

**[GET IT NOW!](http://www.prioregroup.com/iphone/soapengine.aspx)**

##Contacts

- https://twitter.com/DaniloPriore
- https://www.facebook.com/prioregroup
- http://www.prioregroup.com/
- http://it.linkedin.com/in/priore/
