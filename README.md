**SOAPEngine**
================

This generic [SOAP](http://www.wikipedia.org/wiki/SOAP) client allows you to access web services using a your [iOS](http://www.wikipedia.org/wiki/IOS) app, [Mac OS X](http://www.wikipedia.org/wiki/OS_X) app and [Apple TV](http://www.apple.com/tv/) app.

With this Framework you can create [iPhone](http://www.wikipedia.org/wiki/IPhone), [iPad](http://www.wikipedia.org/wiki/IPad), [Mac OS X](http://www.wikipedia.org/wiki/OS_X) and [AppleTv](http://www.apple.com/tv/) apps that supports [SOAP](http://www.wikipedia.org/wiki/SOAP) Client Protocol. This framework able executes methods at remote web services with [SOAP](http://www.wikipedia.org/wiki/SOAP) standard protocol.

## Features
---
* Support both 2001 (v1.1) and 2003 (v1.2) [XML](http://www.wikipedia.org/wiki/XML) schema.
* Support array, array of structs, dictionary and sets.
* Support for user-defined object with serialization of complex data types and array of complex data types, even embedded multilevel structures.
* Supports [ASMX](http://www.wikipedia.org/wiki/ASP.NET#Other_files) Services, [WCF](http://www.wikipedia.org/wiki/Windows_Communication_Foundation) Services ([SVC](http://www.wikipedia.org/wiki/ASP.NET#Other_files)) and now also the [WSDL](http://www.wikipedia.org/wiki/Web_Services_Description_Language) definitions.
* Supports [Basic](http://www.wikipedia.org/wiki/Basic_access_authentication), [Digest](http://www.wikipedia.org/wiki/Digest_access_authentication) and [NTLM](http://www.wikipedia.org/wiki/Integrated_Windows_Authentication) Authentication, [WS-Security](http://www.wikipedia.org/wiki/WS-Security), Client side Certificate and custom security header.
* Supports [iOS](http://www.wikipedia.org/wiki/IOS) Social Account to send [OAuth2.0](http://www.wikipedia.org/wiki/OAuth) token on the request.
* [AES256](http://www.wikipedia.org/wiki/Advanced_Encryption_Standard) or [3DES](http://www.wikipedia.org/wiki/Triple_DES) Encrypt/Decrypt data without [SSL](http://www.wikipedia.org/w/index.php?title=Transport_Layer_Security) security.
* An example of service and how to use it is included in source code.

## Requirements for [iOS](http://www.wikipedia.org/wiki/IOS)
---
* [iOS](http://www.wikipedia.org/wiki/IOS) 7.1, and later
* [Xcode](http://www.wikipedia.org/wiki/Xcode) 7.1 or later
* Security.framework
* Accounts.framework
* Foundation.framework
* UIKit.framework
* libxml2.dylib

## Requirements for [Mac OS X](http://www.wikipedia.org/wiki/OS_X)
---
* [OS X](http://www.wikipedia.org/wiki/OS_X) 10.9 and later
* [Xcode](http://www.wikipedia.org/wiki/Xcode) 7.1 or later
* Security.framework
* Accounts.framework
* Foundation.framework
* AppKit.framework
* Cocoa.framework
* libxml2.dylib

## Requirements for [Apple TV](http://www.apple.com/tv/)
---
* [iOS](http://www.wikipedia.org/wiki/IOS) 9.0, and later
* [Xcode](http://www.wikipedia.org/wiki/Xcode) 7.1 or later
* Security.framework
* Foundation.framework
* UIKit.framework
* libxml2.dylib

## Limitations
---
* for [WCF](http://www.wikipedia.org/wiki/Windows_Communication_Foundation) services, only supports basic http bindings ([basicHttpBinding](https://msdn.microsoft.com/library/ms731361.aspx)).
* in [Mac OS X](http://www.wikipedia.org/wiki/OS_X) unsupported image objects, instead you can use the [NSData](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSData_Class/index.html).

## Security for Xcode 7.x
---
The new Xcode 7 requires an additional setting for the apps, if this setting does not exist you will see a log message like this:

`App Transport Security has blocked a cleartext HTTP (http://) resource load since it is insecure. Temporary exceptions can be configured via your app's Info.plist file.`

To resolve this, add few keys in info.plist, the steps are:

1. Open `info.plist` file of your project.
2. Add a Key called `NSAppTransportSecurity` as a Dictionary.
3. Add a Subkey called `NSAllowsArbitraryLoads` as Boolean and set its value to YES as like following image.

![NSAppTransportSecurity](https://github.com/priore/SOAPEngine/raw/master/screen/NSAppTransportSecurity.png)

ref link: http://stackoverflow.com/a/32631185/4069848

## How to use
---
with [**Delegates**](https://developer.apple.com/library/ios/documentation/General/Conceptual/CocoaEncyclopedia/DelegatesandDataSources/DelegatesandDataSources.html) :

``` objective-c
	#import <SOAPEngine64/SOAPEngine.h>

	// standard soap service (.asmx)
	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	soap.delegate = self; // use SOAPEngineDelegate

	// each single value
	[soap setValue:@"my-value1" forKey:@"Param1"];
	[soap setIntegerValue:1234 forKey:@"Param2"];
	// service url without ?WSDL, and you can search the soapAction in the WSDL
	[soap requestURL:@"http://www.my-web.com/my-service.asmx" 
		  soapAction:@"http://www.my-web.com/My-Method-name"];
 
	#pragma mark - SOAPEngine Delegates

	- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {

	        NSDictionary *result = [soapEngine dictionaryValue];
        	// read data from a dataset table
        	NSArray *list = [result valueForKeyPath:@"NewDataSet.Table"];
	}
```

with [**Block programming**](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html) :

``` objective-c
	#import <SOAPEngine64/SOAPEngine.h>
	
	// TODO: your user object
	MyClass myObject = [[MyClass alloc] init];
	
	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	soap.version = VERSION_WCF_1_1; // WCF service (.svc)
	
	// service url without ?WSDL, and you can search the soapAction in the WSDL
	[soap requestURL:@"http://www.my-web.com/my-service.svc"
		  soapAction:@"http://www.my-web.com/my-interface/my-method"
			   value:myObject
			completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict) {
				NSLog(@"%@", dict);
			} failWithError:^(NSError *error) {
				NSLog(@"%@", error);
			}];
```	

directly from [**WSDL**](http://www.wikipedia.org/wiki/Web_Services_Description_Language) (*not recommended is slow*) :

``` objective-c
	#import <SOAPEngine64/SOAPEngine.h>
	
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

with [**Notifications**](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSNotificationCenter_Class/index.html) :

``` objective-c
	#import <SOAPEngine64/SOAPEngine.h>

	// TODO: your user object
	MyClass myObject = [[MyClass alloc] init];
	
	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	soap.version = VERSION_WCF_1_1; // WCF service (.svc)
		
    [[NSNotificationCenter defaultCenter] 
    			addObserver:self 
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

[**Synchronous**]() request :

``` objective-c
	#import <SOAPEngine64/SOAPEngine.h>
	
	NSError *error = nil;
    SOAPEngine *soap = [[SOAPEngine alloc] init];
    soap.responseHeader = YES; // use only for non standard MS-SOAP service like PHP
    NSDictionary *dict = [soap syncRequestURL:@"http://www.my-web.com/my-service.amsx" 
    						soapAction:@"http://tempuri.org/my-method" error:&error];
    NSLog(@"error: %@, result: %@", error, dict)
```

[**Swift 3**](http://www.wikipedia.org/wiki/Swift_programming_language) language :

``` swift
        var soap = SOAPEngine()
        soap.userAgent = "SOAPEngine"
        soap.actionNamespaceSlash = true
        soap.version = VERSION_1_1
        soap.responseHeader = true // use only for non standard MS-SOAP service
        
        soap.setValue("param-value", forKey: "param-name")
        soap.requestURL("http://www.my-web.com/my-service.asmx",
            soapAction: "http://www.my-web.com/My-Method-name",
            completeWithDictionary: { (statusCode : Int, 
            					 dict : [AnyHashable : Any]?) -> Void in
                
                var result:Dictionary = dict! as Dictionary
                print(result)
                
            }) { (error : Error?) -> Void in
                
                print(error)
        }
```
	
settings for [**SOAP Authentication**](http://www.whitemesa.com/soapauth.html) :

``` objective-c
	#import <SOAPEngine64/SOAPEngine.h>

	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	
	// authorization
	soap.authorizationMethod = SOAP_AUTH_BASIC; // basic auth
	soap.username = @"my-username";
	soap.password = @"my-password";
	
	// TODO: your code here...
	
```	

settings for Social [**OAuth2.0**](http://www.wikipedia.org/wiki/OAuth) token :

``` objective-c
	#import <SOAPEngine64/SOAPEngine.h>
	#import <Accounts/Accounts.h>

	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	
	// token authorization
	soap.authorizationMethod = SOAP_AUTH_SOCIAL;
	soap.apiKey = @"1234567890"; // your apikey https://dev.twitter.com/
	soap.socialName = ACAccountTypeIdentifierTwitter;
	
	// TODO: your code here...
	
```	

[**Encryption/Decryption**](https://it.wikipedia.org/wiki/Advanced_Encryption_Standard) data without SSL/HTTPS :

``` objective-c
	#import <SOAPEngine64/SOAPEngine.h>

	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	soap.encryptionType = SOAP_ENCRYPT_AES256; // or SOAP_ENCRYPT_3DES
	soap.encryptionPassword = @"my-password";

	// TODO: your code here...
	
```	

Params with [**Attributes**](http://www.w3schools.com/xml/xml_attributes.asp) :

``` objective-c
    // book
    NSMutableDictionary *book = [NSMutableDictionary dictionaryWithObject:@"Genesis" forKey:@"name"];
    // chapter
    NSDictionary *attr = @{@"order": @"asc"};
    NSDictionary *child = [soap dictionaryForKey:@"chapter" value:@"1" attributes:attr];
    [book addEntriesFromDictionary:child]; // add chapter to book
    // book attributes
    [soap setValue:book forKey:@"Book" attributes:@{@"rack": @"2"}];
```
it builds a request like this:
``` xml
    <Book rack="2">
        <name>Genesis</name>
        <chapter order="asc">1</chapter>
    </Book>
```

[**W3Schools**](http://www.w3schools.com) example :

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

[**WebServiceX**](http://www.webservicex.net) example :

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

[**BarCode**](http://www.wikipedia.org/wiki/Barcode) with [**WebServiceX**](http://www.webservicex.net) example :

``` objective-c
	 SOAPEngine *soap = [[SOAPEngine alloc] init];
     soap.actionNamespaceSlash = NO;

     NSDictionary *barCodeParam = @{
     	@"Height" : @(100),
     	@"Width" : @(150),
     	@"Angle" : @(0),
     	@"Ratio" : @(5),
     	@"Module" : @(0),
     	@"Left" : @(0),
     	@"Top" : @(0),
     	@"CheckSum" : @"true",
     	@"FontName" : @"Arial",
     	@"FontSize" : @(20),
     	@"BarColor" : @"black",
     	@"BGColor" : @"white",
     	@"barcodeOption" : @"None",
     	@"barcodeType" : @"CodeEAN13",
     	@"checkSumMethod" : @"None",
     	@"showTextPosition" : @"BottomCenter",
     	@"BarCodeImageFormat" : @"PNG" };
     [soap setValue:barCodeParam forKey:@"BarCodeParam"];
     [soap setValue:@"9783161484100" forKey:@"BarCodeText"];
     [soap requestURL:@"http://www.webservicex.net/genericbarcode.asmx"
     soapAction:@"http://www.webservicex.net/GenerateBarCode"
        completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict) {
     
         NSString *imgBase64 = [soap stringValue];
         NSData *base64 = [[NSData alloc] initWithBase64Encoding:imgBase64];
         UIImage *barCodeImage = [[UIImage alloc] initWithData:base64];
     
     } failWithError:^(NSError *error) {
         NSLog(@"Error: %@", error);
     }];
     
```	

[**PAYPAL**](http://www.paypal.com) example with certificate :

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

[**Magento 2**](http://devdocs.magento.com) login example :

``` objective-c
	SOAPEngine *soap = [[SOAPEngine alloc] init];
    soap.selfSigned = YES; // only for invalid https certificates
    soap.responseHeader = YES;
    soap.actionNamespaceSlash = NO;
    soap.envelope = @"xmlns:urn=\"urn:Magento\"";
    [soap setValue:@"your-username" forKey:@"username"];
    [soap setValue:@"your-apykey" forKey:@"apiKey"];
    [soap requestURL:@"https://your-magentohost/api/v2_soap/"
          soapAction:@"urn:Mage_Api_Model_Server_V2_HandlerAction#login"
completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict)
	{
        NSLog(@"Login return: %@", [soap stringValue]);
        
    } failWithError:^(NSError *error) {
        
        NSLog(@"%@", error);
    }];
```	

[**Upload file**]() :

``` objective-c
	SOAPEngine *soap = [[SOAPEngine alloc] init];

	// read local file
    NSData *data = [NSData dataWithContentsOfFile:@"my_video.mp4"];

	// send file data
    [soap setValue:data forKey:@"video"];
    [soap requestURL:@"http://www.my-web.com/my-service.asmx"
          soapAction:@"http://www.my-web.com/UploadFile"
          completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict) {
              
              NSLog(@"Result: %@", dict);
              
          } failWithError:^(NSError *error) {
    
              NSLog(@"%@", error);
          }];
          	
```	

[**Download file**]() :

``` objective-c
	SOAPEngine *soap = [[SOAPEngine alloc] init];

	// send filename to remote webservice
    [soap setValue:"my_video.mp4" forKey:@"filename"];
    [soap requestURL:@"http://www.my-web.com/my-service.asmx"
          soapAction:@"http://www.my-web.com/DownloadFile"
          completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict) {
            
            // local writable directory
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *filePath = [[paths firstObject] stringByAppendingPathComponent:@"my_video.mp4"];

			// the service returns file data in the tag named video
			NSData *data = dict[@"video"];
		    [data writeToFile:@"my_video.mp4" atomically:YES];
              
          } failWithError:^(NSError *error) {
    
              NSLog(@"%@", error);
          }];
          	
```	

## Optimizations
---
First of all, if you note a slowdown in the response of the request, try to change the value of the property named `actionNamespaceSlash`.
After, when using the method named `requestWSDL` three steps are performed : 

1. retrieve the WSDL with an http request.
2. processing to identify the soapAction.
3. calls the method with an http request.

this is not optimized, very slow, instead you can use the optimization below : 

1. retrieving manually the SOAPAction directly from WSDL (once with your favorite browser).
2. use the method named requestURL instead of requestWSDL without WSDL extension.

## Install in your apps
---
###With Cocoapods###

Read the ["Getting Started" guide](https://github.com/priore/SOAPEngine/wiki/Cocoapods-Installation-guide)

###Cocoapods and Swift###

Read the [Integrating SOAPEngine with a Swift project](https://github.com/priore/SOAPEngine/wiki/Integrating-SOAPEngine-with-a-Swift-project)

###Standard installation###

Read the ["Standard Installation" guide](https://github.com/priore/SOAPEngine/wiki/Standard-Installation)

## Licenses
---
Trial (simulator) | Single App | Enterprise (multi App) | Full Source Code
------------- | ------------- | ------------- | ------------- 
[![TRIAL LICENSE](https://github.com/priore/SOAPEngine/raw/master/screen/freetrial.png)](https://github.com/priore/SOAPEngine/archive/master.zip)  | [![BUY SINGLE LICENSE](https://github.com/priore/SOAPEngine/raw/master/screen/1299.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=G3RXTN3YD7VRG) | [![BUY ENTERPRISE LICENSE](https://github.com/priore/SOAPEngine/raw/master/screen/7799.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6YH9LJRNXPTHE) | [Contact US](mailto:support@prioregroup.com)

##Contacts
---
[![TWITTER](https://github.com/priore/SOAPEngine/raw/master/screen/twitter.png)](https://twitter.com/DaniloPriore)      [![FACEBOOK](https://github.com/priore/SOAPEngine/raw/master/screen/facebook.png)](https://www.facebook.com/prioregroup)      [![LINKED-IN](https://github.com/priore/SOAPEngine/raw/master/screen/linked-in.png)](http://it.linkedin.com/in/priore/)

