//
//  SOAPEngine.h
//
//  Created by Danilo Priore on 21/11/12.
//  Copyright (c) 2012 Centro Studi Informatica di Danilo Priore. All rights reserved.
//  http://www.prioregroup.com
//  https://github.com/priore
//  https://twitter.com/DaniloPriore
//
// 08-20-2013 Version 1.2 (RC1)
//
// Features:
//
// 1. added the verification methods for trusted certificate authorization.
//
// 08-17-2013 Version 1.1.1
//
// Features:
//
// 1. added a property to allow the define extra attributes for Envelope tag.
//
// 06-25-2013 Version 1.1
//
// Features:
//
// 1. added a property that enables the quotes in the property SOAPAction.
// 2. adding basic and wss authorization.

#import <Foundation/Foundation.h>

typedef enum
{
    VERSION_1_1,
    VERSION_1_2
} SOAPVersion;

typedef enum
{
    SOAP_AUTH_NONE,
    SOAP_AUTH_BASIC,
    SOAP_AUTH_WSSECURITY,
    SOAP_AUTH_CUSTOM
} SOAPAuthorization;

@protocol SOAPEngineDelegate;

@interface SOAPEngine : NSObject

// adds the quotes in the SOAPAction header
// eg. SOAPAction = http://temp.org become SOAPAction = "http://temp.org".
@property (nonatomic, assign) BOOL actionQuotes;

// return the last status code of connection
// http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html.
@property (nonatomic, assign) int statusCode;

//sets a custom name for the user-agent (default is "SOAPEngine").
@property (nonatomic, retain) NSString *userAgent;

// sets a custom date format for dates (default yyyy-mm-dd)
// http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
@property (nonatomic, retain) NSString *dateFormat;

// sets the type of permission you want to use (none, wss, basic or custom).
@property (nonatomic, assign) SOAPAuthorization authorizationMethod;

// sets a custom content for the custom authorization method (xml format).
@property (nonatomic, retain) NSString *header;

// sets username and password for selected authorization method
// or for server authorization or for client certifcate password.
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

// sets the custom attributes for Envelope tag, eg.
// for extra namespace definitions (xmlns:tmp="http://temp.org").
@property (nonatomic, retain) NSString *envelope;

// sets the SOAP version you want to use (v.1.1 or v.1.2).
@property (nonatomic, assign) SOAPVersion version;

// enables communication with servers that have self-signed certificates.
@property (nonatomic, assign) BOOL selfSigned;

// sets the name of the local certificate to be used for servers
// that require authorization using a client certificate (p12).
@property (nonatomic, retain) NSString *clientCerficateName;

// sets the receiver of the delegates 
@property (nonatomic, assign) id<SOAPEngineDelegate> delegate;

// returns the value for a webservice that returns a single value
- (int)integerValue;
- (float)floatValue;
- (double)doubleValue;
- (NSString*)stringValue;
- (NSData*)dataValue;
- (NSDate*)dateValue;
- (NSNumber*)numberValue;
- (NSDictionary*)dictionaryValue;
- (id)valueForKey:(NSString*)key;
- (NSArray*)arrayValue;
- (id)valuesToObject:(id)object;

// add a parameter to post
- (void)setValue:(id)value;
- (void)setValue:(id)value forKey:(NSString *)key; // can also be used with user-defined objects
- (void)setIntegerValue:(int)value forKey:(NSString*)key;
- (void)setDoubleValue:(double)value forKey:(NSString*)key;
- (void)setFloatValue:(float)value forKey:(NSString*)key;

// clear all parameters
- (void)clearValues;

// webservice request
- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction;
- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value;
- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value forKey:(NSString*)key;

@end

@protocol SOAPEngineDelegate <NSObject>

@optional

- (void)soapEngine:(SOAPEngine*)soapEngine didFinishLoading:(NSString*)stringXML;
- (void)soapEngine:(SOAPEngine *)soapEngine didFailWithError:(NSError*)error;
- (BOOL)soapEngine:(SOAPEngine *)soapEngine didReceiveResponseCode:(int)statusCode;
- (NSMutableURLRequest*)soapEngine:(SOAPEngine *)soapEngine didBeforeSendingURLRequest:(NSMutableURLRequest*)request;

@end