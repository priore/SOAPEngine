//
//  SOAPConnection.h
//  SOAPEngine
//
//  Created by Danilo Priore on 15/12/14.
//  Copyright (c) 2014 Prioregroup.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOAPEngine.h"

typedef NSData* (^SOAPConnectionDidBeforeParsing)(NSInteger statusCode, NSData *data);
typedef void(^SOAPConnectionDidCompleted)(NSInteger statusCode, NSData* data, NSDictionary *dict, NSString* value);
typedef void(^SOAPConnectionDidFailed)(NSInteger statusCode, NSError *error);
typedef void(^SOAPConnectionDidSendBodyData)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
typedef void(^SOAPConnectionDidReceiveResponse)(NSURLResponse *response);
typedef void(^SOAPConnectionDidReceiveData)(NSData *data);

@interface SOAPConnection : NSObject

@property (nonatomic, assign) BOOL selfSigned;

//@property (nonatomic, strong) NSString *xmlString;
@property (nonatomic, strong) NSString *xpathQuery;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *clientCerficateName;
@property (nonatomic, strong) NSString *clientCerficatePassword;
@property (nonatomic, assign) SOAPCertificate clientCertificateMode;

@property (nonatomic, strong) NSString *soapNamespace;
@property (nonatomic, strong) NSString *methodName;

@property (nonatomic, assign) BOOL responseHeader;
@property (nonatomic, assign) BOOL actionNamespaceSlash;
@property (nonatomic, assign) BOOL retrievesAttributes;

@property (nonatomic, assign) SOAPEnryption encryptionType;
@property (nonatomic, strong) NSString *encryptionPassword;;

@property (nonatomic, copy) SOAPConnectionDidCompleted didCompleted;
@property (nonatomic, copy) SOAPConnectionDidSendBodyData didSendBodyData;
@property (nonatomic, copy) SOAPConnectionDidReceiveResponse didReceiveResponse;
@property (nonatomic, copy) SOAPConnectionDidReceiveData didReceiveData;
@property (nonatomic, copy) SOAPConnectionDidBeforeParsing didBeforeParse;
@property (nonatomic, copy) SOAPConnectionDidFailed didFailed;

- (void)loadRequest:(NSURLRequest*)request;
- (void)cancel;

@end
