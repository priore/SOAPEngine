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
// Version      : 1.45
// Changelog    : https://github.com/priore/SOAPEngine/blob/master/CHANGELOG.txt
// Updates      : https://github.com/priore/SOAPEngine
//
#define SOAPEngineFrameworkVersion @"1.45"

#import <Foundation/Foundation.h>

#if TARGET_OS_TV || TARGET_OS_SIMULATOR || TARGET_OS_IOS
    #if __has_include(<UIKit/UIKit.h>)
        #import <UIKit/UIKit.h>
    #endif
#endif

#pragma mark - Notification Constants

/// local notification generated when all data is downloaded.
FOUNDATION_EXPORT NSString *const SOAPEngineDidFinishLoadingNotification;
/// local notification generated when an error occurs.
FOUNDATION_EXPORT NSString *const SOAPEngineDidFailWithErrorNotification;
/// local notification generated when the service answer.
FOUNDATION_EXPORT NSString *const SOAPEngineDidReceiveResponseCodeNotification;
/// local notification generated when before calling the service.
FOUNDATION_EXPORT NSString *const SOAPEngineDidBeforeSendingURLRequestNotification;
/// local notification generated when before parsing received data.
FOUNDATION_EXPORT NSString *const SOAPEngineDidBeforeParsingResponseStringNotification;
/// local notification generated during downloading data.
FOUNDATION_EXPORT NSString *const SOAPEngineDidReceiveDataSizeNotification;
/// local notification generated during sending data
FOUNDATION_EXPORT NSString *const SOAPEngineDidSendDataSizeNotification;

#pragma mark - Notifications Keys Constants

/// response status code key in the userInfo of notifications
FOUNDATION_EXPORT NSString *const SOAPEngineStatusCodeKey;
/// unavailable, plese use SOAPEngineXMLDictionaryKey instead.
FOUNDATION_EXPORT NSString *const SOAPEngineXMLResponseKey UNAVAILABLE_ATTRIBUTE;
/// complete response dictionary key in the userInfo of notifications
FOUNDATION_EXPORT NSString *const SOAPEngineXMLDictionaryKey;
/// complete response data key in the userInfo of notifications
FOUNDATION_EXPORT NSString *const SOAPEngineXMLDatayKey;
/// http request object key in the userInfo of notifications
FOUNDATION_EXPORT NSString *const SOAPEngineURLRequestKey;
/// http response object key in the userInfo of notifications
FOUNDATION_EXPORT NSString *const SOAPEngineURLResponseKey;
/// error key in the userInfo of notifications
FOUNDATION_EXPORT NSString *const SOAPEngineErrorKey;
/// send/receive data size key in the userInfo of notifications
FOUNDATION_EXPORT NSString *const SOAPEngineDataSizeKey;
/// send/receive total data size key in the userInfo of notifications
FOUNDATION_EXPORT NSString *const SOAPEngineTotalDataSizeKey;

#pragma mark - Blocks Defines

typedef void(^SOAPEngineCompleteBlockWithDictionary)(NSInteger statusCode, NSDictionary *dict);
typedef void(^SOAPEngineCompleteBlock)(NSInteger statusCode, NSString *stringXML) UNAVAILABLE_ATTRIBUTE;

typedef void(^SOAPEngineFailBlock)(NSError *error);
typedef void(^SOAPEngineReceiveDataSizeBlock)(NSUInteger current, long long total);
typedef void(^SOAPEngineSendDataSizeBlock)(NSUInteger current, NSUInteger total);
typedef void(^SOAPEngineReceivedProgressBlock)(NSProgress *progress);
typedef void(^SOAPEngineSendedProgressBlock)(NSProgress *progress);

#pragma mark - Enums

/// SOAP versions.
typedef NS_ENUM(NSInteger, SOAPVersion)
{
    /// SOAP version 1.1.
    VERSION_1_1,
    /// SOAP version 1.2.
    VERSION_1_2,
    /// SOAP version 1.1 WCF (.svc) only basicHttpBinding.
    VERSION_WCF_1_1
};

