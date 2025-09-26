//
//  SOAPEngine.m
//
//  Created by Danilo Priore on 21/11/12.
//  Copyright (c) 2012-2013 Centro Studi Informatica di Danilo Priore. All rights reserved.
//  https://www.prioregroup.com
//

#if TARGET_OS_SIMULATOR || TARGET_OS_IOS || TARGET_OS_TV
    #if __has_include(<UIKit/UIKit.h>)
        #import <UIKit/UIKit.h>
    #endif
#else
    #if __has_include(<AppKit/AppKit.h>)
        #import <AppKit/NSAlert.h>
        #import <Security/Security.h>
    #endif
#endif

#import "SOAPEngine.h"
#import "SOAPConnection.h"
#import "SOAPSocial.h"
#import "SOAPSHA1.h"
#import "SOAPMD5.h"
#import "NSData+SOAPEngine.h"
#import "NSString+SOAPEngine.h"
#import "NSDictionary+SOAPEngine.h"
#import "SOAPPrefix.pch"

#import <objc/runtime.h>
#import <libkern/OSAtomic.h>

NSString *const SOAPEngineDidFinishLoadingNotification                = @"SOAPEngineDidFinishLoading";
NSString *const SOAPEngineDidFailWithErrorNotification                = @"SOAPEngineDidFailWithError";
NSString *const SOAPEngineDidReceiveResponseCodeNotification          = @"SOAPEngineDidReceiveResponseCode";
NSString *const SOAPEngineDidBeforeSendingURLRequestNotification      = @"SOAPEngineDidBeforeSendingURLRequest";
NSString *const SOAPEngineDidBeforeParsingResponseStringNotification  = @"SOAPEngineDidBeforeParsingResponseString";
NSString *const SOAPEngineDidReceiveDataSizeNotification              = @"SOAPEngineDidReceiveDataSize";
NSString *const SOAPEngineDidSendDataSizeNotification                 = @"SOAPEngineDidSendDataSize";

NSString *const SOAPEngineStatusCodeKey         = @"statusCode";
NSString *const SOAPEngineXMLDictionaryKey      = @"dictionary";
NSString *const SOAPEngineXMLDatayKey           = @"data";
NSString *const SOAPEngineURLRequestKey         = @"request";
NSString *const SOAPEngineURLResponseKey        = @"response";
NSString *const SOAPEngineErrorKey              = @"error";
NSString *const SOAPEngineDataSizeKey           = @"size";
NSString *const SOAPEngineTotalDataSizeKey      = @"totalSize";

@interface SOAPEngine()
{
    OSSpinLock _lock;
}

@property (nonatomic, strong) NSString *singleValue;
@property (nonatomic, strong) NSDictionary *multiValues;

@property (nonatomic, strong) NSMutableString *params;

@property (nonatomic, copy) SOAPEngineCompleteBlockWithDictionary completeBlockWithDict;
@property (nonatomic, copy) SOAPEngineFailBlock failBlock;
@property (nonatomic, copy) SOAPEngineReceiveDataSizeBlock receiveBlock;
@property (nonatomic, copy) SOAPEngineSendDataSizeBlock sendBlock;
@property (nonatomic, copy) SOAPEngineReceivedProgressBlock receivedProgressBlock;
@property (nonatomic, copy) SOAPEngineSendedProgressBlock sendedProgressBlock;

@property (nonatomic, strong) NSProgress *sendProgress;
@property (nonatomic, strong) NSProgress *receiveProgress;

@property (nonatomic, strong) SOAPConnection *conn;

@property (nonatomic, assign) BOOL cancelDelegates;

@property (nonatomic, strong) id asmxURL;
@property (nonatomic, strong) NSString *xmlRequest;
@property (nonatomic, strong) NSString *apiVersion;

@property (nonatomic, assign) long long contentLength;

- (void)addParamName:(NSString*)name withValue:(id)value attributes:(NSDictionary*)attributes;
- (void)appendParamName:(NSString*)name value:(id)value attributes:(NSDictionary*)attributes;
- (void)convertClassToXML:(Class)class fromObject:(id)object;

- (void)appendFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2);

@end

@implementation SOAPEngine

+ (SOAPEngine *)sharedInstance
{
    static SOAPEngine *sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self allocWithZone:NULL] init];
    });
    
    return sharedInstance;
}

+ (SOAPEngine*)manager
{
    return [[self allocWithZone:NULL] init];
}

- (id)init {
    
    if (self = [super init]) {
        
        NSLog(@"Initializing SOAPEngine v.%@", SOAPEngineFrameworkVersion);
        
        _conn = nil;
        _actionQuotes = NO;
        _actionNamespaceSlash = NO;
        _soapActionRequest = nil;
        _version = VERSION_1_1;
        _userAgent = @"SOAPEngine";
        _dateFormat = @"yyyy-MM-dd";
        _envelope = @"";
        _authorizationMethod = SOAP_AUTH_NONE;
        _clientCerficateName = @"";
        _clientCertificatePassword = @"";
        _clientCertificateMode = SOAP_CERTIFICATE_DEFAULT;
        _username = @"";
        _password = @"";
        _header = @"";
        _selfSigned = NO;
        _replaceNillable = NO;
        _singleValue = nil;
        _multiValues = nil;
        _params = nil;
        _completeBlockWithDict = nil;
        _failBlock = nil;
        _receiveBlock = nil;
        _sendBlock = nil;
        _receivedProgressBlock = nil;
        _sendedProgressBlock = nil;
        _cancelDelegates = NO;
        _escapingHTML = YES;
        _encryptionType = SOAP_ENCRYPT_NONE;
        _responseHeader = NO;
        _email = @"";
        _realm = @"";
        _signature = @"";
        _requestTimeout = 20;
        _apiVersion = @"";
        _currentRequestURL = nil;
        _methodName = @"";
        _soapAction = @"";
        _response = nil;
        _defaultTagName = @"input";
        _retrievesAttributes = NO;
        _xsdDataTypes = NO;
        _params = [NSMutableString string];
        _lock = OS_SPINLOCK_INIT;
        _soapNamespace = @"soap";
    }
    
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    SOAPEngine *copy = [[[self class] allocWithZone:zone] init];
    copy.actionQuotes = _actionQuotes;
    copy.actionNamespaceSlash = _actionNamespaceSlash;
    copy.soapActionRequest = _soapActionRequest;
    copy.statusCode = _statusCode;
    copy.userAgent = _userAgent;
    copy.dateFormat = _dateFormat;
    copy.authorizationMethod = _authorizationMethod;
    copy.header = _header;
    copy.username = _username;
    copy.password = _password;
    copy.envelope = _envelope;
    copy.version = _version;
    copy.selfSigned = _selfSigned;
    copy.clientCerficateName = _clientCerficateName;
    copy.clientCertificatePassword = _clientCertificatePassword;
    copy.clientCertificateMode = _clientCertificateMode;
    copy.replaceNillable = _replaceNillable;
    copy.escapingHTML = _escapingHTML;
    copy.encryptionType = _encryptionType;
    copy.licenseKey = _licenseKey;
    copy.delegate = nil;
    copy.responseHeader = _responseHeader;
    copy.email = _email;
    copy.realm = _realm;
    copy.signature = _signature;
    copy.requestTimeout = _requestTimeout;
    copy.params = _params;
    copy.defaultTagName = _defaultTagName;
    copy.retrievesAttributes = _retrievesAttributes;
    copy.xsdDataTypes = _xsdDataTypes;
    copy.socialName = _soapNamespace;
    
    return copy;
}

- (NSString *)description
{
    return [[NSString allocWithZone:NULL] initWithFormat:@"<%@: %p, RequestURL: %@, SOAPAction: %@, MethodName: %@>", NSStringFromClass([self class]), self, _currentRequestURL, _soapAction, _methodName];
}

