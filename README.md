**SOAPEngine**
================

This generic SOAP client allows you to access web services using a your iOS app.

With this Framework you can create iPhone and iPad Apps that supports SOAP Client Protocol. This framework able executes methods at remote web services with SOAP standard protocol.

## Updates Jun, 25, 2013
* Ability to define a basic or WSS authentication.
* Property named actionQuotes, allow the quotes in the soapAction header.

## Features
* Support both 2001 (v1.1) and 2003 (v1.2) XML schema.
* Support array, array of structs and dictionary.
* Support user-defined object. Capable of serializing complex data types and array of complex data types, even multi-level embedded structs.
* An example is included in source code.

## Requirements
* iOS 4.x, 5.x and last iOS6.
* XCode 4.1 or later
* Foundation.framework
* UIKit.framework
* libxml2.dylib

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