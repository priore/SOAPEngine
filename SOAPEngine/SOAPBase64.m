//
//  SOAPBase64.m
//  SOAPEngine
//
//  Created by Danilo Priore on 25/06/13.
//  Copyright (c) 2013 Prioregroup.com. All rights reserved.
//

#import "SOAPBase64.h"

@implementation SOAPBase64

static char soap_encodingTable[64] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };


#pragma mark - Encode

+ (NSString *)base64EncodingWithData:(NSData*)data
{
	const unsigned char	*bytes = [data bytes];
	NSMutableString *result = [NSMutableString stringWithCapacity:[data length]];
	unsigned long ixtext = 0;
	unsigned long lentext = [data length];
	long ctremaining = 0;
	unsigned char inbuf[3], outbuf[4];
	short i = 0;
	short ctcopy = 0;
	unsigned long ix = 0;
    
	while( YES ) {
		ctremaining = lentext - ixtext;
		if( ctremaining <= 0 ) break;
        
		for( i = 0; i < 3; i++ ) {
			ix = ixtext + i;
			if( ix < lentext ) inbuf[i] = bytes[ix];
			else inbuf [i] = 0;
		}
        
		outbuf [0] = (inbuf [0] & 0xFC) >> 2;
		outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
		outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
		outbuf [3] = inbuf [2] & 0x3F;
		ctcopy = 4;
        
		switch( ctremaining ) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
		}
        
		for( i = 0; i < ctcopy; i++ )
			[result appendFormat:@"%c", soap_encodingTable[outbuf[i]]];
        
		for( i = ctcopy; i < 4; i++ )
			[result appendFormat:@"%c",'='];
        
		ixtext += 3;
	}
    
	return result;
}

+ (NSString *)base64EncodingWithString:(NSString*)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self base64EncodingWithData:data];
}

#pragma mark - Decode

+ (NSData *)base64DecodingWithString:(NSString*)string
{
    if (string) {
        return [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }
    
    return nil;
}

+ (NSString *)stringDecodingBase64WithString:(NSString*)string
{
    NSData *base64 = [SOAPBase64 base64DecodingWithString:string];
    return [[NSString alloc] initWithData:base64 encoding:NSUTF8StringEncoding];
}

@end