- (void)dealloc
{
    _conn = nil;
    _soapActionRequest = nil;
    _completeBlockWithDict = nil;
    _failBlock = nil;
    _receiveBlock = nil;
    _sendBlock = nil;
    _receivedProgressBlock = nil;
    _sendedProgressBlock = nil;
    _params = nil;
    _singleValue = nil;
    _multiValues = nil;
    _username = nil;
    _password = nil;
    _userAgent = nil;
    _dateFormat = nil;
    _header = nil;
    _prefixObjectName = nil;
    _replacePrefixObjectName = nil;
    _soapAction = nil;
    _xmlRequest = nil;
    _methodName = nil;
    _clientCertificatePassword = nil;
    _clientCerficateName = nil;
    _licenseKey = nil;
    _email = nil;
    _realm = nil;
    _signature = nil;
    _response = nil;
    _defaultTagName = nil;
    _soapNamespace = nil;
}

#pragma mark - Requests URL (async)

- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value
{
    [self requestURL:asmxURL soapAction:soapAction value:value forKey:nil];
}

- (void)requestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value forKey:(NSString*)key
{
    [self setValue:value forKey:key];
    [self requestURL:asmxURL soapAction:soapAction];
}

- (void)requestURL:(id)asmxURL soapAction:(NSString *)soapAction
{
    self.asmxURL = [asmxURL copy];
    _soapAction = [soapAction copy];
    
    // caratteri non validi nel soapAction per l'Header
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"].invertedSet;
    if ([soapAction rangeOfCharacterFromSet:set].location != NSNotFound && !_actionQuotes) {
        _actionQuotes = true;
    }
    
    _currentRequestURL = nil;
    if ([_asmxURL isKindOfClass:[NSString class]]) {
        // se ha il suffisso WSDL
        if ([_asmxURL hasSuffix:SOAP_WSDL_SUFFIX]) {
            // ma no ha una action valida per l'wsdl, rimuove il suffisso wsdl
            if ([_soapAction hasPrefix:@"http://"] || [_soapAction hasPrefix:@"https://"])
                self.asmxURL = [_asmxURL stringByReplacingOccurrencesOfString:SOAP_WSDL_SUFFIX withString:@""];
            else {
                #pragma GCC diagnostic push
                #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                    // se invece è una chiamata corretta al wsdl, allora rigira la chiamata al metodo corretto
                    [self requestWSDL:_asmxURL operation:soapAction];
                #pragma GCC diagnostic pop
                return;
            }
        }
        _currentRequestURL = [NSURL URLWithString:_asmxURL];
    } else if ([_asmxURL isKindOfClass:[NSURL class]]) {
        _currentRequestURL = (NSURL*)_asmxURL;
    } else {
        // se manca la url del servizio il soapaction
        NSError *error = [NSError errorWithDomain:SOAP_MSGTITLE
                                             code:400
                                         userInfo:@{
                                             NSLocalizedDescriptionKey : @"SOAPEngine invalid type url!"
                                         }];
        [self didFailWithError:error.code error:error];
        return;
    }
    
    // SOAP namespace
    NSString *bodyAttribute = @"";
    NSString *actionAttr = [_actionAttributes stringAttributes] ?: @"";
    NSString *contentType = SOAP_CONTENTTYPE_TEXTXML;
    NSString *xmlns = SOAP_HTTP_PATH(_soapAction)?:_soapAction;
    _methodName = [_soapAction lastPathComponent];
    if (_actionNamespaceSlash && [xmlns length] > 0 && ![xmlns hasSuffix:@"/"]) {
        xmlns = [xmlns stringByAppendingString:@"/"];
    }
    
    // soapAction con #
    if ([_soapAction rangeOfString:@"#"].location != NSNotFound) {
        NSArray *actions = [_soapAction componentsSeparatedByString:@"#"];
        _methodName = [actions lastObject];
        xmlns = [actions firstObject];
        _actionNamespaceSlash = NO;
    }

    // SOAP authorization
    if (_authorizationMethod == SOAP_AUTH_WSSECURITY || _authorizationMethod == SOAP_AUTH_WSSECURITY_TEXT) {
        // current date
        NSDateFormatter *formatter = [SOAPEngine dateFormatter];
        formatter.dateFormat = SOAP_WSS_AUTH_DATE_FORMAT;
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        formatter.locale = [NSLocale currentLocale];
        NSString *created = [formatter stringFromDate:[NSDate date]];
        
        // nonce, user-token
        NSString *userToken = [self userToken];
        NSString *nonce = [userToken substringFromIndex:userToken.length - 16];
        NSString *nonce64 = [SOAPBase64 base64EncodingWithString:nonce];
        
        if (_authorizationMethod == SOAP_AUTH_WSSECURITY_TEXT) {
            // WS-Security Text header
            NSString *header = [SOAP_WSS_AUTH stringByReplacingOccurrencesOfString:@"#PasswordDigest" withString:@"#PasswordText"];
            self.header = [[NSString allocWithZone:NULL] initWithFormat:header, userToken, _username, _password, nonce64, created];
        } else {
            // WS-Security Digest header
            NSString *s_digest = [[NSString allocWithZone:NULL] initWithFormat:@"%@%@%@", nonce, created, _password];
            NSData *digest = [SOAPSHA1 getSHA1WithString:s_digest];
            NSString *pwdSHA1 = [SOAPBase64 base64EncodingWithData:digest];
            self.header = [[NSString allocWithZone:NULL] initWithFormat:SOAP_WSS_AUTH, userToken, _username, pwdSHA1, nonce64, created];
        }
        
    }
    else if (_authorizationMethod == SOAP_AUTH_BASICAUTH) {
        self.header = [[NSString allocWithZone:NULL] initWithFormat:SOAP_BASIC_AUTH, _soapNamespace, _username, _password];
    }
    else if (_authorizationMethod == SOAP_AUTH_CUSTOM) {
        // custom header
    }
    else if (_authorizationMethod == SOAP_AUTH_PAYPAL) {
        // PAYPAL
        self.header = [[NSString allocWithZone:NULL] initWithFormat:SOAP_PAYPAL_AUTH, _username, _password, _signature, _email];
        self.envelope = SOAP_PAYPAL_ENVELOPE;
        // versione presa dall'WSDL
        if ([_apiVersion length] > 0)
            [self setValue:_apiVersion forKey:@"paypal1:Version"];
        // incapsulamento dei parametri
        self.params = [NSMutableString stringWithFormat:@"<paypal:%@Request>%@</paypal:%@Request>", _methodName, _params, _methodName];
        _methodName = [[NSString allocWithZone:NULL] initWithFormat:@"paypal:%@Req", _methodName];
    } else if (_authorizationMethod == SOAP_AUTH_SOCIAL) {
        if ([_token length] == 0) {
#if TARGET_OS_TV
            NSLog(@"Attention! authorization method set to social but not have sets a value for the token!");
#else
            // richiede il token OAuth dal social
            __block NSError *_err = nil;
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [SOAPSocial accountInfoWithSocial:_socialName
                                     appIdKey:_apiKey
                                   completion:^(BOOL granted, ACAccount *account, NSError *error) {
                                       _err = error;
                                       self.token = [[account credential] oauthToken];
                                       dispatch_semaphore_signal(semaphore);
                                   }];
            // aspetta che sia recuperato
            while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                         beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            // se è avvenuto un errore lo segnala ed interrompe
            if (_err)
            {
                [self didFailWithError:_err.code error:_err];
                return;
            }
#endif
        }
        
    }
    else {
        self.header = @"";
    }

    // per WCF
    if (_version >= VERSION_WCF_1_1) xmlns = SOAP_HTTP_PATH(xmlns);
    if ([xmlns length] > 0)
        xmlns = [[NSString allocWithZone:NULL] initWithFormat:@" xmlns=\"%@%@\"", xmlns, _actionNamespaceSlash && ![xmlns hasSuffix:@"/"] ? @"/" : @""];
    
    // Action tag on Header
    if (_soapActionRequest.length == 0)
        self.soapActionRequest = _soapAction;
    
    // SOAP request
    switch (_version) {
        case VERSION_1_1:
        case VERSION_WCF_1_1:
        {
            self.xmlRequest = [[NSString allocWithZone:NULL] initWithFormat:SOAP_REQUEST_1_1, _soapNamespace, _soapNamespace, _envelope, _soapNamespace, _header, _soapNamespace, _soapNamespace, bodyAttribute, _methodName, actionAttr, xmlns, _params, _methodName, _soapNamespace, _soapNamespace];
            break;
        }
        case VERSION_1_2:
        {
            contentType = [contentType stringByAppendingFormat:@"; action=%c%@%c", 34, _soapActionRequest, 34];
            self.xmlRequest = [[NSString allocWithZone:NULL] initWithFormat:SOAP_REQUEST_1_2, _soapNamespace, _soapNamespace, _envelope, _soapNamespace, _header, _soapNamespace, _soapNamespace, bodyAttribute, _methodName, actionAttr, xmlns, _params, _methodName, _soapNamespace, _soapNamespace];
            break;
        }
        default:
            break;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_currentRequestURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:_requestTimeout];
    NSString *msgLength = [[NSNumber numberWithInteger:[_xmlRequest length]] stringValue];
    
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:!_actionQuotes ? _soapActionRequest : [[NSString allocWithZone:NULL] initWithFormat:@"%c%@%c", 34, _soapActionRequest, 34] forHTTPHeaderField:@"SOAPAction"];
    [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:_userAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue:SOAP_CONTENTTYPE_TEXTXML forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[_xmlRequest dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Basic authentication
    if (_authorizationMethod == SOAP_AUTH_BASIC) {
        NSString *authBase64 = [SOAPBase64 base64EncodingWithString:[[NSString allocWithZone:NULL] initWithFormat:@"%@:%@", _username, _password]];
        NSString *auth = [[NSString allocWithZone:NULL] initWithFormat:@"Basic %@", authBase64];
        [request addValue:auth forHTTPHeaderField:SOAP_AUTHORIZATION_FIELD];
    } else if (_authorizationMethod == SOAP_AUTH_DIGEST) {
        NSString *nonce = [self nonce].lowercaseString;
        NSString *A1 = [SOAPMD5 getMD5WithString: [[NSString allocWithZone:NULL] initWithFormat:@"%@:%@:%@", _username, _realm, _password]];
        NSString *A2 = [SOAPMD5 getMD5WithString: [[NSString allocWithZone:NULL] initWithFormat:@"POST:%@", _currentRequestURL.path]];
        NSString *digest = [SOAPMD5 getMD5WithString: [[NSString allocWithZone:NULL] initWithFormat:@"%@:%@:%@", A1, nonce, A2]];
        NSString *auth = [[NSString allocWithZone:NULL] initWithFormat:@"Digest username=\"%@\",realm=\"%@\",nonce=\"%@\",uri=\"%@\",response=\"%@\"", _username, _realm, nonce, _currentRequestURL.path, digest];
        [request addValue:auth forHTTPHeaderField:SOAP_AUTHORIZATION_FIELD];
    } else if (_authorizationMethod == SOAP_AUTH_TOKEN || _authorizationMethod == SOAP_AUTH_SOCIAL) {
        NSString *auth = [[NSString allocWithZone:NULL] initWithFormat:@"Bearer %@", _token ?: @""];
        [request addValue:auth forHTTPHeaderField:SOAP_AUTHORIZATION_FIELD];
    }
    
    if (!_cancelDelegates) {
        
        if (_sendProgress) {
            _sendProgress.completedUnitCount = 0;
            _sendProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
        }
        
        if (_receiveProgress) {
            _receiveProgress.completedUnitCount = 0;
            _receiveProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SOAPEngineDidBeforeSendingURLRequestNotification
                                                            object:self
                                                          userInfo:@{SOAPEngineURLRequestKey: request}];

        if (_delegate && [_delegate respondsToSelector:@selector(soapEngine:didBeforeSendingURLRequest:)]) {
            request = [_delegate soapEngine:self didBeforeSendingURLRequest:request];
        }

        __weak SOAPEngine *wself = self;

        self.conn = [self connection];
        _conn.didCompleted = ^(NSInteger statusCode, NSData *data, NSDictionary *dict, NSString *value) {
            [wself didFinishLoading:statusCode data:data dict:dict value:value];
        };
        
        _conn.didFailed = ^(NSInteger statusCode, NSError *error) {
            [wself didFailWithError:statusCode error:error];
        };
        
        _conn.didBeforeParse = ^NSData *(NSInteger statusCode, NSData *data) {
            return [wself didBeforeParsing:data];
        };
        
        _conn.didSendBodyData = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            [wself didSendBodyData:bytesSent totalBytesWritten:totalBytesSent totalBytesExpectedToWrite:totalBytesExpectedToSend];
        };

        _conn.didReceiveResponse = ^(NSURLResponse *response) {
            [wself didReceiveResponse:response];
        };
        
        _conn.didReceiveData = ^(NSData *data) {
            [wself didReceiveData:data];
        };
        
        [_conn loadRequest:request];
    }
}

