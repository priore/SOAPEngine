//
//  SOAPEngine.h
//
//  Created by Danilo Priore on 21/11/12.
//  Copyright (c) 2012 Centro Studi Informatica di Danilo Priore. All rights reserved.
//  http://www.prioregroup.com
//
// 06-25-2013 Version 1.1
//
// Features:
//
// 1. add a property that enables the quotes in the property SOAPAction.
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

@property (nonatomic, assign) BOOL actionQuotes;
@property (nonatomic, assign) int statusCode;
@property (nonatomic, retain) NSString *userAgent;
@property (nonatomic, retain) NSString *dateFormat;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *header;
@property (nonatomic, assign) SOAPVersion version;
@property (nonatomic, assign) SOAPAuthorization authorizationMethod;
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