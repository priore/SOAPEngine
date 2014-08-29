//
//  SOAPEngine.h
//
//  Created by Danilo Priore on 21/11/12.
//  Copyright (c) 2012-2014 Centro Studi Informatica di Danilo Priore. All rights reserved.
//
//  http://www.prioregroup.com
//  https://github.com/priore
//  https://twitter.com/DaniloPriore
//
// Change-log
//
// 08-27-2014 v.1.8.1
// 1. added a supported version for Mac OS X.
//
// 08-12-2014 v.1.8.0
// 1. added dictionary response on delegate, notification and completion block.
// 2. added delegate and notification before parsing response data.
// 3. added encryption/decryption content data with AES256+BASE64.
// 4. fixes BASE64 conversion for NSData and UIImage/UIImageView objects.
// 5. automatic setting of the property named actionNamespaceSlash in the case of a failure of the first request.
// 6. automatic setting of the property named actionQuotes in the case where the soapAction path contains unsupported characters.
// 7. default to YES for the property named escapingHTML.
// 8. requires a license code, as required by the new EULA.
//
// 06-20-2014 v.1.7.0
// 1. added the support for sending of UIImage and UIImageView objects.
// 2. added the conversion of special characters in a compatible html format.
//
// 04-12-2014 v.1.6.0
// 1. support for WFC services (svc) with basicHttpBinding.
//
// 02-13-2014 v.1.5.1
// 1. fixes for premature release of connections in nested blocks.
//
// 01-29-2014 v.1.5.0
// 1. added a new method named "cancel" to able cancel all delegates, blocks or notifications.
// 2. fixes for fault codes in client SOAP response.
// 3. added version compiled for arm64 (64-bit, only in purchased version).
//
// 01-09-2014 v.1.4.0
// 1. support for NSSet types.
// 2. support for other more primitive types (short, long).
// 2. fixes releases object in ARC projects.
//
// 12-22-2013 v.1.3.4
// 1. fixes for HTML special characters.
// 2. fixes for Unicode characters.
// 3. fixes for blocks inside blocks.
// 
// 12-18-2013 v.1.3.3
// 1. fixes dictionary error in a double sequential call.
//
// 12-10-2013 v.1.3.2
// 1. Extended with two new properties to replace the prefix of the user objects.
// 2. Decode Unicode characters in readable strings (\Uxxxx).
// 3. fixes for results in array values.
//
// 12-04-2013 v.1.3.1
// 1. Thread Safety
// 2. Support nil/null values replaced with xsi:nil="true"
//
// 12-02-2013 v.1.3.0
// 1. added local notifications.
// 2. fixes last path slash for namespace actions.
//
// 11-08-2013 v.1.2.2
// 1. implementing block programming.
// 2. fixes log message for IList elements.
//
// 08-29-2013 v.1.2.1
// 1. added the verification methods for certificate authorization.
// 2. update WS-Security with encrypted password (digest).
// 3. fixes for parameters with nil values.
// 4. fixes for inherited classes.
// 5. fixes when hostname could not be found.
//
// NOTE: required Security.framework
//
// 08-20-2014 v.1.2.0
// 1. Added the verification methods for trusted certificate authorization.
//
// 08-17-2013 v.1.1.1
// 1. added a property to allow the define extra attributes for Envelope tag.
//
// 06-25-2013 v.1.1.0
// 1. added a property that enables the quotes in the property SOAPAction.
// 2. adding basic and wss authorization.

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
#endif

// Local Notification names
extern const NSString *SOAPEngineDidFinishLoadingNotification;
extern const NSString *SOAPEngineDidFailWithErrorNotification;
extern const NSString *SOAPEngineDidReceiveResponseCodeNotification;
extern const NSString *SOAPEngineDidBeforeSendingURLRequestNotification;
extern const NSString *SOAPEngineDidBeforeParsingResponseStringNotification;

// UserInfo dictionary keys for Local Noficiations
extern const NSString *SOAPEngineStatusCodeKey;
extern const NSString *SOAPEngineXMLResponseKey;
extern const NSString *SOAPEngineXMLDictionaryKey;
extern const NSString *SOAPEngineURLRequestKey;
extern const NSString *SOAPEngineErrorKey;

typedef __block void(^SOAPEngineCompleteBlock)(NSInteger statusCode, NSString *stringXML);
typedef __block void(^SOAPEngineCompleteBlockWithDictionary)(NSInteger statusCode, NSDictionary *dict);
typedef __block void(^SOAPEngineFailBlock)(NSError *error);