#pragma mark - Request URL (sync)

- (NSDictionary*)syncRequestURL:(id)asmxURL soapAction:(NSString*)soapAction error:(NSError**)error
{
    __block NSError *err = nil;
    __block NSDictionary *response = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self requestURL:asmxURL soapAction:soapAction completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict) {
        response = dict;
        dispatch_semaphore_signal(semaphore);
    } failWithError:^(NSError *_error_) {
        err = _error_;
        dispatch_semaphore_signal(semaphore);
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    if (error != NULL)
        *error = err;
    return response;
}

- (NSDictionary*)syncRequestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value error:(NSError**)error
{
    return [self syncRequestURL:asmxURL soapAction:soapAction value:value forKey:nil error:error];
}

- (NSDictionary*)syncRequestURL:(id)asmxURL soapAction:(NSString*)soapAction value:(id)value forKey:(NSString*)key error:(NSError**)error
{
    __block NSError *err = nil;
    __block NSDictionary *response = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self requestURL:asmxURL soapAction:soapAction value:value forKey:key completeWithDictionary:^(NSInteger statusCode, NSDictionary *dict) {
        response = dict;
        dispatch_semaphore_signal(semaphore);
    } failWithError:^(NSError *_error_) {
        err = _error_;
        dispatch_semaphore_signal(semaphore);
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    if (error != NULL)
        *error = err;
    return response;
}

#pragma mark - Requests URL with block and dictionary

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
{
    self.completeBlockWithDict = [complete copy];
    self.failBlock = [fail copy];

    [self requestURL:asmxURL soapAction:soapAction];
}

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
{
    [self requestURL:asmxURL
          soapAction:soapAction
               value:value
              forKey:nil
completeWithDictionary:complete
       failWithError:fail];
}

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
{
    [self setValue:value forKey:key];
    [self requestURL:asmxURL
          soapAction:soapAction
completeWithDictionary:complete
       failWithError:fail];
}

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString *)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedDataSize:(SOAPEngineReceiveDataSizeBlock)receive
{
    self.receiveBlock = [receive copy];
    [self requestURL:asmxURL
          soapAction:soapAction
               value:value
              forKey:key
completeWithDictionary:complete
       failWithError:fail];
}

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString *)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedDataSize:(SOAPEngineReceiveDataSizeBlock)receive
    sendedDataSize:(SOAPEngineSendDataSizeBlock)sended
{
    self.sendBlock = [sended copy];
    [self requestURL:asmxURL
          soapAction:soapAction
               value:value
              forKey:key
completeWithDictionary:complete
       failWithError:fail
    receivedDataSize:receive];
}

