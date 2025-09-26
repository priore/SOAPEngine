//
//  XPathQuery.m
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SOAPXPathQuery.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

NSDictionary *SOAPDictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult);
NSArray *SOAPPerformXPathQuery(xmlDocPtr doc, NSString *query);

NSDictionary *SOAPDictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult)
{
  NSMutableDictionary *resultForNode = [NSMutableDictionary dictionary];

  if (currentNode->name)
    {
      NSString *currentNodeContent =
        [NSString stringWithCString:(const char *)currentNode->name encoding:NSUTF8StringEncoding];
      [resultForNode setObject:currentNodeContent forKey:@"nodeName"];
    }

  if (currentNode->content && currentNode->content != (xmlChar *)-1)
    {
      NSString *currentNodeContent =
        [NSString stringWithCString:(const char *)currentNode->content encoding:NSUTF8StringEncoding];

      if ([[resultForNode objectForKey:@"nodeName"] isEqual:@"text"] && parentResult)
        {
          [parentResult
            setObject:
              [currentNodeContent
                stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
            forKey:@"nodeContent"];
          return nil;
        }

      [resultForNode setObject:currentNodeContent forKey:@"nodeContent"];
    }

  xmlAttr *attribute = currentNode->properties;
  if (attribute)
    {
      NSMutableArray *attributeArray = [NSMutableArray array];
      while (attribute)
        {
          NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
          NSString *attributeName =
            [NSString stringWithCString:(const char *)attribute->name encoding:NSUTF8StringEncoding];
          if (attributeName)
            {
              [attributeDictionary setObject:attributeName forKey:@"attributeName"];
            }

          if (attribute->children)
            {
              NSDictionary *childDictionary = SOAPDictionaryForNode(attribute->children, attributeDictionary);
              if (childDictionary)
                {
                  [attributeDictionary setObject:childDictionary forKey:@"attributeContent"];
                }
            }

          if ([attributeDictionary count] > 0)
            {
              [attributeArray addObject:attributeDictionary];
            }
          attribute = attribute->next;
        }

      if ([attributeArray count] > 0)
        {
          [resultForNode setObject:attributeArray forKey:@"nodeAttributeArray"];
        }
    }

  xmlNodePtr childNode = currentNode->children;
  if (childNode)
    {
      NSMutableArray *childContentArray = [NSMutableArray array];
      while (childNode)
        {
          NSDictionary *childDictionary = SOAPDictionaryForNode(childNode, resultForNode);
          if (childDictionary)
            {
              [childContentArray addObject:childDictionary];
            }
          childNode = childNode->next;
        }
      if ([childContentArray count] > 0)
        {
          [resultForNode setObject:childContentArray forKey:@"nodeChildArray"];
        }
    }

  return resultForNode;
}

NSArray *SOAPPerformXPathQuery(xmlDocPtr doc, NSString *query)
{
  xmlXPathContextPtr xpathCtx;
  xmlXPathObjectPtr xpathObj;

  /* Create xpath evaluation context */
  xpathCtx = xmlXPathNewContext(doc);
  if(xpathCtx == NULL)
    {
      NSLog(@"Unable to create XPath context.");
      return nil;
    }

  /* Evaluate xpath expression */
  xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
  if(xpathObj == NULL) {
    NSLog(@"Unable to evaluate XPath.");
    xmlXPathFreeContext(xpathCtx);
    return nil;
  }

  xmlNodeSetPtr nodes = xpathObj->nodesetval;
  if (!nodes)
    {
      NSLog(@"Nodes was nil.");
      xmlXPathFreeObject(xpathObj);
      xmlXPathFreeContext(xpathCtx);
      return nil;
    }

  NSMutableArray *resultNodes = [NSMutableArray array];
  for (NSInteger i = 0; i < nodes->nodeNr; i++)
    {
      NSDictionary *nodeDictionary = SOAPDictionaryForNode(nodes->nodeTab[i], nil);
      if (nodeDictionary)
        {
          [resultNodes addObject:nodeDictionary];
        }
    }

  /* Cleanup */
  xmlXPathFreeObject(xpathObj);
  xmlXPathFreeContext(xpathCtx);

  return resultNodes;
}

NSArray *SOAPPerformHTMLXPathQuery(NSData *document, NSString *query)
{
  xmlDocPtr doc;

  /* Load XML document */
  doc = htmlReadMemory([document bytes], (int)[document length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);

  if (doc == NULL)
    {
      NSLog(@"Unable to parse.");
      return nil;
    }

  NSArray *result = SOAPPerformXPathQuery(doc, query);
  xmlFreeDoc(doc);

  return result;
}

NSArray *SOAPPerformXMLXPathQuery(NSData *document, NSString *query)
{
  xmlDocPtr doc;

  /* Load XML document */
  doc = xmlReadMemory([document bytes], (int)[document length], "", NULL, XML_PARSE_RECOVER);

  if (doc == NULL)
    {
      NSLog(@"Unable to parse.");
      return nil;
    }

  NSArray *result = SOAPPerformXPathQuery(doc, query);
  xmlFreeDoc(doc);

  return result;
}