typedef enum
{
    VERSION_1_1,
    VERSION_1_2,
    VERSION_WCF_1_1 // only basicHttpBinding wcf services (.svc)
} SOAPVersion;

typedef enum
{
    SOAP_AUTH_NONE,
    SOAP_AUTH_BASIC,        // located in header request (base64)
    SOAP_AUTH_BASICAUTH,    // valid only for SOAP 1.1
    SOAP_AUTH_WSSECURITY,   // digest password
    SOAP_AUTH_CUSTOM        // sets header property for custom auth
} SOAPAuthorization;

typedef enum
{
    SOAP_ENCRYPT_NONE,
    SOAP_ENCRYPT_AES256
} SOAPEnryption;

@protocol SOAPEngineDelegate;

@interface SOAPEngine : NSObject

// adds the quotes in the SOAPAction header
// eg. SOAPAction = http://temp.org become SOAPAction = "http://temp.org".
@property (nonatomic, assign) BOOL actionQuotes;

// add last path slash for action namespace
@property (nonatomic, assign) BOOL actionNamespaceSlash;

// return the last status code of connection
// http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html.
@property (nonatomic, assign) NSInteger statusCode;

//sets a custom name for the user-agent (default is "SOAPEngine").
@property (nonatomic, retain) NSString *userAgent;

// sets a custom date format for dates (default yyyy-mm-dd)
// http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
@property (nonatomic, retain) NSString *dateFormat;

// sets to indicate that the nil values ​​are replaced with xsi:nil="true"
@property (nonatomic, assign) BOOL replaceNillable;

// sets the prefix of the user object you want to replace
@property (nonatomic, retain) NSString *prefixObjectName;

// sets the value of replacing for the prefix of the user object
@property (nonatomic, retain) NSString *replacePrefixObjectName;

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

// enables the conversion of special characters in a compatible html format (eg &amp;) 
@property (nonatomic, assign) BOOL escapingHTML;

// sets the encryption/decryption type for content data.
@property (nonatomic, assign) SOAPEnryption encryptionType;

// sets the encryption/decryption password for content data.
@property (nonatomic, strong) NSString *encryptionPassword;

// license key for full-version (no limitations).
@property (nonatomic, strong) NSString *licenseKey;

// sets the receiver of the delegates 
@property (nonatomic, assign) id<SOAPEngineDelegate> delegate;

+ (SOAPEngine *)sharedInstance;

// returns the value for a webservice that returns a single value
- (NSInteger)integerValue;
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
- (BOOL)isNull;

// add a parameter to post
- (void)setValue:(id)value;
- (void)setValue:(id)value forKey:(NSString *)key; // can also be used with user-defined objects
- (void)setIntegerValue:(NSInteger)value forKey:(NSString*)key;
- (void)setDoubleValue:(double)value forKey:(NSString*)key;
- (void)setFloatValue:(float)value forKey:(NSString*)key;
- (void)setLongValue:(long)value forKey:(NSString*)key;

#if TARGET_OS_IPHONE
- (void)setImage:(UIImage*)image forKey:(NSString*)key; // only for iOS
#endif

// clear all parameters
- (void)clearValues;

// webservice request
- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction;
- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value;
- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value forKey:(NSString*)key;

// webservice request with block
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail;

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail;

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail;

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

// cancel all delegates, blocks or notifications
- (void)cancel;

@end

@protocol SOAPEngineDelegate <NSObject>

@optional

- (void)soapEngine:(SOAPEngine*)soapEngine didFinishLoading:(NSString*)stringXML;
- (void)soapEngine:(SOAPEngine*)soapEngine didFinishLoading:(NSString*)stringXML dictionary:(NSDictionary*)dict;
- (void)soapEngine:(SOAPEngine *)soapEngine didFailWithError:(NSError*)error;
- (BOOL)soapEngine:(SOAPEngine *)soapEngine didReceiveResponseCode:(NSInteger)statusCode;
- (NSMutableURLRequest*)soapEngine:(SOAPEngine *)soapEngine didBeforeSendingURLRequest:(NSMutableURLRequest*)request;
- (NSString*)soapEngine:(SOAPEngine*)soapEngine didBeforeParsingResponseString:(NSString*)stringXML;

@end