#pragma mark - Request URL with NSProgress

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedProgress:(SOAPEngineReceivedProgressBlock)receive
{
    self.receivedProgressBlock = [receive copy];
    self.receiveProgress = [[NSProgress allocWithZone:NULL] initWithParent:nil userInfo:nil];
    self.receiveProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
    self.sendProgress = nil;
    
    [self requestURL:asmxURL
          soapAction:soapAction
               value:value
              forKey:key
completeWithDictionary:complete
       failWithError:fail];
}

- (void)requestURL:(id)asmxURL
        soapAction:(NSString *)soapAction
             value:(id)value
            forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
     failWithError:(SOAPEngineFailBlock)fail
  receivedProgress:(SOAPEngineReceivedProgressBlock)receive
    sendedProgress:(SOAPEngineSendedProgressBlock)sended
{
    self.sendedProgressBlock = [sended copy];
    self.sendProgress = [[NSProgress allocWithZone:NULL] initWithParent:nil userInfo:nil];
    self.sendProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
    self.receiveProgress = [[NSProgress allocWithZone:NULL] initWithParent:nil userInfo:nil];
    self.receiveProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
    
    [self requestURL:asmxURL
          soapAction:soapAction
               value:value
              forKey:key
completeWithDictionary:complete
       failWithError:fail
    receivedProgress:receive];
}

#pragma mark - Requests with WSDL