/// authorization types.
typedef NS_ENUM(NSInteger, SOAPAuthorization)
{
    /// none authentication.
    SOAP_AUTH_NONE,
    /// Basic authentication (base64).
    SOAP_AUTH_BASIC,
    /// Basic authentication valid only for SOAP 1.1.
    SOAP_AUTH_BASICAUTH,
    /// Digest authentication.
    SOAP_AUTH_DIGEST,
    /// WSS authentication with digest password.
    SOAP_AUTH_WSSECURITY,
    /// WSS authentication with text password.
    SOAP_AUTH_WSSECURITY_TEXT,
    /// custom authentication sets in the header property.
    SOAP_AUTH_CUSTOM,
    /// PayPal authentication.
    SOAP_AUTH_PAYPAL,
    /// OAuth token authentication.
    SOAP_AUTH_TOKEN,
    /// Social authentication.
    SOAP_AUTH_SOCIAL
};

/// integrated enrcyption/decryption types.
typedef NS_ENUM(NSInteger, SOAPEnryption)
{
    /// integrate encryption/decryption disabled.
    SOAP_ENCRYPT_NONE,
    /// integrate encryption/decryption AES256 type.
    SOAP_ENCRYPT_AES256,
    /// integrate encryption/decryption 3DES type.
    SOAP_ENCRYPT_3DES
};

/// types of certificates for SOAP authorization
typedef NS_ENUM(NSInteger, SOAPCertificate)
{
    /// default p12 or none certificate.
    SOAP_CERTIFICATE_DEFAULT,
    /// pinning mode, support CER or DER certificate.
    SOAP_CERTIFICATE_PINNING
};

@protocol SOAPEngineDelegate;

@interface SOAPEngine : NSObject

#pragma mark - Properties

/// return the current request URL
@property (nonatomic, strong, readonly) NSURL *currentRequestURL;
/// unavailable property, please use currentRequestURL instead.
@property (nonatomic, strong, readonly, getter=currentRequestURL) NSURL *requestURL UNAVAILABLE_ATTRIBUTE;
/// return the current SOAP Action
@property (nonatomic, strong, readonly) NSString *soapAction;
/// sets or returns SOAPAction value in the header of the request.
@property (nonatomic, strong) NSString *soapActionRequest;
/// return the current method name
@property (nonatomic, strong, readonly) NSString *methodName;
/// return the current response
@property (nonatomic, strong, readonly) NSURLResponse *response;
/// adds the quotes in the SOAPAction header eg. SOAPAction = http://temp.org become SOAPAction = "http://temp.org".
@property (nonatomic, assign) BOOL actionQuotes;
/// add last path slash for action namespace eg. xmlns="http://temp.org" become xmlns="http://temp.org/"
@property (nonatomic, assign) BOOL actionNamespaceSlash;
/// add attributes on SOAP Action TAG eg. <soapAction attr="value">...</soapAction>
@property (nonatomic, strong) NSDictionary *actionAttributes;
/// return the last status code of connection
@property (nonatomic, assign) NSInteger statusCode; // http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
/// sets a custom name for the user-agent (default is "SOAPEngine").
@property (nonatomic, strong) NSString *userAgent;
/// sets a custom date format for dates (default yyyy-mm-dd)
@property (nonatomic, strong) NSString *dateFormat; // http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
/// sets to indicate that the nil values ​​are replaced with xsi:nil="true"
@property (nonatomic, assign) BOOL replaceNillable;
/// sets the default tag name, default is "input", when using setValue without key value or for array items
@property (nonatomic, strong) NSString *defaultTagName;
/// sets the prefix of the user object you want to replace
@property (nonatomic, strong) NSString *prefixObjectName;
/// sets the value of replacing for the prefix of the user object
@property (nonatomic, strong) NSString *replacePrefixObjectName;
/// sets the type of permission you want to use (none, wss, basic or custom).
@property (nonatomic, assign) SOAPAuthorization authorizationMethod;
/// sets a custom content for the custom authorization method (xml string or dictionary).
@property (nonatomic, strong) id header;
/// enables retrieval of the contents of the SOAP header in the server response.
@property (nonatomic, assign) BOOL responseHeader;
/// enables retrieval the attributes of the tags in the SOAP response.
@property (nonatomic, assign) BOOL retrievesAttributes;
/// the default SOAP namespace <soap:Envelope...
@property (nonatomic, strong) NSString *soapNamespace;
/// enables the attribute xsi:type="xsd:..." in the requests.
@property (nonatomic, assign) BOOL xsdDataTypes;
/// sets the time out for all requests.
@property (nonatomic, assign) NSTimeInterval requestTimeout;
/// sets username or selected authorization method or for server authorization or for client certifcate password.
@property (nonatomic, strong) NSString *username;
/// sets password or selected authorization method or for server authorization or for client certifcate password.
@property (nonatomic, strong) NSString *password;
/// sets REALM for Digest authorization.
@property (nonatomic, strong) NSString *realm;

