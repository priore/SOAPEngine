//
//  SOAPEngine.h
//
//  Created by Danilo Priore on 21/11/12.
//  Copyright (c) 2012-2016 Centro Studi Informatica di Danilo Priore. All rights reserved.
//
//  http://www.prioregroup.com
//  https://github.com/priore
//  https://twitter.com/DaniloPriore
//
//  email support: support@prioregroup.com
//
// Version      : 1.31
// Changelog    : https://github.com/priore/SOAPEngine/blob/master/CHANGELOG.txt
// Updates      : https://github.com/priore/SOAPEngine
//
#define SOAPEngineFrameworkVersion @"1.31" DEPRECATED_MSG_ATTRIBUTE("SOAPEngineFrameworkVersion as deprecated please use SOAPEngine64VersionString")

#import <Foundation/Foundation.h>

#if TARGET_OS_TV
    #import <UIKit/UIKit.h>
    FOUNDATION_EXPORT double SOAPEngineTVVersionNumber;
    FOUNDATION_EXPORT const unsigned char SOAPEngineTVVersionString[];
#elif TARGET_OS_SIMULATOR || TARGET_OS_IOS
    #import <UIKit/UIKit.h>
    FOUNDATION_EXPORT double SOAPEngine64VersionNumber;
    FOUNDATION_EXPORT const unsigned char SOAPEngine64VersionString[];
#else // OSX
    FOUNDATION_EXPORT double SOAPEngineOSXVersionNumber;
    FOUNDATION_EXPORT const unsigned char SOAPEngineOSXVersionString[];
#endif

// Local Notification names
FOUNDATION_EXPORT const NSString *SOAPEngineDidFinishLoadingNotification;
FOUNDATION_EXPORT const NSString *SOAPEngineDidFailWithErrorNotification;
FOUNDATION_EXPORT const NSString *SOAPEngineDidReceiveResponseCodeNotification;
FOUNDATION_EXPORT const NSString *SOAPEngineDidBeforeSendingURLRequestNotification;
FOUNDATION_EXPORT const NSString *SOAPEngineDidBeforeParsingResponseStringNotification;
FOUNDATION_EXPORT const NSString *SOAPEngineDidReceiveDataSizeNotification;
FOUNDATION_EXPORT const NSString *SOAPEngineDidSendDataSizeNotification;

// UserInfo dictionary keys for Local Noficiations
FOUNDATION_EXPORT const NSString *SOAPEngineStatusCodeKey;     // response status code
FOUNDATION_EXPORT const NSString *SOAPEngineXMLResponseKey;    // response xml
FOUNDATION_EXPORT const NSString *SOAPEngineXMLDictionaryKey;  // response dictionary
FOUNDATION_EXPORT const NSString *SOAPEngineURLRequestKey;     // http request
FOUNDATION_EXPORT const NSString *SOAPEngineURLResponseKey;    // http response
FOUNDATION_EXPORT const NSString *SOAPEngineErrorKey;          // errors
FOUNDATION_EXPORT const NSString *SOAPEngineDataSizeKey;       // send/receive data size
FOUNDATION_EXPORT const NSString *SOAPEngineTotalDataSizeKey;  // send/receive total data size

typedef void(^SOAPEngineCompleteBlock)(NSInteger statusCode, NSString *stringXML) DEPRECATED_MSG_ATTRIBUTE("SOAPEngineCompleteBlock as deprecated please use SOAPEngineCompleteBlockWithDictionary");
typedef void(^SOAPEngineCompleteBlockWithDictionary)(NSInteger statusCode, NSDictionary *dict);
typedef void(^SOAPEngineFailBlock)(NSError *error);
typedef void(^SOAPEngineReceiveDataSizeBlock)(NSUInteger current, long long total);
typedef void(^SOAPEngineSendDataSizeBlock)(NSUInteger current, NSUInteger total);
typedef void(^SOAPEngineReceivedProgressBlock)(NSProgress *progress);
typedef void(^SOAPEngineSendedProgressBlock)(NSProgress *progress);

typedef NS_ENUM(NSInteger, SOAPVersion)
{
    VERSION_1_1,
    VERSION_1_2,
    VERSION_WCF_1_1 // only basicHttpBinding wcf services (.svc)
};