- (void)requestWSDL:(id)wsdlURL operation:(NSString*)operation
{
    NSURL *url = nil;
    if ([wsdlURL isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:wsdlURL];
    } else if ([wsdlURL isKindOfClass:[NSURL class]]) {
        url = (NSURL*)wsdlURL;
    } else {
        // se manca la url del servizio il soapaction
        NSError *error = [NSError errorWithDomain:SOAP_MSGTITLE
                                             code:400
                                         userInfo:@{
                                             NSLocalizedDescriptionKey : @"SOAPEngine invalid type url!"
                                         }];
        [self didFailWithError:error.code error:error];
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:_requestTimeout];
    [request setValue:_userAgent forHTTPHeaderField:@"User-Agent"];
    
    __weak SOAPEngine *wself = self;

    self.conn = [self connection];
    _conn.responseHeader = YES;
    _conn.retrievesAttributes = YES;
    
    _conn.didCompleted = ^(NSInteger statusCode, NSData *data, NSDictionary *dict, NSString *value) {
        // versione api (PAYPAL)
        wself.apiVersion = [dict valueForKeyPath:@"attributes.version"];
        
        NSString *soapType = (wself.version == VERSION_1_2) ? @"soap12" : @"soap";
        if (wself.authorizationMethod == SOAP_AUTH_PAYPAL) {
            // per Paypal seleziona il tipo di autenticazione con certificato o signature
            soapType = [wself.clientCerficateName length] > 0 ? @"paypalapisoapbinding" : @"paypalapiaasoapbinding";
        }
        
        // cerca la url del servizio
        NSString *location = nil;
        id ports = [dict valueForKeyPath:@"service.port"];
        if ([ports isKindOfClass:[NSMutableDictionary class]]) {
            location = [ports valueForKeyPath:@"address.attributes.location"];
        } else if ([ports isKindOfClass:[NSMutableArray class]]) {
            // cerca la rispettiva versione di soap
            for (NSDictionary *port in ports) {
                NSString *binding = [port valueForKeyPath:@"attributes.binding"] ?: [[port valueForKeyPath:@"attributes.name"] lowercaseString];
                if ([binding hasSuffix:soapType]) {
                    location = [port valueForKeyPath:@"address.attributes.location"];
                    break;
                }
            }
            // se non ha trovato la versione del soap prende il primo url
            if (location == nil)
                location = [[ports firstObject] valueForKeyPath:@"address.attributes.location"];
        }
        
        // cerca il soapaction
        NSString *soapAction = operation;
        id operations = [dict valueForKeyPath:@"binding.operation.operation.attributes.soapAction"];
        if (operations) {
            // nel caso sia una stringa
            if ([operations isKindOfClass:[NSString class]]) {
                soapAction = [[(NSString*)operations stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0 ? operations : nil;
            } else if ([[operations firstObject] isKindOfClass:[NSArray class]]) {
                // nel caso sia un array di array
                BOOL isFounded = NO;
                for (NSArray *actions in operations) {
                    for (NSString *action in actions) {
                        if (![action isKindOfClass:[NSNull class]]
                            && [[action lastPathComponent] isEqualToString:operation]) {
                            
                            soapAction = action;
                            isFounded = YES;
                            break;
                        }
                    }
                    // interrompe tutti i cicli
                    if (isFounded)
                        break;
                }
            } else {
                for (NSString *action in operations) {
                    if (action && [[action lastPathComponent] isEqualToString:operation]) {
                        soapAction = action;
                        break;
                    }
                }
            }
        }
        
        if (location && soapAction) {
            // chiama il servizio
            NSCharacterSet *novalid = [NSCharacterSet characterSetWithCharactersInString:@"!*'();@&=+$,\\?%#[]"];
            soapAction = [[soapAction componentsSeparatedByCharactersInSet:novalid] componentsJoinedByString:@""];
            [wself requestURL:location soapAction:soapAction];
        } else {
            // se manca la url del servizio il soapaction
            NSError *error = [NSError errorWithDomain:SOAP_MSGTITLE
                                                 code:415
                                             userInfo:@{
                                                 NSLocalizedDescriptionKey : @"SOAPEngine invalid WSDL format the location attribute and soapAction attribute required!"
                                             }];
            [wself didFailWithError:error.code error:error];
        }
    };
    
    _conn.didFailed = ^(NSInteger statusCode, NSError *error) {
        [wself didFailWithError:statusCode error:error];
    };

    [_conn loadRequest:request];
}

- (void)requestWSDL:(id)wsdlURL
          operation:(NSString *)operation
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
      failWithError:(SOAPEngineFailBlock)fail
{
    self.completeBlockWithDict = [complete copy];
    self.failBlock = [fail copy];
    
    [self requestWSDL:wsdlURL operation:operation];
}

- (void)requestWSDL:(id)wsdlURL
          operation:(NSString *)operation
              value:(id)value
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
      failWithError:(SOAPEngineFailBlock)fail
{
    [self requestWSDL:wsdlURL
            operation:operation
                value:value
               forKey:nil
completeWithDictionary:complete failWithError:fail];
}

- (void)requestWSDL:(id)wsdlURL
          operation:(NSString *)operation
              value:(id)value
             forKey:(NSString*)key
completeWithDictionary:(SOAPEngineCompleteBlockWithDictionary)complete
      failWithError:(SOAPEngineFailBlock)fail
{
    [self setValue:value forKey:key];
    [self requestWSDL:wsdlURL
            operation:operation
completeWithDictionary:complete
        failWithError:fail];
}

#pragma mark - Logins

- (void)login:(NSString*)username password:(NSString*)password
{
    [self login:username password:password authorization:SOAP_AUTH_BASIC];
}

- (void)login:(NSString*)username password:(NSString*)password realm:(NSString*)realm
{
    OSSpinLockLock(&_lock);
    _username = username;
    _password = password;
    _realm = realm;
    _authorizationMethod = SOAP_AUTH_DIGEST;
    OSSpinLockUnlock(&_lock);
}

- (void)login:(NSString*)username password:(NSString*)password authorization:(SOAPAuthorization)authorization
{
    OSSpinLockLock(&_lock);
    _username = username;
    _password = password;
    _authorizationMethod = authorization;
    OSSpinLockUnlock(&_lock);
}

- (void)login:(NSString*)username password:(NSString*)password email:(NSString*)email signature:(NSString*)signature
{
    OSSpinLockLock(&_lock);
    _username = username;
    _password = password;
    _email = email;
    _signature = signature;
    _authorizationMethod = SOAP_AUTH_PAYPAL;
    OSSpinLockUnlock(&_lock);
}

#pragma mark - Public Methods

- (void)cancel
{
    _cancelDelegates = YES;

    if (_conn) {
        [_conn cancel];
    }
    
    if (_sendProgress)
        [_sendProgress cancel];
    
    if (_receiveProgress)
        [_receiveProgress cancel];
}

#pragma mark - GetValues

- (NSInteger)integerValue
{
    NSInteger result = 0;
    OSSpinLockLock(&_lock);
    if (_singleValue)
        result = [_singleValue integerValue];
    OSSpinLockUnlock(&_lock);
    return result;
}

- (float)floatValue
{
    float result = 0;
    OSSpinLockLock(&_lock);
    if (_singleValue)
        result = [_singleValue floatValue];
    OSSpinLockUnlock(&_lock);
    return result;
}

- (double)doubleValue
{
    double result = 0;
    OSSpinLockLock(&_lock);
    if (_singleValue)
        result = [_singleValue doubleValue];
    OSSpinLockUnlock(&_lock);
    return result;
}

- (BOOL)booleanValue
{
    bool result = NO;
    OSSpinLockLock(&_lock);
    if (_singleValue)
        result = [_singleValue boolValue];
    OSSpinLockUnlock(&_lock);
    return result;
}

- (NSString*)stringValue
{
    NSString *result = nil;
    OSSpinLockLock(&_lock);
    if (_singleValue)
        result = [[NSString allocWithZone:NULL] initWithString:_singleValue];
    OSSpinLockUnlock(&_lock);
    return  result;
}

- (NSData*)dataValue
{
    NSData *result = nil;
    OSSpinLockLock(&_lock);
    if (_singleValue)
        result = [NSData dataWithData:[_singleValue dataUsingEncoding:NSUTF8StringEncoding]];
    OSSpinLockUnlock(&_lock);
    return result;
}

- (NSDate*)dateValue
{
    NSDate *result = nil;
    OSSpinLockLock(&_lock);
    if (_singleValue) {
        NSDateFormatter *formatter = [SOAPEngine dateFormatter];
        formatter.dateFormat = _dateFormat;
        result = [formatter dateFromString:_singleValue];
    }
    OSSpinLockUnlock(&_lock);
    return result;
}

- (NSNumber*)numberValue
{
    NSNumber *result = nil;
    OSSpinLockLock(&_lock);
    if (_singleValue)
        result = [NSNumber numberWithDouble:[_singleValue doubleValue]];
    OSSpinLockUnlock(&_lock);
    return result;
}

- (BOOL)isNull
{
    bool result = NO;
    OSSpinLockLock(&_lock);
    if (_singleValue)
        result = _singleValue == nil;
    OSSpinLockUnlock(&_lock);
    return result;
}

- (NSDictionary*)dictionaryValue
{
    NSDictionary *result = nil;
    OSSpinLockLock(&_lock);
    if (_multiValues)
        result = _multiValues;
    OSSpinLockUnlock(&_lock);
    return result;
}

- (id)valueForKey:(NSString*)key
{
    id result = nil;
    OSSpinLockLock(&_lock);
    if (_multiValues)
        result = [_multiValues valueForKeyPath:key];
    OSSpinLockUnlock(&_lock);
    return result;
}

- (NSArray*)arrayValue
{
    NSArray *result = nil;
    OSSpinLockLock(&_lock);
    if (_multiValues)
        result = [NSArray arrayWithArray:[_multiValues objectForKey:[_multiValues.allKeys firstObject]]];
    OSSpinLockUnlock(&_lock);
    return result;
}

#pragma mark - SetValues

- (void)setValue:(id)value
{
    [self setValue:value forKey:nil subKeyName:nil attributes:nil];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    [self setValue:value forKey:key subKeyName:nil attributes:nil];
}

- (void)setValue:(id)value forKey:(NSString *)key attributes:(NSDictionary*)attributes
{
    [self setValue:value forKey:key subKeyName:nil attributes:attributes];
}

- (void)setValue:(id)value forKey:(NSString *)key subKeyName:(NSString*)subKeyName
{
    [self setValue:value forKey:key subKeyName:subKeyName attributes:nil];
}

- (void)setValue:(id)value forKey:(NSString *)key subKeyName:(NSString*)subKeyName attributes:(NSDictionary*)attribitues
{
    if (value == nil || value == (id)[NSNull null]) {
        [self addParamName:key withValue:nil attributes:attribitues];
    }
    else if ([value isKindOfClass:[NSString class]]) {
        NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithDictionary:attribitues];
        if (_xsdDataTypes)
            [attr setValue:@"string" forKey:SOAP_XML_XSITYPE];
        [self addParamName:key withValue:value attributes:attr];
    }
    else if ([value isKindOfClass:[NSData class]]) {
        [self addParamName:key withValue:value attributes:attribitues];
    }
    else if ([value isKindOfClass:[NSDate class]]) {
        NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithDictionary:attribitues];
        if (_xsdDataTypes)
            [attr setValue:@"dateTime" forKey:SOAP_XML_XSITYPE];
        NSDateFormatter *formatter = [SOAPEngine dateFormatter];
        formatter.dateFormat = _dateFormat;
        NSString *s_value = [formatter stringFromDate:value];
        [self addParamName:key withValue:s_value attributes:attr];
    }
    else if ([value isKindOfClass:[NSNumber class]]) {
        NSString *s_value = [(NSNumber*)value stringValue];
        [self addParamName:key withValue:s_value attributes:attribitues];
    }
    else if ([value isKindOfClass:[NSDictionary class]]) {
        [self convertDictionaryToXML:value keyName:key ?: _defaultTagName attributes:attribitues];
    }
    else if ([value isKindOfClass:[NSArray class]]) {
        [self convertArrayToXML:value keyName:key ?: _defaultTagName subKeyName:subKeyName attributes:attribitues];
    }
    else if ([value isKindOfClass:[NSSet class]]) {
        NSArray *array = [(NSSet*)value allObjects];
        [self convertArrayToXML:array keyName:key ?: _defaultTagName subKeyName:subKeyName attributes:attribitues];
    }
    
#if TARGET_OS_SIMULATOR || TARGET_OS_IOS || TARGET_OS_TV
    
    else if ([value isKindOfClass:[UIImage class]]) {
        [self setImage:value forKey:key attributes:attribitues];
    }
    else if ([value isKindOfClass:[UIImageView class]]) {
        [self setImage:[(UIImageView*)value image] forKey:key attributes:attribitues];
    }
#endif
    
    else if ([value isKindOfClass:[NSObject class]]) {
        [self convertObjectToXML:value keyName:key ?: _defaultTagName attributes:attribitues];
    }
    else {
        NSString *msg = [[NSString allocWithZone:NULL] initWithFormat:@"SOAPEngine invalid type of value for key '%@' (class: %@)", key, [value class]];
        NSLog(@"%@", msg);
    }
}

- (void)setIntegerValue:(NSInteger)value forKey:(NSString*)key
{
    NSString *s_value = [[NSNumber numberWithInteger:value] stringValue];
    [self addParamName:key withValue:s_value attributes:_xsdDataTypes ? @{SOAP_XML_XSITYPE: @"int"}: nil];
}

