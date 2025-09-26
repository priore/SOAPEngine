//
//  SOAPX509.m
//  SOAPEngine
//
//  Created by Danilo Priore on 03/07/15.
//  Copyright (c) 2015 Prioregroup.com. All rights reserved.
//

#import "SOAPX509.h"
#import "SOAPSHA1.h"

@implementation SOAPX509

+ (NSDictionary*)getX509InfoWithName:(NSString*)certificateName password:(NSString*)password
{
    NSString *p12Path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:certificateName];
    NSData *p12Data = [[NSData alloc] initWithContentsOfFile:p12Path];
    
    CFStringRef p12Password = (__bridge CFStringRef)password;
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { p12Password };
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef p12Items;
    OSStatus result = SecPKCS12Import((__bridge CFDataRef)p12Data, optionsDictionary, &p12Items);
    CFRelease(optionsDictionary);
    
    if(result == noErr) {
        NSDictionary *item = (NSDictionary*)CFArrayGetValueAtIndex(p12Items, 0);
        SecCertificateRef cert = (SecCertificateRef)CFArrayGetValueAtIndex((__bridge CFArrayRef)[item objectForKey:(__bridge NSString*)kSecImportItemCertChain], 0);
        
        return [self dictionaryFromCerificateWithLongDescription:cert];
        
        //NSDictionary *attr = [self attributesWithCertificate:cert];
        //NSData *serial_number = [attr valueForKey:(__bridge id)kSecAttrSerialNumber];
        //NSData *issuer = [attr valueForKey:(__bridge id)kSecAttrIssuer];
    }
    
    return [NSDictionary new];
}

+ (NSDictionary *)attributesWithCertificate:(SecCertificateRef)certificate
{
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)(kSecClassCertificate), kSecClass,
                           [NSArray arrayWithObject:(__bridge id)certificate], kSecMatchItemList,
                           kCFBooleanTrue, kSecReturnAttributes,
                           kSecMatchLimitOne, kSecMatchLimit,
                           nil];
    CFDictionaryRef attrs = NULL;
    __unused OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(query), (CFTypeRef*)&attrs);
    NSDictionary *result = [(__bridge NSDictionary*)attrs mutableCopy];
    CFBridgingRelease(attrs);
    
    return result;
}

+ (NSDictionary*)dictionaryFromCerificateWithLongDescription:(SecCertificateRef)certificateRef {
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if (certificateRef == NULL)
        return dict;
    
    NSData *digest = [SOAPSHA1 getSHA1WithCertificate:certificateRef];
    [dict setObject:digest forKey:@"Digest"];
    
#if TARGET_OS_SIMULATOR || TARGET_OS_IOS || TARGET_OS_TV
    
    //    NSData *certificateData = (__bridge NSData *)SecCertificateCopyData(certificateRef);
    //    const unsigned char *certificateDataBytes = (const unsigned char *)[certificateData bytes];
    //    X509 *x509 = d2i_X509(NULL, &certificateDataBytes, [certificateData length]);
    //    ASN1_INTEGER *serialNumber = X509_get_serialNumber(x509);
    //    unsigned long serial = ASN1_INTEGER_get(serialNumber);
    //    [dict setValue:[NSString stringWithFormat:@"%lu", serial] forKey:@"Serial Number"];
    //    [dict setValue:[self certificateGetIssuerName:x509] forKey:@"Issuer Name"];
    //    // signature
    //    NSData *signature = [NSData dataWithBytes:x509->signature->data length:x509->signature->length];
    //    [dict setObject:signature forKey:@"Signature"];
    
#else
    
    const void *keys[] = { kSecOIDX509V1SubjectName, kSecOIDX509V1IssuerName, kSecOIDX509V1SerialNumber, kSecOIDX509V1Signature };
    CFArrayRef keySelection = CFArrayCreate(NULL, keys , sizeof(keys)/sizeof(keys[0]), &kCFTypeArrayCallBacks);
    
    CFErrorRef error;
    CFDictionaryRef vals = SecCertificateCopyValues(certificateRef, keySelection, &error);
    
    for(int i = 0; i < sizeof(keys)/sizeof(keys[0]); i++) {
        CFDictionaryRef dict_values = CFDictionaryGetValue(vals, keys[i]);
        CFStringRef label = CFDictionaryGetValue(dict_values, kSecPropertyKeyLabel);
        if (CFEqual(label, CFSTR("Serial Number"))) {
            CFStringRef value = CFDictionaryGetValue(dict_values, kSecPropertyKeyValue);
            if (value == NULL)
                continue;
            [dict setObject:(__bridge NSString*)(value) forKey:(__bridge NSString*)label];
        } else if (CFEqual(label, CFSTR("Signature"))) {
            CFDataRef value = CFDictionaryGetValue(dict_values, kSecPropertyKeyValue);
            if (value == NULL)
                continue;
            [dict setObject:(__bridge NSData*)(value) forKey:(__bridge NSString*)label];
        } else {
            CFArrayRef values = CFDictionaryGetValue(dict_values, kSecPropertyKeyValue);
            if (values == NULL)
                continue;
            [dict setObject:[self dictionaryFromDNwithSubjectName:values] forKey:(__bridge NSString*)label];
        }
    }
    
    CFRelease(vals);
    
#endif
    
    return dict;
}