typedef NS_ENUM(NSInteger, SOAPAuthorization)
{
    SOAP_AUTH_NONE,
    SOAP_AUTH_BASIC,            // located in header request (base64)
    SOAP_AUTH_BASICAUTH,        // valid only for SOAP 1.1
    SOAP_AUTH_WSSECURITY,       // WSS with digest password
    SOAP_AUTH_WSSECURITY_TEXT,  // WSS with text password
    SOAP_AUTH_CUSTOM,           // sets header property for custom auth
    SOAP_AUTH_PAYPAL,           // for PayPal SOAP API
    SOAP_AUTH_TOKEN,            // with OAuth token
    SOAP_AUTH_SOCIAL            // for social account
};

typedef NS_ENUM(NSInteger, SOAPEnryption)
{
    SOAP_ENCRYPT_NONE,
    SOAP_ENCRYPT_AES256,
    SOAP_ENCRYPT_3DES
};

typedef NS_ENUM(NSInteger, SOAPCertificate)
{
    SOAP_CERTIFICATE_DEFAULT,
    SOAP_CERTIFICATE_PINNING // support CER or DER certificate
};

@protocol SOAPEngineDelegate;

@interface SOAPEngine : NSObject

// return the current request URL
@property (nonatomic, strong, readonly, getter=currentRequestURL) NSURL *requestURL DEPRECATED_MSG_ATTRIBUTE("requestURL property as deprecated please use currentRequestURL");
@property (nonatomic, strong, readonly) NSURL *currentRequestURL;

// return the current SOAP Action
@property (nonatomic, strong, readonly) NSString *soapAction;

// return the current method name
@property (nonatomic, strong, readonly) NSString *methodName;

// return the current response
@property (nonatomic, strong, readonly) NSURLResponse *response;

// adds the quotes in the SOAPAction header
// eg. SOAPAction = http://temp.org become SOAPAction = "http://temp.org".
@property (nonatomic, assign) BOOL actionQuotes;

// add last path slash for action namespace
// eg. xmlns="http://temp.org" become xmlns="http://temp.org/"
@property (nonatomic, assign) BOOL actionNamespaceSlash;

// add attributes on SOAP Action TAG
// eg. <soapAction attr="value">...</soapAction>
@property (nonatomic, strong) NSDictionary *actionAttributes;

// return the last status code of connection
// http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
@property (nonatomic, assign) NSInteger statusCode;

//sets a custom name for the user-agent (default is "SOAPEngine").
@property (nonatomic, strong) NSString *userAgent;

// sets a custom date format for dates (default yyyy-mm-dd)
// http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
@property (nonatomic, strong) NSString *dateFormat;

// sets to indicate that the nil values ​​are replaced with xsi:nil="true"
@property (nonatomic, assign) BOOL replaceNillable;

// sets the default tag name, default is "input", when using setValue without key value or for array items
@property (nonatomic, strong) NSString *defaultTagName;

// sets the prefix of the user object you want to replace
@property (nonatomic, strong) NSString *prefixObjectName;

// sets the value of replacing for the prefix of the user object
@property (nonatomic, strong) NSString *replacePrefixObjectName;

// sets the type of permission you want to use (none, wss, basic or custom).
@property (nonatomic, assign) SOAPAuthorization authorizationMethod;

// sets a custom content for the custom authorization method (xml string or dictionary).
@property (nonatomic, strong) id header;

// enables retrieval of the contents of the SOAP header in the server response.
@property (nonatomic, assign) BOOL responseHeader;

// enables retrieval the attributes of the tags in the SOAP response.
@property (nonatomic, assign) BOOL retrievesAttributes;

// the default SOAP namespace <soap:Envelope...
@property (nonatomic, strong) NSString *soapNamespace;

// enables the attribute xsi:type="xsd:..." in the requests.
@property (nonatomic, assign) BOOL xsdDataTypes;

// sets the time out for all requests.
@property (nonatomic, assign) NSTimeInterval requestTimeout;

// sets username and password for selected authorization method
// or for server authorization or for client certifcate password.
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;      // for PAYPAL auth
@property (nonatomic, strong) NSString *signature;  // for PAYPAL auth
// when calling PayPal APIs, you must authenticate each request using a set of API credentials
// PayPal associates a set of API credentials with a specific PayPal account
// you can generate credentials from this https://developer.paypal.com/docs/classic/api/apiCredentials/

// extended values for social logins
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *socialName;
@property (nonatomic, strong) NSString *token;