- (void)setDoubleValue:(double)value forKey:(NSString*)key
{
    NSString *s_value = [[NSNumber numberWithDouble:value] stringValue];
    [self addParamName:key withValue:s_value attributes:_xsdDataTypes ? @{SOAP_XML_XSITYPE: @"double"} : nil];
}

- (void)setFloatValue:(float)value forKey:(NSString*)key
{
    NSString *s_value = [[NSNumber numberWithFloat:value] stringValue];
    [self addParamName:key withValue:s_value attributes:_xsdDataTypes ? @{SOAP_XML_XSITYPE: @"float"} : nil];
}

- (void)setLongValue:(long)value forKey:(NSString*)key
{
    NSString *s_value = [[NSNumber numberWithLong:value] stringValue];
    [self addParamName:key withValue:s_value attributes:_xsdDataTypes ? @{SOAP_XML_XSITYPE: @"long"} : nil];
}

#if TARGET_OS_SIMULATOR || TARGET_OS_IOS || TARGET_OS_TV

- (void)setImage:(UIImage*)image forKey:(NSString*)key
{
    [self setImage:image forKey:key attributes:nil];
}

- (void)setImage:(UIImage*)image forKey:(NSString*)key attributes:(NSDictionary*)attributes
{
    if (image) {
        CGDataProviderRef provider = CGImageGetDataProvider([image CGImage]);
        NSData *data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
        [self addParamName:key withValue:data attributes:attributes];
    }
}

#endif

- (void)setHeader:(id)header
{
    if ([header isKindOfClass:[NSDictionary class]]) {
        
        NSMutableString *tmp = _params.mutableCopy;
        
        _params = nil;
        [self convertDictionaryToXML:header keyName:nil attributes:nil];
        
        OSSpinLockLock(&_lock);
        _header = _params;
        _params = tmp;
        OSSpinLockUnlock(&_lock);
        
    } else if ([header isKindOfClass:[NSString class]]) {
        OSSpinLockLock(&_lock);
        _header = header;
        OSSpinLockUnlock(&_lock);
    }
}

- (NSDictionary*)dictionaryForKey:(NSString*)key value:(id)value attributes:(NSDictionary*)attributes;
{
    if (key != nil)
        return @{key : @{SOAP_XML_KEYVALUE: value ?: @"", SOAP_XML_KEYATTRIBUTES: attributes}};
    return [[NSDictionary allocWithZone:NULL] init];
}

- (void)clearValues
{
    OSSpinLockLock(&_lock);
    self.params = [NSMutableString string];
    OSSpinLockUnlock(&_lock);
}

#pragma mark - Connection

- (SOAPConnection*)connection
{
    SOAPConnection *conn = [[SOAPConnection allocWithZone:NULL] init];
    conn.selfSigned = _selfSigned;
    conn.username = _username;
    conn.password = _password;
    conn.clientCerficateName = _clientCerficateName;
    conn.clientCerficatePassword = _clientCertificatePassword;
    conn.encryptionType = _encryptionType;
    conn.encryptionPassword = _encryptionPassword;
    conn.xpathQuery = @"/*";
    conn.soapNamespace = _soapNamespace;
    conn.methodName = _methodName;
    conn.responseHeader = _responseHeader;
    conn.actionNamespaceSlash = _actionNamespaceSlash;
    conn.retrievesAttributes = _retrievesAttributes;
    conn.encryptionType = _encryptionType;
    conn.encryptionPassword = _encryptionPassword;
    conn.clientCertificateMode = _clientCertificateMode;
    
    return conn;
}

-(void)didReceiveResponse:(NSURLResponse *)response
{
    _response = response;
    if (!_cancelDelegates && [response respondsToSelector:@selector(statusCode)])
    {
        _statusCode = [((NSHTTPURLResponse *)response) statusCode];

        [[NSNotificationCenter defaultCenter] postNotificationName:SOAPEngineDidReceiveResponseCodeNotification
                                                            object:self
                                                          userInfo:@{
                                                              SOAPEngineStatusCodeKey: @(_statusCode),
                                                              SOAPEngineURLResponseKey: response
                                                          }];

        if (_delegate != nil && [_delegate respondsToSelector:@selector(soapEngine:didReceiveResponseCode:)]) {
            BOOL ret = [_delegate soapEngine:self didReceiveResponseCode:_statusCode];
            if (!ret && _conn) [_conn cancel];
        }
    }
    
    // recupera la lunghezza dei dati
    _contentLength = response.expectedContentLength;
    _receiveProgress.totalUnitCount = response.expectedContentLength;
    
    if (_contentLength <= 0) {
        
        _contentLength = 0;
        
        NSLog(@"SOAPEngine missing Content-Length in the header of the HTTP response or its value is equal zero!");
        NSLog(@"Warning! NSProgress not work without Content-Length.");
    }
}

-(void)didReceiveData:(NSData *)data
{
    // percentuale dati ricevuti
    if (!_cancelDelegates)
    {
        NSUInteger len = [data length];

        [[NSNotificationCenter defaultCenter] postNotificationName:SOAPEngineDidReceiveDataSizeNotification
                                                            object:self
                                                          userInfo:@{
                                                              SOAPEngineDataSizeKey : @(len),
                                                              SOAPEngineXMLDatayKey: data,
                                                              SOAPEngineTotalDataSizeKey : @(_contentLength)
                                                          }];
        
        if (_receiveProgress)
            _receiveProgress.completedUnitCount = MIN(len, _receiveProgress.totalUnitCount);

        if (_receiveBlock) {
            _receiveBlock(len, _contentLength);
        } else if (_receivedProgressBlock) {
            _receivedProgressBlock(_receiveProgress);
        } else if (_delegate != nil && [_delegate respondsToSelector:@selector(soapEngine:didReceiveDataSize:total:)]) {
            [_delegate soapEngine:self didReceiveDataSize:len total:_contentLength];
        }
    }
}

- (void)didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    // percentuale dati inviati
    if (!_cancelDelegates)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:SOAPEngineDidSendDataSizeNotification
                                                            object:self
                                                          userInfo:@{
                                                              SOAPEngineDataSizeKey : @(bytesWritten),
                                                              SOAPEngineTotalDataSizeKey : @(totalBytesExpectedToWrite)
                                                          }];

        if (_sendProgress) {
            if (_sendProgress.totalUnitCount == NSURLSessionTransferSizeUnknown)
                _sendProgress.totalUnitCount = totalBytesExpectedToWrite;
            
            _sendProgress.completedUnitCount = MIN(bytesWritten, _sendProgress.totalUnitCount);
        }
        
        if (_sendBlock) {
            _sendBlock(bytesWritten, totalBytesExpectedToWrite);
        } else if (_sendedProgressBlock) {
            _sendedProgressBlock(_sendProgress);
        } else if (_delegate != nil && [_delegate respondsToSelector:@selector(soapEngine:didSendDataSize:total:)]) {
            [_delegate soapEngine:self didSendDataSize:bytesWritten total:totalBytesExpectedToWrite];
        }
    }
}

-(void)didFailWithError:(NSInteger)code error:(NSError *)error
{
    self.conn = nil;
    self.statusCode = code;

    if (_sendProgress)
        [_sendProgress cancel];
    
    if (_receiveProgress)
        [_receiveProgress cancel];

    [self errorWithError:error];
}

