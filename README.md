**SOAPEngine**
================

This generic `SOAP` client allows you to access web services using a your `iOS` app.

With this Framework you can create iPhone and iPad Apps that supports SOAP Client Protocol. This framework able executes methods at remote web services with SOAP standard protocol.

## Features
* Support both 2001 (v1.1) and 2003 (v1.2) `XML` schema.
* Support array, array of structs and dictionary.
* Support user-defined object. Capable of serializing complex data types and array of complex data types, even multi-level embedded structs.
* Supports `ASMX` Services and now also the `WCF` Services (`svc`).
* An example of service and how to use it is included in source code.

## Requirements for iOS
* iOS 5.x, and later
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



How to use with delegates :

``` objective-c
	#import <SOAPEngine/SOAPEngine.h>

	// standard soap service (.asmx)
	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	soap.delegate = self; // use SOAPEngineDelegate

	// each single value
	[soap setValue:@"my-value1" forKey:@"Param1"];
	[soap setIntegerValue:1234 forKey:@"Param2"];
	[soap requestURL:@"http://www.my-web.com/my-service.asmx" soapAction:@"http://www.my-web.com/My-Method-name"];
 
	#pragma mark - SOAPEngine Delegates

	- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {

	        NSDictionary *result = [soapEngine dictionaryValue];
        	// read data from a dataset table
        	NSArray *list = [result valueForKeyPath:@"NewDataSet.Table"];
	}
```

or with block programming :

``` objective-c
	#import <SOAPEngine/SOAPEngine.h>
	
	// TODO: your user object
	MyClass myObject = [[MyClass alloc] init];
	
	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	soap.version = VERSION_WCF_1_1; // WCF service (.svc)
	
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

or with notifications :

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

encryption/decryption data :

``` objective-c
	#import <SOAPEngine/SOAPEngine.h>

	SOAPEngine *soap = [[SOAPEngine alloc] init];
	soap.userAgent = @"SOAPEngine";
	soap.encryptionType = SOAP_ENCRYPT_AES256;
	soap.encryptionPassword = @"my-password";

	// TODO: your code here...
	
```	

**[GET IT NOW!](http://www.prioregroup.com/iphone/soapengine.aspx)**

##Contacts

- https://twitter.com/DaniloPriore
- https://www.facebook.com/prioregroup
- http://www.prioregroup.com/
- http://it.linkedin.com/in/priore/
