//
//  SOAPEngine.h
//
//  Created by Danilo Priore on 21/11/12.
//  Copyright (c) 2012-2015 Centro Studi Informatica di Danilo Priore. All rights reserved.
//
//  http://www.prioregroup.com
//  https://github.com/priore
//  https://twitter.com/DaniloPriore
//
// Version      : 1.21.0
// Changelog    : https://github.com/priore/SOAPEngine/blob/master/CHANGELOG.txt
// Updates      : https://github.com/priore/SOAPEngine
//
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
extern const NSString *SOAPEngineDidReceiveDataSizeNotification;
extern const NSString *SOAPEngineDidSendDataSizeNotification;

// UserInfo dictionary keys for Local Noficiations
extern const NSString *SOAPEngineStatusCodeKey;     // response status code
extern const NSString *SOAPEngineXMLResponseKey;    // response xml
extern const NSString *SOAPEngineXMLDictionaryKey;  // response dictionary
extern const NSString *SOAPEngineURLRequestKey;     // http request
extern const NSString *SOAPEngineURLResponseKey;    // http response
extern const NSString *SOAPEngineErrorKey;          // errors
extern const NSString *SOAPEngineDataSizeKey;       // send/receive data size
extern const NSString *SOAPEngineTotalDataSizeKey;  // send/receive total data size

typedef __block void(^SOAPEngineCompleteBlock)(NSInteger statusCode, NSString *stringXML) DEPRECATED_ATTRIBUTE;
typedef __block void(^SOAPEngineCompleteBlockWithDictionary)(NSInteger statusCode, NSDictionary *dict);
typedef __block void(^SOAPEngineFailBlock)(NSError *error);
typedef __block void(^SOAPEngineReceiveDataSizeBlock)(NSUInteger current, NSUInteger total);
typedef __block void(^SOAPEngineSendDataSizeBlock)(NSUInteger current, NSUInteger total);

typedef enum
{
    VERSION_1_1,
    VERSION_1_2,
    VERSION_WCF_1_1 // only basicHttpBinding wcf services (.svc)
} SOAPVersion;

typedef enum
{
    SOAP_AUTH_NONE,
    SOAP_AUTH_BASIC,            // located in header request (base64)
    SOAP_AUTH_BASICAUTH,        // valid only for SOAP 1.1
    SOAP_AUTH_WSSECURITY,       // digest password
    SOAP_AUTH_CUSTOM,           // sets header property for custom auth
    SOAP_AUTH_PAYPAL,           // for PayPal SOAP API
    SOAP_AUTH_TOKEN,            // with OAuth token
    SOAP_AUTH_SOCIAL            // for social account
} SOAPAuthorization;

typedef enum
{
    SOAP_ENCRYPT_NONE,
    SOAP_ENCRYPT_AES256,
    SOAP_ENCRYPT_3DES
} SOAPEnryption;

@protocol SOAPEngineDelegate;

@interface SOAPEngine : NSObject

// return the current request URL
@property (nonatomic, retain, readonly) NSURL *requestURL;

// return the current SOAP Action
@property (nonatomic, retain, readonly) NSString *soapAction;

// return the current method name
@property (nonatomic, retain, readonly) NSString *methodName;

// return the current response
@property (nonatomic, retain, readonly) NSURLResponse *response;

// adds the quotes in the SOAPAction header
// eg. SOAPAction = http://temp.org become SOAPAction = "http://temp.org".
@property (nonatomic, assign) BOOL actionQuotes;

// add last path slash for action namespace
@property (nonatomic, assign) BOOL actionNamespaceSlash;

// return the last status code of connection
// http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
@property (nonatomic, assign) NSInteger statusCode;

//sets a custom name for the user-agent (default is "SOAPEngine").
@property (nonatomic, retain) NSString *userAgent;

// sets a custom date format for dates (default yyyy-mm-dd)
// http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
@property (nonatomic, retain) NSString *dateFormat;

// sets to indicate that the nil values ​​are replaced with xsi:nil="true"
@property (nonatomic, assign) BOOL replaceNillable;

// sets the default tag name, default is "input", when using setValue without key value
@property (nonatomic, retain) NSString *defaultTagName;

// sets the prefix of the user object you want to replace
@property (nonatomic, retain) NSString *prefixObjectName;

