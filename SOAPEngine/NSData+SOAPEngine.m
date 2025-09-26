//
//  NSData+SOAPEngine.m
//  SOAPEngine
//
//  Created by Danilo Priore on 03/07/15.
//  Copyright (c) 2015 Prioregroup.com. All rights reserved.
//

#import "NSData+SOAPEngine.h"
#import "NSString+SOAPEngine.h"
#import "SOAPAES256.h"
#import "SOAP3DES.h"
#import "SOAPBase64.h"

@implementation NSData (SOAPEngine)

- (NSString*)encryptWithType:(SOAPEnryption)type password:(NSString*)password
{
    NSData *encrypted = nil;
    if (type == SOAP_ENCRYPT_AES256)
        encrypted = [SOAPAES256 AES256EncryptData:self withKey:password];
    else if (type == SOAP_ENCRYPT_3DES)
        encrypted = [SOAP3DES TripleDESEncryptData:self withKey:password];
    return [SOAPBase64 base64EncodingWithData:encrypted];
}

- (NSData*)decryptWithType:(SOAPEnryption)type password:(NSString*)password
{
    if (type == SOAP_ENCRYPT_AES256)
        return [SOAPAES256 AES256DecryptData:self withKey:password];
    else if (type == SOAP_ENCRYPT_3DES)
        return [SOAP3DES TripleDESDecryptData:self withKey:password];
    
    return [NSData new];
}

- (NSString*)toString
{
        NSUInteger len = [self length];
        Byte *bytes = (Byte*)malloc(len);
        memcpy(bytes, [self bytes], len);
    
        // recupera i primi 40 caratteri (header) in modo da verificare che formato UTF sia
        NSString *header = [[NSString allocWithZone:NULL] initWithBytes:bytes length:40 encoding:NSASCIIStringEncoding];
        NSStringEncoding encoding = [header UTFType];
    
        // converte nel giusto formato UTF
        NSString *xml = [[NSString allocWithZone:NULL] initWithBytes:bytes length:len encoding:encoding];
        xml = [xml stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        xml = [xml stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    
        // free memory
        free(bytes);
        bytes = NULL;
    
    return xml;
}

@end