//
// when calling PayPal APIs, you must authenticate each request using a set of API credentials
// PayPal associates a set of API credentials with a specific PayPal account
// you can generate credentials from this https://developer.paypal.com/docs/classic/api/apiCredentials/
//

/// sets email for PAYPAL authorization
@property (nonatomic, strong) NSString *email;
/// sets signature for PAYPAL authorization.
@property (nonatomic, strong) NSString *signature;
/// sets API Key for Social logins.
@property (nonatomic, strong) NSString *apiKey;
/// sets Social name for Social logins eg. Facebook.
@property (nonatomic, strong) NSString *socialName;
/// return Social token for current Social login
@property (nonatomic, strong) NSString *token;
/// sets the custom attributes for Envelope tag, eg. for extra namespace definitions eg. xmlns:tmp="http://temp.org".
@property (nonatomic, strong) NSString *envelope;
/// sets the SOAP version you want to use (v.1.1 or v.1.2).
@property (nonatomic, assign) SOAPVersion version;
/// enables communication with servers that have self-signed certificates.
@property (nonatomic, assign) BOOL selfSigned;

//
// sets the name of the local certificate to be used for servers
// that require authorization using a client certificate (p12)
// to convert a PAYPAL certificate to a p12 use the command shown below :
// openssl pkcs12 -export -in cert_key_pem.txt -inkey cert_key_pem.txt -out paypal_cert.p12
//

/// sets the file name of the local certificate to be used for servers
@property (nonatomic, strong) NSString *clientCerficateName;
/// sets the password of the local certificate
@property (nonatomic, strong) NSString *clientCertificatePassword;
/// sets the certificte modes
@property (nonatomic, assign) SOAPCertificate clientCertificateMode;
/// enables the conversion of special characters in a compatible html format (eg &amp;)
@property (nonatomic, assign) BOOL escapingHTML;
/// sets the encryption/decryption type for content data.
@property (nonatomic, assign) SOAPEnryption encryptionType;
/// sets the encryption/decryption password for content data.
@property (nonatomic, strong) NSString *encryptionPassword;
/// license key (deprecated, no longer used)
@property (nonatomic, strong) NSString *licenseKey __attribute__((deprecated("no longer used")));;
/// sets the receiver of the delegates
@property (nonatomic, weak) id<SOAPEngineDelegate> delegate;

#pragma mark - Static Methods

/// shared instance of class.
+ (SOAPEngine *)sharedInstance;
/// create a new (not-shared) instance of class.
+ (SOAPEngine *)manager;

#pragma mark - Methods

/// returns the integer number value for a service that return a single value.
- (NSInteger)integerValue;
/// returns the float number value for a service that return a single value.
- (float)floatValue;
/// returns the double number value for a service that return a single value.
- (double)doubleValue;
/// returns the boolean value for a service that return a single value.
- (BOOL)booleanValue;
/// returns the string value for a service that return a single value.
- (NSString*)stringValue;
/// returns the data value for a service that return a single value.
- (NSData*)dataValue;
/// returns the date value for a service that return a single value.
- (NSDate*)dateValue;
/// returns the number value for a service that return a single value.
- (NSNumber*)numberValue;
/// returns the dicionary get from the service.
- (NSDictionary*)dictionaryValue;
/// returns an object get from the service with a specific key.
- (id)valueForKey:(NSString*)key;
/// returns an array get from the service.
- (NSArray*)arrayValue;
/// returns true for a service that return a null value.
- (BOOL)isNull;