// sets the value of replacing for the prefix of the user object
@property (nonatomic, retain) NSString *replacePrefixObjectName;

// sets the type of permission you want to use (none, wss, basic or custom).
@property (nonatomic, assign) SOAPAuthorization authorizationMethod;

// sets a custom content for the custom authorization method (xml format).
@property (nonatomic, retain) NSString *header;

// enables retrieval of the contents of the SOAP header in the server response.
@property (nonatomic, assign) BOOL responseHeader;

// enables retrieval the attributes of the tags in the SOAP response.
@property (nonatomic, assign) BOOL retrievesAttributes;

// enables the attribute xsi:type="xsd:..." in the requests.
@property (nonatomic, assign) BOOL xsdDataTypes;

// sets the time out for all requests.
@property (nonatomic, assign) NSTimeInterval requestTimeout;

// sets username and password for selected authorization method
// or for server authorization or for client certifcate password.
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *email;      // for PAYPAL auth
@property (nonatomic, retain) NSString *signature;  // for PAYPAL auth
// when calling PayPal APIs, you must authenticate each request using a set of API credentials
// PayPal associates a set of API credentials with a specific PayPal account
// you can generate credentials from this https://developer.paypal.com/docs/classic/api/apiCredentials/

// extended values for social logins
@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic, retain) NSString *socialName;
@property (nonatomic, retain) NSString *token;

// sets the custom attributes for Envelope tag, eg.
// for extra namespace definitions (xmlns:tmp="http://temp.org").
@property (nonatomic, retain) NSString *envelope;

// sets the SOAP version you want to use (v.1.1 or v.1.2).
@property (nonatomic, assign) SOAPVersion version;

// enables communication with servers that have self-signed certificates.
@property (nonatomic, assign) BOOL selfSigned;

// sets the name of the local certificate to be used for servers
// that require authorization using a client certificate (p12)
// to convert a PAYPAL certificate to a p12 use the command shown below :
// openssl pkcs12 -export -in cert_key_pem.txt -inkey cert_key_pem.txt -out paypal_cert.p12
@property (nonatomic, retain) NSString *clientCerficateName;
@property (nonatomic, retain) NSString *clientCertificatePassword;

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

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
- (void)setImage:(UIImage*)image forKey:(NSString*)key __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_4_3);
- (void)setImage:(UIImage*)image forKey:(NSString*)key attributes:(NSDictionary*)attributes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_4_3);
#endif

// clear all parameters
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
     failWithError:(SOAPEngineFailBlock)fail DEPRECATED_ATTRIBUTE;

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail DEPRECATED_ATTRIBUTE;

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail DEPRECATED_ATTRIBUTE;

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedDataSize:(SOAPEngineReceiveDataSizeBlock)receive DEPRECATED_ATTRIBUTE;

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedDataSize:(SOAPEngineReceiveDataSizeBlock)receive
    sendedDataSize:(SOAPEngineSendDataSizeBlock)sended DEPRECATED_ATTRIBUTE;

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
  receivedDataSize:(SOAPEngineReceiveDataSizeBlock)receive
    sendedDataSize:(SOAPEngineSendDataSizeBlock)sended;

// request with wsdl
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

- (void)soapEngine:(SOAPEngine*)soapEngine didFinishLoading:(NSString*)stringXML DEPRECATED_ATTRIBUTE;
- (void)soapEngine:(SOAPEngine*)soapEngine didFinishLoading:(NSString*)stringXML dictionary:(NSDictionary*)dict;
- (void)soapEngine:(SOAPEngine*)soapEngine didFailWithError:(NSError*)error;
- (void)soapEngine:(SOAPEngine*)soapEngine didReceiveDataSize:(NSUInteger)current total:(NSUInteger)total;
- (void)soapEngine:(SOAPEngine*)soapEngine didSendDataSize:(NSUInteger)current total:(NSUInteger)total;
- (BOOL)soapEngine:(SOAPEngine*)soapEngine didReceiveResponseCode:(NSInteger)statusCode;
- (NSMutableURLRequest*)soapEngine:(SOAPEngine*)soapEngine didBeforeSendingURLRequest:(NSMutableURLRequest*)request;
- (NSString*)soapEngine:(SOAPEngine*)soapEngine didBeforeParsingResponseString:(NSString*)stringXML;

@end