#if TARGET_OS_SIMULATOR || TARGET_OS_IOS || TARGET_OS_TV

//+ (NSString*)certificateGetIssuerName:(X509*)certificateX509
//{
//    NSString *issuer = nil;
//    if (certificateX509 != NULL) {
//        X509_NAME *issuerX509Name = X509_get_issuer_name(certificateX509);
//
//        if (issuerX509Name != NULL) {
//            int nid = OBJ_txt2nid("O"); // organization
//            int index = X509_NAME_get_index_by_NID(issuerX509Name, nid, -1);
//
//            X509_NAME_ENTRY *issuerNameEntry = X509_NAME_get_entry(issuerX509Name, index);
//
//            if (issuerNameEntry) {
//                ASN1_STRING *issuerNameASN1 = X509_NAME_ENTRY_get_data(issuerNameEntry);
//
//                if (issuerNameASN1 != NULL) {
//                    unsigned char *issuerName = ASN1_STRING_data(issuerNameASN1);
//                    issuer = [NSString stringWithUTF8String:(char *)issuerName];
//                }
//            }
//        }
//    }
//
//    return issuer;
//}

#else

+ (NSDictionary*)dictionaryFromDNwithSubjectName:(CFArrayRef)array {
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    
    const void *keys[] = { kSecOIDCommonName, kSecOIDEmailAddress, kSecOIDOrganizationalUnitName, kSecOIDOrganizationName, kSecOIDLocalityName, kSecOIDStateProvinceName, kSecOIDCountryName };
    NSArray *labels = [NSArray arrayWithObjects:@"CN", @"E", @"OU", @"O", @"L", @"S", @"C", @"E", nil];
    
    for(int i = 0; i < sizeof(keys)/sizeof(keys[0]);  i++) {
        for (CFIndex n = 0 ; n < CFArrayGetCount(array); n++) {
            CFDictionaryRef dict_values = CFArrayGetValueAtIndex(array, n);
            if (CFGetTypeID(dict_values) != CFDictionaryGetTypeID())
                continue;
            CFTypeRef dictkey = CFDictionaryGetValue(dict_values, kSecPropertyKeyLabel);
            if (!CFEqual(dictkey, keys[i]))
                continue;
            CFStringRef str = (CFStringRef) CFDictionaryGetValue(dict_values, kSecPropertyKeyValue);
            [dict setObject:(__bridge  NSString*)str forKey:labels[i]];
        }
    }
    
    return dict;
}

#endif

@end