/// adds a integer number parameter to the data to be sent with a specific key.
- (void)setIntegerValue:(NSInteger)value forKey:(NSString*)key;
/// adds a double number parameter to the data to be sent with a specific key.
- (void)setDoubleValue:(double)value forKey:(NSString*)key;
/// adds a float number parameter to the data to be sent with a specific key.
- (void)setFloatValue:(float)value forKey:(NSString*)key;
/// adds a long number parameter to the data to be sent with a specific key.
- (void)setLongValue:(long)value forKey:(NSString*)key;
/// adds a parameter to the data to be sent, can also be used with user-defined objects.
- (void)setValue:(id)value;
/// adds a parameter to the data to be sent with a specific key, can also be used with user-defined objects.
- (void)setValue:(id)value forKey:(NSString *)key;
/// adds a parameter to the data to be sent  with a specific key and attributes, can also be used with user-defined objects.
- (void)setValue:(id)value forKey:(NSString *)key attributes:(NSDictionary*)attributes;
/// adds a parameter to the data to be sent  with a specific subkey in parent key, can also be used with user-defined objects.
- (void)setValue:(id)value forKey:(NSString *)key subKeyName:(NSString*)subKeyName;
/// adds a parameter to the data to be sent  with a specific subkey and attributes in parent key, can also be used with user-defined objects.
- (void)setValue:(id)value forKey:(NSString *)key subKeyName:(NSString*)subKeyName attributes:(NSDictionary*)attrbitues;

#if TARGET_OS_SIMULATOR || TARGET_OS_IOS || TARGET_OS_TV

/// adds a image data parameter to the data to be sent.
- (void)setImage:(UIImage*)image forKey:(NSString*)key __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_4_3);
/// adds a image data parameter to the data to be sent with a specific key and attributes.
- (void)setImage:(UIImage*)image forKey:(NSString*)key attributes:(NSDictionary*)attributes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_4_3);

#endif

/// return a formatted dictionary for a sub-child with attributes, eg. ["key": ["value": key-value, "attributes": ["attr": attr-value]]] this generates an XML like this: <key attr="attr-value">key-value</key>.
- (NSDictionary*)dictionaryForKey:(NSString*)key value:(id)value attributes:(NSDictionary*)attributes;

/// clear all parameters, usually used before a new request with the same instance.
- (void)clearValues;

/// sets logins for BASIC_AUTH.
- (void)login:(NSString*)username password:(NSString*)password;
/// sets logins for DIGEST_AUTH.
- (void)login:(NSString*)username password:(NSString*)password realm:(NSString*)realm;
/// sets logins for a specific authorization type.
- (void)login:(NSString*)username password:(NSString*)password authorization:(SOAPAuthorization)authorization;
/// sets logins for PAYPAL.
- (void)login:(NSString*)username password:(NSString*)password email:(NSString*)email signature:(NSString*)signature;

#pragma mark - Request with delegates

/// webservice request (async)
- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction;
/// webservice request (async)
- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value;
/// webservice request (async)
- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value forKey:(NSString*)key;

/// webservice request (sync)
- (NSDictionary*)syncRequestURL:(id)asmxURL soapAction:(NSString*)soapAction error:(NSError**)error;
/// webservice request (sync)
- (NSDictionary*)syncRequestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value error:(NSError**)error;
/// webservice request (sync)
- (NSDictionary*)syncRequestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value forKey:(NSString*)key error:(NSError**)error;

#pragma mark - Request with blocks

/// unavailable method, please use [requestURL: soapAction: completeWithDictionary: failWithError:] instead.
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail UNAVAILABLE_ATTRIBUTE;

/// unavailable method, please use [requestURL: soapAction: value: completeWithDictionary: failWithError:] instead.
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail UNAVAILABLE_ATTRIBUTE;

/// unavailable method, please use [requestURL: soapAction: value: forKey: completeWithDictionary: failWithError:] instead.
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail UNAVAILABLE_ATTRIBUTE;

/// unavailable method, please use [requestURL: soapAction: value: forKey: completeWithDictionary: failWithError: receivedDataSize:] instead.
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedDataSize:(SOAPEngineReceiveDataSizeBlock)receive UNAVAILABLE_ATTRIBUTE;

/// unavailable method, please use [requestURL: soapAction: value: forKey: completeWithDictionary: failWithError: receivedDataSize: sendedDataSize:] instead.
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
          complete:(SOAPEngineCompleteBlock)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedDataSize:(SOAPEngineReceiveDataSizeBlock)receive
    sendedDataSize:(SOAPEngineSendDataSizeBlock)sended UNAVAILABLE_ATTRIBUTE;

/// webservice request with block and dictionary
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail;

/// webservice request with block and dictionary
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail;

/// webservice request with block and dictionary
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail;

/// webservice request with block and dictionary
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedDataSize:(SOAPEngineReceiveDataSizeBlock)receive;

