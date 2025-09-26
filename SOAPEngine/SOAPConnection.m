//
//  SOAPConnection.m
//  SOAPEngine
//
//  Created by Danilo Priore on 15/12/14.
//  Copyright (c) 2014 Prioregroup.com. All rights reserved.
//

#import "SOAPTFHpple.h"
#import "SOAPConnection.h"
#import "NSData+SOAPEngine.h"
#import "NSString+SOAPEngine.h"
#import "NSDictionary+SOAPEngine.h"
#import "SOAPPrefix.pch"

@interface SOAPConnection() <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableDictionary *multiValues;
@property (nonatomic, strong) NSString *singleValue;

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, assign) BOOL canceled;

@property (nonatomic, strong) NSMutableData *webData;

@end

@implementation SOAPConnection

- (id)init
{
    if (self = [super init]) {
        _xpathQuery = @"/*/*";
    }
    
    return self;
}

- (void)loadRequest:(NSURLRequest*)request
{
    _task = nil;
    _queue = nil;
    _session = nil;
    _webData = nil;
    _canceled = NO;
    _multiValues = nil;
    _singleValue = nil;
    
    [NSURLCache.sharedURLCache removeCachedResponseForRequest:request];
    self.session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration delegate:self delegateQueue:nil];
    self.task = [_session dataTaskWithRequest:request];
    [_task resume];
}

- (void)cancel
{
    _canceled = YES;

    [_task cancel];
    [_session invalidateAndCancel];
    [_queue cancelAllOperations];
    
    _task = nil;
    _queue = nil;
    _session = nil;
    _webData = nil;
    _multiValues = nil;
    _singleValue = nil;
}

- (void)dealloc
{
    [self cancel];
}