// sets the custom attributes for Envelope tag, eg.
// for extra namespace definitions eg. xmlns:tmp="http://temp.org".
@property (nonatomic, strong) NSString *envelope;

// sets the SOAP version you want to use (v.1.1 or v.1.2).
@property (nonatomic, assign) SOAPVersion version;

// enables communication with servers that have self-signed certificates.
@property (nonatomic, assign) BOOL selfSigned;

// sets the name of the local certificate to be used for servers
// that require authorization using a client certificate (p12)
// to convert a PAYPAL certificate to a p12 use the command shown below :
// openssl pkcs12 -export -in cert_key_pem.txt -inkey cert_key_pem.txt -out paypal_cert.p12
@property (nonatomic, strong) NSString *clientCerficateName;
@property (nonatomic, strong) NSString *clientCertificatePassword;
@property (nonatomic, assign) SOAPCertificate clientCertificateMode;

// enables the conversion of special characters in a compatible html format (eg &amp;) 
@property (nonatomic, assign) BOOL escapingHTML;

// sets the encryption/decryption type for content data.
@property (nonatomic, assign) SOAPEnryption encryptionType;

// sets the encryption/decryption password for content data.
@property (nonatomic, strong) NSString *encryptionPassword;

// license key for full-version (no limitations).
// buy a license from http://www.prioregroup.com/iphone/soapengine.aspx
@property (nonatomic, strong) NSString *licenseKey;

// sets the receiver of the delegates 
@property (nonatomic, weak) id<SOAPEngineDelegate> delegate;

+ (SOAPEngine *)sharedInstance;
+ (SOAPEngine *)manager;

// returns the value for a webservice that returns a single value
- (NSInteger)integerValue;
- (float)floatValue;
- (double)doubleValue;
- (BOOL)booleanValue;
- (NSString*)stringValue;
- (NSData*)dataValue;
- (NSDate*)dateValue;
- (NSNumber*)numberValue;
- (NSDictionary*)dictionaryValue;
- (id)valueForKey:(NSString*)key;
- (NSArray*)arrayValue;
- (id)valuesToObject:(id)object;
- (BOOL)isNull;

// add a parameter to post
- (void)setIntegerValue:(NSInteger)value forKey:(NSString*)key;
- (void)setDoubleValue:(double)value forKey:(NSString*)key;
- (void)setFloatValue:(float)value forKey:(NSString*)key;
- (void)setLongValue:(long)value forKey:(NSString*)key;

// add a parameter to post, can also be used with user-defined objects
- (void)setValue:(id)value;
- (void)setValue:(id)value forKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key attributes:(NSDictionary*)attributes;
- (void)setValue:(id)value forKey:(NSString *)key subKeyName:(NSString*)subKeyName;
- (void)setValue:(id)value forKey:(NSString *)key subKeyName:(NSString*)subKeyName attributes:(NSDictionary*)attrbitues;

#if TARGET_OS_SIMULATOR || TARGET_OS_IOS || TARGET_OS_TV
- (void)setImage:(UIImage*)image forKey:(NSString*)key __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_4_3);
- (void)setImage:(UIImage*)image forKey:(NSString*)key attributes:(NSDictionary*)attributes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_4_3);
#endif

// return a formatted dictionary for a sub-child with attributes
// eg. ["key": ["value": key-value, "attributes": ["attr": attr-value]]]
// this generates an XML like this: <key attr="attr-value">key-value</key>
- (NSDictionary*)dictionaryForKey:(NSString*)key value:(id)value attributes:(NSDictionary*)attributes;

// clear all parameters, usually used before a new request with the same instance.
- (void)clearValues;

// webservice request (async)
- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction;
- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value;
- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value forKey:(NSString*)key;

// webservice request (sync)
- (NSDictionary*)syncRequestURL:(id)asmxURL soapAction:(NSString*)soapAction error:(NSError**)error;
- (NSDictionary*)syncRequestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value error:(NSError**)error;
- (NSDictionary*)syncRequestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value forKey:(NSString*)key error:(NSError**)error;