/// webservice request with block and dictionary
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedProgress:(SOAPEngineReceivedProgressBlock)receive;

/// webservice request with block and dictionary
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedDataSize:(SOAPEngineReceiveDataSizeBlock)receive
    sendedDataSize:(SOAPEngineSendDataSizeBlock)sended;

/// webservice request with block and dictionary
- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedProgress:(SOAPEngineReceivedProgressBlock)receive
    sendedProgress:(SOAPEngineSendedProgressBlock)sended;

#pragma mark - Request with WSDL

/// deprecated method, please use [requestURL: soapAction:] instead.
- (void)requestWSDL:(id)wsdlURL operation:(NSString*)operation
DEPRECATED_MSG_ATTRIBUTE("requestWSDL:operation: as deprecated please use requestURL:soapAction:");

/// deprecated method, please use [requestURL: soapAction: completeWithDictionary: failWithError:] instead.
- (void)requestWSDL:(id)wsdlURL
          operation:(NSString *)operation
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
      failWithError:(SOAPEngineFailBlock)fail
DEPRECATED_MSG_ATTRIBUTE("requestWSDL:operation:completeWithDictionary:failWithError: as deprecated please use requestURL:soapAction:completeWithDictionary:failWithError:");

/// deprecated method, please use [requestURL: soapAction: value: completeWithDictionary: failWithError:] instead.
- (void)requestWSDL:(id)wsdlURL
          operation:(NSString *)operation
              value:(id)value
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
      failWithError:(SOAPEngineFailBlock)fail
DEPRECATED_MSG_ATTRIBUTE("requestWSDL:operation:value:completeWithDictionary:failWithError: as deprecated please use requestURL:soapAction:value:completeWithDictionary:failWithError:");

/// deprecated method, please use [requestURL: soapAction:v alue: forKey: completeWithDictionary: failWithError:] instead.
- (void)requestWSDL:(id)wsdlURL
          operation:(NSString *)operation
              value:(id)value
             forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
      failWithError:(SOAPEngineFailBlock)fail
DEPRECATED_MSG_ATTRIBUTE("requestWSDL:operation:value:forKey:completeWithDictionary:failWithError: as deprecated please use requestURL:soapAction:value:forKey:completeWithDictionary:failWithError:");


#pragma mark - Cancel all requests

/// cancel all operations
- (void)cancel;

@end

#pragma mark - Protocol

@protocol SOAPEngineDelegate <NSObject>

@optional

/// unavailable delegate, please use didFinishLoadingWithDictionary instead.
- (void)soapEngine:(SOAPEngine*)soapEngine didFinishLoading:(NSString*)stringXML UNAVAILABLE_ATTRIBUTE;
/// unavailable delegate, please use didFinishLoadingWithDictionary instead.
- (void)soapEngine:(SOAPEngine*)soapEngine didFinishLoading:(NSString*)stringXML dictionary:(NSDictionary*)dict UNAVAILABLE_ATTRIBUTE;
/// delegate called when all data are downloaded
- (void)soapEngine:(SOAPEngine*)soapEngine didFinishLoadingWithDictionary:(NSDictionary*)dict data:(NSData*)data;
/// delegate called when generate an error
- (void)soapEngine:(SOAPEngine*)soapEngine didFailWithError:(NSError*)error;
/// delegate called during downloading data
- (void)soapEngine:(SOAPEngine*)soapEngine didReceiveDataSize:(NSUInteger)current total:(long long)total;
/// delegate called during sending data
- (void)soapEngine:(SOAPEngine*)soapEngine didSendDataSize:(NSUInteger)current total:(NSUInteger)total;
/// delegate called when the service answers
- (BOOL)soapEngine:(SOAPEngine*)soapEngine didReceiveResponseCode:(NSInteger)statusCode;
/// delegate called before calling the service
- (NSMutableURLRequest*)soapEngine:(SOAPEngine*)soapEngine didBeforeSendingURLRequest:(NSMutableURLRequest*)request;
/// delegate called before parsing received data
- (NSData*)soapEngine:(SOAPEngine*)soapEngine didBeforeParsingResponseData:(NSData*)data;
/// unavailable delegate, please use didBeforeParsingResponseData instead.
- (NSString*)soapEngine:(SOAPEngine*)soapEngine didBeforeParsingResponseString:(NSString*)stringXML UNAVAILABLE_ATTRIBUTE;

@end