#pragma mark - URLTaskSessionDelegates

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error != nil) {
        _multiValues = nil;
        _singleValue = nil;
        _didFailed(_statusCode, error);

        [_session invalidateAndCancel];
    } else {
        #if DEBUG
            double then = 0.0;
            double now = CFAbsoluteTimeGetCurrent();
        #endif
    
        __block NSArray *nodes = nil;
        __block SOAPTFHppleElement *element = nil;
        __block SOAPTFHppleElement *fault = nil;
    
        __block NSString *singleValue_1 = nil;
        __block NSString *singleValue_2 = nil;
    
        __weak SOAPConnection *wself = self;
    
        // nessun dato termina
        if (_webData == nil) {
            _didCompleted(_statusCode, nil, nil, nil);
            return;
        }
    
        // recupera l'xml completo
        //NSUInteger len = [_webData length];
        //Byte *bytes = (Byte*)malloc(len);
        //memcpy(bytes, [_webData bytes], len);
    
        // recupera i primi 40 caratteri (header) in modo da verificare che formato UTF sia
        //NSString *header = [[NSString allocWithZone:NULL] initWithBytes:bytes length:40 encoding:NSASCIIStringEncoding];
        //NSStringEncoding encoding = [header UTFType];
    
        // converte nel giusto formato UTF
        //_xmlString = [[NSString allocWithZone:NULL] initWithBytes:bytes length:len encoding:encoding];
        //_xmlString = [_xmlString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        //_xmlString = [_xmlString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    
        // free memory
        //free(bytes);
        //bytes = NULL;
    
        // prima del parsing
        if (_didBeforeParse != nil)
            _webData = [_didBeforeParse(_statusCode, _webData) mutableCopy];
    
        // controlla se deve annullare il parsing
        if (_webData == nil) {
            _didCompleted(_statusCode, nil, nil, nil);
            return;
        }
    
        // parsa l'xml
        __block SOAPTFHpple *xml = [SOAPTFHpple hppleWithXMLData:_webData];
        self.multiValues = [[NSMutableDictionary allocWithZone:NULL] init];
    
        _queue = [[NSOperationQueue allocWithZone:NULL] init];
        _queue.maxConcurrentOperationCount = 2;
    
        [_queue addOperationWithBlock:^{
            nodes = [xml searchWithXPathQuery:wself.responseHeader ? @"/*/*" : @"/*/*/*/*/*"];
            element = [nodes count] >= 1 ? [nodes firstObject] : nil;
            if (element.content != nil) {
                singleValue_1 = [[NSString allocWithZone:NULL] initWithString:element.content];
            }
        }];
    
        [_queue addOperationWithBlock:^{
            fault = [xml peekAtSearchWithXPathQuery:@"/*/*/*/*"];
            if (fault.content != nil) {
                singleValue_2 = [[NSString allocWithZone:NULL] initWithString:fault.content];
            }
        }];
    
        [_queue waitUntilAllOperationsAreFinished];
    
        if (element.content != nil) {
            self.singleValue = singleValue_1;
        } else {
            self.singleValue = singleValue_2;
        }
    
        _queue.maxConcurrentOperationCount = 3;
    
        [_queue addOperationWithBlock:^{
            // controlla se è un msg di errore
            NSString *soapServer = [[NSString allocWithZone:NULL] initWithFormat:@"%@:Server", wself.soapNamespace];
            if ([wself.singleValue isEqualToString:soapServer]
                || [wself.singleValue isEqualToString:@"soap:Server"]
                || [fault.tagName isEqualToString:@"faultcode"]) {
    
                [self->_queue cancelAllOperations];
    
                SOAPTFHppleElement *error = [xml peekAtSearchWithXPathQuery:@"/*/*/*/*[2]"];
                NSInteger code = [fault.content integerValue];
                NSError *err = [NSError errorWithDomain:SOAP_MSGTITLE
                                                   code:code
                                               userInfo:@{ NSLocalizedDescriptionKey: error.content }];
    
                wself.didFailed(wself.statusCode, err);
            }
        }];
    
        [_queue addOperationWithBlock:^{
            // controlla se è un msg dal server (errore?)
            if (wself.singleValue != nil && wself.encryptionType != SOAP_ENCRYPT_NONE) {
    
                // decrypt AES o 3DES
                NSString *value = [wself.singleValue decryptWithType:wself.encryptionType password:wself.encryptionPassword];
                wself.singleValue = [value copy];
            }
        }];
    
        [_queue addOperationWithBlock:^{
            // recupera multi valori (dictionary)
            if (nodes != nil) {
                if (nodes.count > 0) {
                    for (SOAPTFHppleElement *node in nodes) {
                        [wself convertToDictionary:node parent:wself.multiValues];
                    }
                } else {
                    // se non ci sono valori allora cerca più internamente
                    NSArray *nodes = [xml searchWithXPathQuery:@"/*/*/*/*"];
                    if (nodes && [nodes count] > 0) {
                        NSString *newXML = [[nodes firstObject] content];
                        if (newXML) {
                            NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:SOAP_XML_REGEXP options:0 error:nil];
                            NSTextCheckingResult *match = [regEx firstMatchInString:newXML options:0 range:NSMakeRange(0, [newXML length])];
                            if (match && match.range.location != NSNotFound) {
                                // se l'interno cè a sua volta un altro xml
                                NSData *data = [newXML dataUsingEncoding:[newXML UTFType] allowLossyConversion:YES];
                                if (data) {
                                    xml = [SOAPTFHpple hppleWithXMLData:data];
                                    if (xml) {
                                        // parsa e restituisce il dictionary con quest'ultimo xml
                                        nodes = [xml searchWithXPathQuery:@"//*"];
                                        if (nodes && [nodes count] > 0) {
                                            for (SOAPTFHppleElement *node in nodes)
                                                [wself convertToDictionary:node parent:wself.multiValues];
                                        }
                                    }
                                }
                            } else {
                                // se c'è un json parsa e restituisce con quest'ultimo
                                NSError *error = nil;
                                NSData *data = [newXML dataUsingEncoding:[newXML UTFType]];
                                if (data) {
                                    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                    if (error == nil) {
                                        if ([json isKindOfClass:[NSDictionary class]]) {
                                            [wself.multiValues addEntriesFromDictionary:json];
                                        } else if ([json isKindOfClass:[NSArray class]]) {
                                            NSMutableDictionary *dict = [[NSMutableDictionary allocWithZone:NULL] init];
                                            [dict setValue:json forKey:@"array"];
                                            [wself.multiValues addEntriesFromDictionary:dict];
                                        }
                                    }
                                } else {
                                    // se invece è un XML base
                                    NSData *data = [newXML dataUsingEncoding:[newXML UTFType] allowLossyConversion:YES];
                                    SOAPTFHpple *xml = [SOAPTFHpple hppleWithXMLData:data];
                                    NSArray *nodes = [xml searchWithXPathQuery:@"/*"];
                                    if (nodes && [nodes count] > 0) {
                                        for (SOAPTFHppleElement *node in nodes)
                                            [wself convertToDictionary:node parent:wself.multiValues];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }];
    
        [_queue waitUntilAllOperationsAreFinished];
    
        #if DEBUG
            then = CFAbsoluteTimeGetCurrent();
            NSLog(@"SOAPEngine Parsing time %.05f sec", then - now);
        #endif
    
        _didCompleted(_statusCode, _webData, _multiValues, _singleValue);
        [_session finishTasksAndInvalidate];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    if (_didSendBodyData != nil)
        _didSendBodyData(bytesSent, totalBytesSent, totalBytesExpectedToSend);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    // tentativo di accesso già eseguito senza successo
    if (challenge.previousFailureCount > 0) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)[challenge failureResponse];
        NSError *error = [NSError errorWithDomain:SOAP_MSGTITLE
                                             code:135
                                         userInfo:@{
                                             NSLocalizedDescriptionKey: @"Could not authenticate you",
                                             NSLocalizedFailureReasonErrorKey: response
                                         }];
        _didFailed(_statusCode, error);
        
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        
        return;
    }
    
    NSString *authMethod = [challenge.protectionSpace authenticationMethod];
    if (([authMethod isEqual:NSURLAuthenticationMethodNTLM]
         || [authMethod isEqualToString:NSURLAuthenticationMethodDefault]
         || [authMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]
         || [authMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest])) {
        
        if (challenge.previousFailureCount == 0) {
            NSURLCredential *credential = [NSURLCredential credentialWithUser:_username password:_password persistence:NSURLCredentialPersistenceForSession];
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
        
        return;
        
    } else if ([authMethod isEqualToString:NSURLAuthenticationMethodServerTrust] && _selfSigned) {
        
        NSURLProtectionSpace * protectionSpace = [challenge protectionSpace];
        NSURLCredential* credentail = [NSURLCredential credentialForTrust:[protectionSpace serverTrust]];
        [[challenge sender] useCredential:credentail forAuthenticationChallenge:challenge];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credentail);

        return;
    } else if (([authMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]
            || [authMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
            && [_clientCerficateName length] > 0) {
        
        OSStatus status = errSecAuthFailed;
        NSString *certPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:_clientCerficateName];
        NSData *certData = [[NSData allocWithZone:NULL] initWithContentsOfFile:certPath];

        if (certData == nil) {
            // NOP
        } else if (_clientCertificateMode == SOAP_CERTIFICATE_DEFAULT) {
            
            // per mantenere la compatibilità con la v.1.10
            NSString *pwd = _clientCerficatePassword;
            if (pwd == nil || (pwd && [pwd length] == 0)) pwd = _password;
            
            CFStringRef p12Password = (__bridge CFStringRef)pwd;
            const void *keys[] = { kSecImportExportPassphrase };
            const void *values[] = { p12Password };
            CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
            CFArrayRef p12Items;
            status = SecPKCS12Import((__bridge CFDataRef)certData, optionsDictionary, &p12Items);
            CFRelease(optionsDictionary);
            if(status == noErr)
            {
                CFDictionaryRef identityDict = CFArrayGetValueAtIndex(p12Items, 0);
                SecIdentityRef identityApp =(SecIdentityRef)CFDictionaryGetValue(identityDict,kSecImportItemIdentity);
                
                SecCertificateRef certRef;
                SecIdentityCopyCertificate(identityApp, &certRef);
                
                SecCertificateRef certArray[1] = { certRef };
                CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
                //CFRelease(certRef);
                
                SecTrustSetAnchorCertificates(challenge.protectionSpace.serverTrust, myCerts);
                NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identityApp certificates:(__bridge NSArray *)myCerts persistence:NSURLCredentialPersistencePermanent];
                CFRelease(myCerts);
                
                [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
                
                return;
            }
            
        } else if (_clientCertificateMode == SOAP_CERTIFICATE_PINNING) {
            
            do
            {
                SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
                if(serverTrust == nil)
                    break; // failed
                
                SecTrustResultType result;
                status = SecTrustEvaluate(serverTrust, &result);
                if(!(status == errSecSuccess))
                    break; // failed
                
                status = errSecAuthFailed; // reset
                
                SecCertificateRef serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
                if(serverCertificate == nil)
                    break; // failed
                
                CFDataRef serverCertificateData = SecCertificateCopyData(serverCertificate);
                if(serverCertificateData == nil)
                    break; // failed
                
                const UInt8* const data = CFDataGetBytePtr(serverCertificateData);
                const CFIndex size = CFDataGetLength(serverCertificateData);
                
                NSData *certServer = [[NSData allocWithZone:NULL] initWithBytes:data length:(NSUInteger)size];
                CFRelease(serverCertificateData);
                
                if(certServer == nil)
                    break; // failed
                
                if (![certServer isEqualToData:certData])
                    break; // failed;
                
                // The only good exit point
                NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
                [[challenge sender] useCredential: credential forAuthenticationChallenge:challenge];
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);

                return;
            } while(0);
        }
    
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)[challenge failureResponse];
        NSError *error = [NSError errorWithDomain:SOAP_MSGTITLE
                                             code:status
                                         userInfo:@{
                                             NSLocalizedDescriptionKey : @"SOAPEngine certificate not found or invalid password!",
                                             NSLocalizedFailureReasonErrorKey: response
                                         }];
        _didFailed(_statusCode, error);

        [[challenge sender] cancelAuthenticationChallenge:challenge];
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);

    } else {
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    _statusCode = ((NSHTTPURLResponse *)response).statusCode;
    
    if (_didReceiveResponse != nil)
        _didReceiveResponse(response);
    
    if (_canceled) {
        completionHandler(NSURLSessionResponseCancel);
        [_session invalidateAndCancel];
    } else {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if (_webData == nil)
        _webData = [[NSMutableData allocWithZone:NULL] init];
    
    [_webData appendData:data];
    
    if (_didReceiveData != nil)
        _didReceiveData(_webData);
}

#pragma mark - Dictionary

- (void)convertToDictionary:(SOAPTFHppleElement*)element parent:(NSMutableDictionary*)parentDict
{
    NSString *tagName = element.tagName;
    NSArray *children = element.children;
    NSDictionary *attributes = element.attributes;
    NSString *content = element.content;
    
    // controlla se già esiste una key uguale
    id existDict = [parentDict objectForKey:tagName];
    if (existDict) {
        // se già esiste controlla che tipo sia (dictionary o array)
        NSMutableArray *array = nil;
        if ([existDict isKindOfClass:[NSMutableArray class]]) {
            // è già un array, allora uso questo
            array = (NSMutableArray*)existDict;
        } else if ([existDict isKindOfClass:[NSMutableDictionary class]]) {
            // è un dictionary, allora creo un array di dictionary
            array = [[NSMutableArray allocWithZone:NULL] initWithObjects:existDict, nil];
            // sostituisce l'elemento con l'array appena creato
            // contenente anche il l'elemento precedente
            [parentDict setObject:array forKey:tagName];
        } else if ([existDict isKindOfClass:[NSString class]] || [existDict isMemberOfClass:[NSString class]]) {
            // è una stringa, crea un array di stringhe
            array = [[NSMutableArray allocWithZone:NULL] initWithObjects:existDict, nil];
            // sostituisce l'elemento con l'array appena creato
            // contenente anche il l'elemento precedente
            [parentDict setObject:array forKey:tagName];
        } else  {
            // tipo non valido
            NSString *msg = [[NSString allocWithZone:NULL] initWithFormat:@"SOAPEngine invalid element type for tag '%@'.", tagName];
            NSLog(@"%@", msg);
        }
        
        // se ci sono sotto elementi
        if (children.count > 0) {
            NSMutableDictionary *parentChild = [[NSMutableDictionary allocWithZone:NULL] init];
            for (id obj in children) {
                // li aggiunge ad un nuovo dictionary
                [self convertToDictionary:obj parent:parentChild];
            }

            if (tagName && [tagName length] > 0) {
                if (_retrievesAttributes) {
                    [parentChild setValue:attributes forKey:SOAP_XML_KEYATTRIBUTES];
                }
            }
            
            // aggiunge il nuovo dictionary al padre
            if (array != nil)
                [array addObject:parentChild];
            
        } else if ([existDict isKindOfClass:[NSString class]] || [existDict isMemberOfClass:[NSString class]]) {
            if (array != nil) {
                id value = nil;
                if (_encryptionType == SOAP_ENCRYPT_NONE)
                    // converte eventuali unicode \\Uxxxx e caratteri speciali HTML &xxx;
                    value = [content stringUnescaping];
                else
                    // decripta base64 + aes256/3des
                    value = [content decryptWithType:_encryptionType password:_encryptionPassword];

                id object = [self valueWithAttributes:attributes value:value];
                [array addObject:object];
            }
        } else {
            if (array != nil) {
                id value = nil;
                if ([[array firstObject] isKindOfClass:[NSString class]] || [[array firstObject] isMemberOfClass:[NSString class]]) {
                    if (_encryptionType == SOAP_ENCRYPT_NONE)
                        // converte eventuali unicode \\Uxxxx e caratteri speciali HTML &xxx;
                        value = [content stringUnescaping];
                    else
                        // decripta base64 + aes256/3des
                        value = [content decryptWithType:_encryptionType password:_encryptionPassword];
                    id object = [self valueWithAttributes:attributes value:value];
                    [array addObject:object];
                } else if ([[array firstObject] isKindOfClass:[NSData class]] || [[array firstObject] isMemberOfClass:[NSData class]]) {
                    if (_encryptionType != SOAP_ENCRYPT_NONE) {
                        // decripta aes256
                        NSData *decoded = [SOAPBase64 base64DecodingWithString:content];
                        value = [decoded decryptWithType:_encryptionType password:_encryptionPassword];
                    } else
                        value = content;
                    id object = [self valueWithAttributes:attributes value:value];
                    [array addObject:object];
                } else {
                    // se è altro crea un dizionario per la singola voce
                    id object = [self valueWithAttributes:attributes value:content];
                    NSMutableDictionary *childDict = [[NSMutableDictionary allocWithZone:NULL] initWithObjects:@[object] forKeys:@[tagName]];
                    [array addObject:childDict];
                }
            }
        }
    } else {
        // l'elemento non esiste, controlla se ci sono sotto elementi
        if (children.count > 0) {
            SOAPTFHppleElement *firstChild = [element firstChild];
            if (firstChild.tagName == nil) {
                id object = [self valueWithAttributes:attributes value:firstChild.content];
                NSMutableDictionary *childDict = [[NSMutableDictionary allocWithZone:NULL] initWithObjects:@[object] forKeys:@[tagName]];
                [parentDict addEntriesFromDictionary:childDict];
            } else {
                NSMutableDictionary *parentChild = [[NSMutableDictionary allocWithZone:NULL] init];
                for (id obj in children) {
                    // li aggiunge ad un nuovo dictionary
                    [self convertToDictionary:obj parent:parentChild];
                }
                
                if (tagName && [tagName length] > 0) {
                    if (_retrievesAttributes) {
                        NSMutableDictionary *dict = [[NSMutableDictionary allocWithZone:NULL] init];
                        [dict setValue:attributes forKey:SOAP_XML_KEYATTRIBUTES];
                        [dict addEntriesFromDictionary:parentChild];
                        [parentDict setValue:dict forKey:tagName];
                    } else {
                        // sostituisce il padre con i sotto elementi
                        [parentDict setValue:parentChild forKey:tagName];
                    }
                }
            }

        } else {
            // lo aggiunge cosi come è
            id value = nil;
            if (_encryptionType == SOAP_ENCRYPT_NONE)
                // converte eventuali unicode \\Uxxxx e caratteri speciali HTML &xxx;
                value = [content stringUnescaping];
            else
                // decripta base64 + aes256/3des
                value = [content decryptWithType:_encryptionType password:_encryptionPassword];
            id object = [self valueWithAttributes:attributes value:value];
            NSMutableDictionary *childDict = [[NSMutableDictionary allocWithZone:NULL] initWithObjects:@[object] forKeys:@[tagName]];
            [parentDict addEntriesFromDictionary:childDict];
        }
    }
}

#pragma mark - Attributes

- (id)valueWithAttributes:(NSDictionary*)attributes value:(id)value
{
    if (_retrievesAttributes)
        return [attributes attributesWithKeyValue:value];
    
    return value ?: @"";
}

@end