// webservice request with block
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail DEPRECATED_MSG_ATTRIBUTE("requestURL:soapAction:complete:failWithError: as deprecated please use requestURL:soapAction:completeWithDictionary:failWithError:");

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail DEPRECATED_MSG_ATTRIBUTE("requestURL:soapAction:value:complete:failWithError: as deprecated please use requestURL:soapAction:value:completeWithDictionary:failWithError:");

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail DEPRECATED_MSG_ATTRIBUTE("requestURL:soapAction:value:forKey:complete:failWithError: as deprecated please use requestURL:soapAction:value:forKey:completeWithDictionary:failWithError:");

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedDataSize:(SOAPEngineReceiveDataSizeBlock)receive DEPRECATED_MSG_ATTRIBUTE("requestURL:soapAction:value:forKey:complete:failWithError:receivedDataSize: as deprecated please use requestURL:soapAction:value:forKey:completeWithDictionary:failWithError:receivedDataSize:");

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedDataSize:(SOAPEngineReceiveDataSizeBlock)receive
    sendedDataSize:(SOAPEngineSendDataSizeBlock)sended DEPRECATED_MSG_ATTRIBUTE("requestURL:soapAction:value:forKey:complete:failWithError:receivedDataSize:sendedDataSize: as deprecated please use requestURL:soapAction:value:forKey:completeWithDictionary:failWithError:receivedDataSize:sendedDataSize:");

// webservice request with block and dictionary
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail;

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail;

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail;

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedDataSize:(SOAPEngineReceiveDataSizeBlock)receive;

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedProgress:(SOAPEngineReceivedProgressBlock)receive;

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedDataSize:(SOAPEngineReceiveDataSizeBlock)receive
    sendedDataSize:(SOAPEngineSendDataSizeBlock)sended;

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedProgress:(SOAPEngineReceivedProgressBlock)receive
    sendedProgress:(SOAPEngineSendedProgressBlock)sended;

// request with WSDL
// note: better use requestURL, read this https://github.com/priore/SOAPEngine#optimizations
- (void)requestWSDL:(id)wsdlURL operation:(NSString*)operation;

- (void)requestWSDL:(id)wsdlURL
          operation:(NSString *)operation
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
      failWithError:(SOAPEngineFailBlock)fail;

- (void)requestWSDL:(id)wsdlURL
          operation:(NSString *)operation
              value:(id)value
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
      failWithError:(SOAPEngineFailBlock)fail;

- (void)requestWSDL:(id)wsdlURL
          operation:(NSString *)operation
              value:(id)value
             forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
      failWithError:(SOAPEngineFailBlock)fail;

// sets logins
- (void)login:(NSString*)username
     password:(NSString*)password;

- (void)login:(NSString*)username
     password:(NSString*)password
authorization:(SOAPAuthorization)authorization;

// for PAYPAL login
- (void)login:(NSString*)username
     password:(NSString*)password
        email:(NSString*)email
    signature:(NSString*)signature;

// cancel all delegates, blocks or notifications
- (void)cancel;

@end

@protocol SOAPEngineDelegate <NSObject>

@optional

- (void)soapEngine:(SOAPEngine*)soapEngine didFinishLoading:(NSString*)stringXML DEPRECATED_MSG_ATTRIBUTE("soapEngine:didFinishLoading: as deprecated please use soapEngine:didFinishLoading:dictionary:");
- (void)soapEngine:(SOAPEngine*)soapEngine didFinishLoading:(NSString*)stringXML dictionary:(NSDictionary*)dict;
- (void)soapEngine:(SOAPEngine*)soapEngine didFailWithError:(NSError*)error;
- (void)soapEngine:(SOAPEngine*)soapEngine didReceiveDataSize:(NSUInteger)current total:(long long)total;
- (void)soapEngine:(SOAPEngine*)soapEngine didSendDataSize:(NSUInteger)current total:(NSUInteger)total;
- (BOOL)soapEngine:(SOAPEngine*)soapEngine didReceiveResponseCode:(NSInteger)statusCode;
- (NSMutableURLRequest*)soapEngine:(SOAPEngine*)soapEngine didBeforeSendingURLRequest:(NSMutableURLRequest*)request;
- (NSString*)soapEngine:(SOAPEngine*)soapEngine didBeforeParsingResponseString:(NSString*)stringXML DEPRECATED_MSG_ATTRIBUTE("soapEngine:didBeforeParsingResponseString: as deprecated please use soapEngine:didBeforeParsingResponseData:");
- (NSData*)soapEngine:(SOAPEngine*)soapEngine didBeforeParsingResponseData:(NSData*)data;


@end
