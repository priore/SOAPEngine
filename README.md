**SOAPEngine**
================

This generic SOAP client allows you to access web services using a your iOS app.

With this Framework you can create iPhone and iPad Apps that supports SOAP Client Protocol. This framework able executes methods at remote web services with SOAP standard protocol.

## Features
* Support both 2001 (v1.1) and 2003 (v1.2) XML schema.
* Support array, array of structs and dictionary.
* Support user-defined object. Capable of serializing complex data types and array of complex data types, even multi-level embedded structs.
* Supports ASMX Services and now also the WCF Services.
* An example of service and how to use it is included in source code.

## Requirements
* iOS 5.x, 6.x and last iOS7.
* XCode 4.6 or later
* Security.framework
* Foundation.framework
* UIKit.framework
* libxml2.dylib

## Limitations
* supports only WCF Services in basic bindings.

Below a simple example on Objective-C :

	#import <SOAPEngine/SOAPEngine.h>

	SOAPEngine *soap = [[SOAPEngine alloc] init];

	soap.userAgent = @"SOAPEngine";

	soap.delegate = self; // use SOAPEngineDelegate

	[soap setValue:@"my-value1" forKey:@"Param1"];

	[soap setIntegerValue:1234 forKey:@"Param2"];

	[soap requestURL:@"http://www.my-web.com/my-service.asmx" soapAction:@"http://www.my-web.com/My-Method-name"];
 
	#pragma mark - SOAPEngine delegates

	- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {

	        NSDictionary *result = [soapEngine dictionaryValue];
        
        	// read data from a dataset table
        
        	NSArray *list = [result valueForKeyPath:@"NewDataSet.Table"];
        
	}


**[GET IT NOW!](http://www.prioregroup.com/iphone/soapengine.aspx)**

##Change-log

- Jul, 11, 2014 (same v.1.7.0)
* added a example of VS.NET WebService in C#.

- Jun, 20, 2014 (v.1.7.0)
* added the support for sending of UIImage and UIImageView objects.
* added the conversion of special characters in a compatible html format.

- Apr, 12, 2014 (v.1.6.0)
* support for WFC services (svc) with basicHttpBinding.

- Feb, 13, 2014 (v.1.5.1)
* fixes for premature release of connections in nested blocks.

- Jan, 29, 2014 (v.1.5.0)
* added a new method named "cancel" to able cancel all delegates, blocks or notifications.
* fixes for fault codes in client SOAP response.
* added version compiled for arm64 (64-bit, only in purchased version).

- Jan, 09, 2014 (v.1.4.0)
* support for NSSet types.
* support for other more primitive types (short, long).
* fixes releases object in ARC projects.

- Dic, 22, 2013 (v.1.3.4)
* fixes for HTML special characters.
* fixes for Unicode characters.
* fixes for blocks inside blocks.

- Dic, 18, 2013 (v.1.3.3)
* fixes dictionary error in a double sequential call.

- Dic, 10, 2013 (v.1.3.2)
* Extended with two new properties to replace the prefix of the user objects.
* Decode Unicode characters in readable strings (\Uxxxx).
* fixes for results in array values.

- Dic 04, 2013 (v.1.3.1)
* Thread Safety
* Support nil/null values replaced with xsi:nil="true"

- Dic, 02, 2013 (v.1.3.0)
* Added local notifications.
* fixes last path slash for namespace actions.

- Nov, 08, 2013 (v.1.2.1)
* Implementing block programming
* fixes log message for IList (C#) elements

- Ago, 29, 2013 (v.1.2.1)
* Added the verification methods for certificate authorization.
* Update WS-Security with encrypted password (digest).
* fixes for parameters with nil values.
* fixes for inherited classes.
* fixes when hostname could not be found.

- Ago, 20, 2013 (v.1.2.0)
* Added the verification methods for trusted certificate authorization.

- Ago, 17, 2013 (v.1.1.1)
* Property named envelope, allow the define extra attributes for Envelope tag.

- Jun, 25, 2013 (v.1.1.0)
* Ability to define a basic or WSS authentication.
* Property named actionQuotes, allow the quotes in the soapAction header.

