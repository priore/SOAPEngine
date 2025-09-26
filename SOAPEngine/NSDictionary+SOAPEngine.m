//
//  NSDictionary+SOAPEngine.m
//  SOAPEngine
//
//  Created by Danilo Priore on 03/07/15.
//  Copyright (c) 2015 Prioregroup.com. All rights reserved.
//

#import "NSDictionary+SOAPEngine.h"
#import "SOAPPrefix.pch"

@implementation NSDictionary (SOAPEngine)

- (NSString*)stringAttributes
{
    // attributi del tag
    NSMutableString *attr = [NSMutableString string];
    [[self allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        id value = [self valueForKey:key];
        if (![value isKindOfClass:[NSNumber class]])
            [attr appendFormat:@" %@=\"%@\"", key, value];
        else
            [attr appendFormat:@" %@=%@", key, value];
    }];
    
    return attr;
}

- (id)attributesWithKeyValue:(id)value
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:value ?: @"" forKey:SOAP_XML_KEYVALUE];
    [dict setValue:self forKey:SOAP_XML_KEYATTRIBUTES];
    return  dict;
}

@end