- (void)didFinishLoading:(NSInteger)statusCode data:(NSData*)data dict:(NSDictionary*)dict value:(NSString*)value
{
    self.multiValues = dict;
    self.singleValue = value;
    
    // se non ci sono dati
    if ([[dict allKeys] count] == 0 && [value length] == 0) {
        // controlla se la response è dovuta a un action xmlns senza slash
        NSString *xml = data.toString;
        NSString *strRegEx = [[NSString allocWithZone:NULL] initWithFormat:SOAP_RESPONSE_REGEXP, _methodName];
        NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:strRegEx options:0 error:nil];
        NSTextCheckingResult *matchRequest = [regEx firstMatchInString:_xmlRequest options:0 range:NSMakeRange(0, [_xmlRequest length])];
        NSTextCheckingResult *matchResponse = [regEx firstMatchInString:xml options:0 range:NSMakeRange(0, [xml length])];
        if (matchRequest && matchRequest.range.location != NSNotFound && matchResponse && matchResponse.range.location != NSNotFound) {
            NSString *xmlReq = [[[_xmlRequest substringWithRange:matchRequest.range]
                                stringByReplacingOccurrencesOfString:@" " withString:@""]
                                lowercaseString];
            NSString *xmlResponse = [[[[[xml substringWithRange:matchResponse.range]
                                       stringByReplacingOccurrencesOfString:@"Response" withString:@""]
                                      stringByReplacingOccurrencesOfString:@" " withString:@""]
                                     stringByReplacingOccurrencesOfString:@"/>" withString:@">"]
                                     lowercaseString];
            // confronta la request con il response se sono diversi segnala l'errore
            if (![xmlReq isEqualToString:xmlResponse]) {
                NSString *msg = [NSString stringWithFormat:@"SOAPEngine no valid response, try again with actionNamespaceSlash set to %@ or/and responseHeader set to YES.", _actionNamespaceSlash ? @"NO" : @"YES"];
                NSError *error = [NSError errorWithDomain:SOAP_MSGTITLE
                                                   code:204
                                                 userInfo:@{ NSLocalizedDescriptionKey: msg }];
                [self didFailWithError:error.code error:error];
                return;
            }
        }
    }
    
    // notifications
    [[NSNotificationCenter defaultCenter] postNotificationName:SOAPEngineDidFinishLoadingNotification
                                                        object:self
                                                      userInfo:@{
                                                          SOAPEngineStatusCodeKey : @(statusCode),
                                                          SOAPEngineXMLDatayKey: data,
                                                          SOAPEngineXMLDictionaryKey : dict
                                                      }];

    if (self.completeBlockWithDict) {
        // blocks
        self.completeBlockWithDict(statusCode, dict);
    } else if (self.delegate != nil && [self.delegate respondsToSelector:@selector(soapEngine:didFinishLoadingWithDictionary:data:)]) {
        // delegates
        [self.delegate soapEngine:self didFinishLoadingWithDictionary:dict data:data];
    }
}

- (NSData*)didBeforeParsing:(NSData*)data
{
    // delegato prima del parse
    if (!_cancelDelegates) {
        
        if (_sendProgress)
            _sendProgress.completedUnitCount = _sendProgress.totalUnitCount;
        
        if (_receiveProgress)
            _receiveProgress.completedUnitCount = _receiveProgress.totalUnitCount;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SOAPEngineDidBeforeParsingResponseStringNotification
                                                            object:self
                                                          userInfo:@{
                                                              SOAPEngineXMLDatayKey: data,
                                                              SOAPEngineStatusCodeKey : @(_statusCode)
                                                          }];

        if (_delegate != nil && [_delegate respondsToSelector:@selector(soapEngine:didBeforeParsingResponseData:)]) {
            NSData *newData = [_delegate soapEngine:self didBeforeParsingResponseData:data];
            if (newData == nil) {
                return nil;
            } else if (![newData isEqual:data]) {
                // se sono state apportate modifiche all'xml originale
                return newData;
            }
        }
    }
    
    return data;
}


#pragma mark - Parameters - private methods

- (void)addParamName:(NSString*)name withValue:(id)value attributes:(NSDictionary*)attributes
{
    NSDictionary *attr = attributes;
    if (_params == nil)
        [self clearValues];
    if (_replaceNillable && (value == nil || value == (id)[NSNull null])) {
        if (name) {
            // elemento nil XML
            [self appendFormat:SOAP_XML_ELEMENT_NIL, name];
        }
    } else if (_encryptionType != SOAP_ENCRYPT_NONE) {
        // codifica il contenuto
        NSString *base64 = [self encrypt:value];
        [self appendParamName:name value:base64 attributes:attr];
    } else {
        NSString *s_value = nil;
        if ([value isKindOfClass:[NSString class]]) {
            if ([value rangeOfString:[SOAP_XML_ELEMENT_CDATA substringToIndex:8]].location != NSNotFound) {
                // se gia contiene CDATA, estrapola il CDATA
                NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:SOAP_CDATA_REGEXP
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
                NSTextCheckingResult *match = [regEx firstMatchInString:value options:0 range:NSMakeRange(0, [value length])];
                if (match && match.range.location != NSNotFound)
                    s_value = [value substringWithRange:match.range];
                attr = _xsdDataTypes ? @{SOAP_XML_XSITYPE: @"string"} : nil;
            } else if (_escapingHTML) {
                s_value = [value soap_stringByEscapingForXML];
            } else {
                s_value = [value stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
                s_value = [s_value stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
            }
        }
        else if ([value isKindOfClass:[NSData class]]) {
            // converte in BASE64 e racchiude in un CDATA[]
            s_value = [SOAPBase64 base64EncodingWithData:value];
        }
        
        [self appendParamName:name value:s_value attributes:attr];
    }
}

- (void)appendParamName:(NSString*)name value:(id)value attributes:(NSDictionary*)attributes
{
    // attributi del tag
    if (name) {
        NSString *attr = [attributes stringAttributes];
        [self appendFormat:SOAP_XML_ELEMENT_ATTR, name, attr ?: @"", value ?: @"", name];
    }
}

- (void)appendFormat:(NSString*)format, ...
{
    OSSpinLockLock(&_lock);

    if (_params == nil)
        self.params = [NSMutableString string];
    
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString allocWithZone:NULL] initWithFormat:format arguments:args];
    [_params appendString:str];
    va_end(args);
    
    OSSpinLockUnlock(&_lock);
}

#pragma mark - Dictionary - private methods

- (void)convertDictionaryToXML:(NSDictionary*)dictionary keyName:(NSString*)keyName attributes:(NSDictionary*)attributes
{
    NSArray *keys = dictionary.allKeys;
    if ([keys containsObject:SOAP_XML_KEYVALUE] && [keys containsObject:SOAP_XML_KEYATTRIBUTES]) {
        id value = [dictionary objectForKey:SOAP_XML_KEYVALUE];
        NSDictionary *attr = [dictionary objectForKey:SOAP_XML_KEYATTRIBUTES];
        [self setValue:value forKey:keyName attributes:attr];
    } else {
        
        if (keyName) {
            // inizio tag padre
            NSString *attr = [attributes stringAttributes];
            [self appendFormat:SOAP_XML_ELEMENT_OPEN, keyName, attr ?: @""];
        }
        
        for (NSString *key in keys) {
            if (![key isEqualToString:SOAP_XML_KEYATTRIBUTES]) {
                id value = [dictionary objectForKey:key];
                NSDictionary *attr = [dictionary objectForKey:SOAP_XML_KEYATTRIBUTES];
                [self setValue:value forKey:key attributes:attr];
            }
        }
        
        if (keyName) {
            // fine tag padre
            [self appendFormat:SOAP_XML_ELEMENT_CLOSE, keyName];
        }
    }
}

#pragma mark - Array - private methods

