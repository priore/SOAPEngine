//
//  TFHppleElement.m
//  Hpple
//
//  Created by Geoffrey Grosenbach on 1/31/09.
//
//  Copyright (c) 2009 Topfunky Corporation, http://topfunky.com
//
//  MIT LICENSE
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "SOAPTFHppleElement.h"

static NSString * const TFHppleNodeContentKey           = @"nodeContent";
static NSString * const TFHppleNodeNameKey              = @"nodeName";
static NSString * const TFHppleNodeChildrenKey          = @"nodeChildArray";
static NSString * const TFHppleNodeAttributeArrayKey    = @"nodeAttributeArray";
static NSString * const TFHppleNodeAttributeNameKey     = @"attributeName";

@interface SOAPTFHppleElement ()
@property (nonatomic, retain, readwrite) SOAPTFHppleElement *parent;
@end

@implementation SOAPTFHppleElement
@synthesize parent;

- (id) initWithNode:(NSDictionary *) theNode
{
    if (!(self = [super init]))
        return nil;
    
    node = [[NSDictionary alloc] initWithDictionary:theNode];
    
    return self;
}

+ (SOAPTFHppleElement *) hppleElementWithNode:(NSDictionary *) theNode {
    return [[[self class] alloc] initWithNode:theNode];
}

#pragma mark -

- (NSString *) content
{
    return [node objectForKey:TFHppleNodeContentKey];
}


- (NSString *) tagName
{
    return [node objectForKey:TFHppleNodeNameKey];
}

- (NSArray *) children
{
    NSMutableArray *children = [NSMutableArray array];
    NSArray *childs = [node objectForKey:TFHppleNodeChildrenKey];
    for (NSDictionary *child in childs) {
        SOAPTFHppleElement *element = [SOAPTFHppleElement hppleElementWithNode:child];
        element.parent = self;
        [children addObject:element];
    }
    return children;
}

- (SOAPTFHppleElement *) firstChild
{
    NSArray * children = self.children;
    if (children.count)
        return [children objectAtIndex:0];
    return nil;
}


- (NSDictionary *) attributes
{
    NSMutableDictionary * translatedAttributes = [NSMutableDictionary dictionary];
    NSArray *childs =  [node objectForKey:TFHppleNodeAttributeArrayKey];
    for (NSDictionary * attributeDict in childs) {
        [translatedAttributes setObject:[attributeDict objectForKey:TFHppleNodeContentKey]
                                 forKey:[attributeDict objectForKey:TFHppleNodeAttributeNameKey]];
    }
    return translatedAttributes;
}

- (NSString *) objectForKey:(NSString *) theKey
{
    return [[self attributes] objectForKey:theKey];
}

- (id) description
{
    return [node description];
}

@end
