//
//  SOAP3DES.m
//  SOAPEngine
//
//  Created by Danilo Priore on 02/09/14.
//  Copyright (c) 2014 Prioregroup.com. All rights reserved.
//

#import "SOAP3DES.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@implementation SOAP3DES

#pragma mark - Encrypt

+ (NSData*)TripleDESEncryptData:(NSData*)data withKey:(NSString*)key
{
    NSData *d_key = [key dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char sha256[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([d_key bytes], (CC_LONG)[d_key length], sha256);
    const void *digest = [[NSData dataWithBytes:sha256 length:kCCKeySize3DES] bytes];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSize3DES;
    void* buffer                = malloc(bufferSize);
    
    size_t numBytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithm3DES, kCCOptionECBMode + kCCOptionPKCS7Padding,
                                          digest, kCCKeySize3DES,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

+ (NSData*)TripleDESEncryptString:(NSString*)string withKey:(NSString*)key
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self TripleDESEncryptData:data withKey:key];
}

#pragma mark - Decrypt

+ (NSData*)TripleDESDecryptData:(NSData*)data withKey:(NSString*)key
{
    NSData *d_key = [key dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char sha256[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([d_key bytes], (CC_LONG)[d_key length], sha256);
    const void *digest = [[NSData dataWithBytes:sha256 length:kCCKeySize3DES] bytes];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSize3DES;
    void* buffer                = malloc(bufferSize);
    
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithm3DES, kCCOptionECBMode + kCCOptionPKCS7Padding,
                                          digest, kCCKeySize3DES,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

+ (NSData*)TripleDESDecryptString:(NSString*)string withKey:(NSString*)key
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self TripleDESDecryptData:data withKey:key];
}

@end