- (void)convertArrayToXML:(NSArray*)array keyName:(NSString*)keyName subKeyName:(NSString*)subKeyName attributes:(NSDictionary*)attributes
{
    if (keyName) {
        // inizio tag padre
        NSString *attr = [attributes stringAttributes];
        [self appendFormat:SOAP_XML_ELEMENT_OPEN, keyName, attr ?: @""];
    }

    for (id value in array) {
        if (value == nil) {
            [self setValue:@"" forKey:subKeyName ?: @"string"];
        }
        else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSData class]]) {
            [self setValue:value forKey:subKeyName ?: @"string"];
        }
        else if ([value isKindOfClass:[NSDate class]]) {
            [self setValue:value forKey:subKeyName ?: @"dateTime"];
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            NSString *s_value = [(NSNumber*)value stringValue];
            CFNumberType numberType = CFNumberGetType((CFNumberRef)value);
            switch (numberType) {
                case kCFNumberIntType:
                case kCFNumberSInt8Type:
                case kCFNumberSInt16Type:
                case kCFNumberSInt32Type:
                case kCFNumberSInt64Type:
                case kCFNumberNSIntegerType:
                    [self addParamName:subKeyName ?: @"int" withValue:s_value attributes:_xsdDataTypes ? @{SOAP_XML_XSITYPE: @"int"} : nil];
                    break;
                case kCFNumberFloatType:
                case kCFNumberFloat32Type:
                case kCFNumberFloat64Type:
                case kCFNumberCGFloatType:
                    [self addParamName:subKeyName ?: @"float" withValue:s_value attributes:_xsdDataTypes ? @{SOAP_XML_XSITYPE: @"float"} : nil];
                    break;
                case kCFNumberShortType:
                    [self addParamName:subKeyName ?: @"short" withValue:s_value attributes:_xsdDataTypes ? @{SOAP_XML_XSITYPE: @"short"} : nil];
                    break;
                case kCFNumberLongType:
                    [self addParamName:subKeyName ?: @"long" withValue:s_value attributes:_xsdDataTypes ? @{SOAP_XML_XSITYPE: @"long"} : nil];
                    break;
                default:
                    [self addParamName:subKeyName ?: @"double" withValue:s_value attributes:_xsdDataTypes ? @{SOAP_XML_XSITYPE: @"double"} : nil];
                    break;
            }
        }
        else if ([value isKindOfClass:[NSDictionary class]]
                 || [value isKindOfClass:[NSArray class]]) {
            [self setValue:value forKey:subKeyName ?: _defaultTagName];
        }
        else if ([value isKindOfClass:[NSSet class]]) {
            NSArray *array = [(NSSet*)value allObjects];
            [self setValue:array forKey:subKeyName ?: _defaultTagName];
        }
        else if ([value isKindOfClass:[NSObject class]]) {
            NSString *name = [[NSStringFromClass([value class]) componentsSeparatedByString:@"."] lastObject];
            if (_prefixObjectName != nil && _replacePrefixObjectName != nil && [name hasPrefix:_prefixObjectName])
                name = [name stringByReplacingCharactersInRange:NSMakeRange(0, _prefixObjectName.length) withString:_replacePrefixObjectName];
            [self setValue:subKeyName ?: value forKey:name];
        }
        else {
            NSString *msg = [[NSString allocWithZone:NULL] initWithFormat:@"SOAPEngine invalid type of value on array values (%@: %@)", [value class], value];
            NSLog(@"%@", msg);
        }
    }
    
    if (keyName)
        // fine tag padre
        [self appendFormat:SOAP_XML_ELEMENT_CLOSE, keyName];
}

#pragma mark - Object - private methods

- (void)convertObjectToXML:(id)object keyName:(NSString*)keyName attributes:(NSDictionary*)attributes
{
    if (keyName) {
        // inizio tag padre
        NSString *attr = [attributes stringAttributes];
        [self appendFormat:SOAP_XML_ELEMENT_OPEN, keyName, attr ?: @""];
    }
    
    // converte le prorpietà dell'object
    [self convertClassToXML:[object class] fromObject:object];

    // se l'object è ereditato da un altro
    Class superClass = [object superclass];
    while (superClass != NSObject.class) {
        if (superClass != nil && ![superClass isEqual:[NSObject class]]) {
            // converte le proprietà dell'object padre
            [self convertClassToXML:superClass fromObject:object];
        }
        
        // procede al successivo padre
        superClass = [superClass superclass];
    }

    if (keyName)
        // fine tag padre
        [self appendFormat:SOAP_XML_ELEMENT_CLOSE, keyName];
}

- (void)convertClassToXML:(Class)class fromObject:(id)object
{
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(class, &count);
    for (int i = 0; i < count; ++i) {
        
        // recupera il nome e gli attributi della proprietà
        objc_property_t property = properties[i];
        NSString *name = [[NSString allocWithZone:NULL] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *propertyAttributes = [[NSString allocWithZone:NULL] initWithUTF8String:property_getAttributes(property)];
        NSArray *propertyAttributeArray = [propertyAttributes componentsSeparatedByString:@","];
        
        // controlla se è un tipo C primitivo (int, float, ecc)
        NSString *cType = nil;
        for (NSString *string in propertyAttributeArray) {
            if ([@"Ti Tf Td Tl Ts" rangeOfString:string].location != NSNotFound) {
                cType = [[NSString allocWithZone:NULL] initWithString:string];
                break;
            }
        }
        
        // recupera il valore
        id value = [object valueForKey:name];
        if (cType) {
            // se è un tipo primitivo lo gestisce separatamente
            if ([cType isEqualToString:@"Ti"]) {
                [self setIntegerValue:[value integerValue] forKey:name];
            } else if ([cType isEqualToString:@"Tf"]) {
                [self setFloatValue:[value floatValue] forKey:name];
            } else if ([cType isEqualToString:@"Td"]) {
                [self setDoubleValue:[value doubleValue] forKey:name];
            } else if ([cType isEqualToString:@"Tl"]) {
                [self setLongValue:[value longValue] forKey:name];
            } else if ([cType isEqualToString:@"Ts"]) {
                [self setIntegerValue:[value shortValue] forKey:name];
            }
        } else {
            // è una classe o nsobject
            [self setValue:value forKey:name];
        }
    }
    free(properties);
}

#pragma mark - Error - Private

- (void)errorWithError:(NSError*)error
{
    if (!_cancelDelegates && error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SOAPEngineDidFailWithErrorNotification
                                                            object:self
                                                          userInfo:@{SOAPEngineErrorKey: error}];
        
        if (_failBlock) {
            _failBlock(error);
        } else if (_delegate && [_delegate respondsToSelector:@selector(soapEngine:didFailWithError:)]) {
            [_delegate soapEngine:self didFailWithError:error];
        }
    }
}

#pragma mark - Private Properties

+ (NSDateFormatter *)dateFormatter
{
    // thread-safe
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *formatter = [dictionary objectForKey:@"SOAPDateFormatter"];
    if (!formatter)
    {
        formatter = [[NSDateFormatter allocWithZone:NULL] init];
        [dictionary setObject:formatter forKey:@"SOAPDateFormatter"];
    }
    
    return formatter;
}

#pragma mark - AES256/3DES

- (NSString*)encrypt:(id)data
{
    if ([data isKindOfClass:[NSString class]])
        return [data encryptWithType:_encryptionType password:_encryptionPassword];
    else if ([data isKindOfClass:[NSData class]])
        return [data encryptWithType:_encryptionType password:_encryptionPassword];
    
    return @"";
}

#pragma mark - UIID

- (NSString*)nonce
{
    // nonce
    NSString *userToken = [self userToken];
    NSString *nonce = [userToken substringFromIndex:userToken.length - 16];

    return nonce;
}

- (NSString*)userToken
{
    // nonce
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef uuidRef = CFUUIDCreateString(NULL, theUUID);
    NSString *userToken = [(__bridge NSString*)uuidRef stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(uuidRef);
    CFRelease(theUUID);
    
    return userToken;
}

@end

