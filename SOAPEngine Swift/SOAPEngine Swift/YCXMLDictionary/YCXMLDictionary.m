//
//  YCXMLDictionary.m
//  YCXMLDictionary
//
//  Created by YeTao on 16/7/1.
//
//

#import "YCXMLDictionary.h"
#import "TBXML.h"

@implementation YCXMLDictionary

#pragma mark - Public API

+ (NSDictionary *)dictionaryFromXMLString:(NSString *)xmlString {
    YCXMLDictionary *parse = [[YCXMLDictionary alloc] init];
    return [parse dictionaryFromXMLString:xmlString];
}

+ (NSDictionary *)dictionaryFromXMLData:(NSData *)xmlData {
    NSString *xmlString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    return [self dictionaryFromXMLString:xmlString];
}

+ (NSDictionary *)dictionaryFromXMLFile:(NSString *)fileName {
    fileName = [fileName stringByReplacingOccurrencesOfString:@".xml" withString:@""];
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"];
    NSString *xmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return [self dictionaryFromXMLString:xmlString];
}

#pragma mark - String Tools

/*!
 *  @brief char * 转化为NSString
 *  @param name 需要转化的字符串
 *  @return 转化后的NSString,已经转码,例如&amp;->&
 */
NSString *StringFromChar(char * name) {
    if (name == NULL || strlen(name) == 0) {
        return @"";
    }
    NSString *string = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
    //注释,忽略
    if ([string hasPrefix:@"<!--"] && [string hasSuffix:@"-->"]) {
        return @"";
    } else {
        return XMLDncodedString(string);
    }
}

/*!
 *  @brief XML特殊字符解码
 *  @param string 转码前字符串
 *  @return 转码后字符串
 */
NSString *XMLDncodedString(NSString * string){
    return [[[[[string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]
               stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"]
              stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"]
             stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""]
            stringByReplacingOccurrencesOfString:@"&apos;" withString:@"\'"];
}

#pragma mark - Parse API

- (NSDictionary *)dictionaryFromXMLString:(NSString *)xmlString {
    TBXML *tbxml = [TBXML tbxmlWithXMLString:xmlString error:nil];
    TBXMLElement *root = tbxml.rootXMLElement;
    id dict = [self objectWithElement:root];
    if ([dict isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)dict;
        if ([array count] == 1) {
            dict = @{StringFromChar(root->name):[array firstObject]};
        }
    }
    return dict;
}

/*!
 *  @brief 获取节点的某个属性对应的字典
 *  @param attribute <item id='xj'/>
 *  @return @{@"id":@"xj"}
 */
- (NSDictionary *)dictWithAttribute:(TBXMLAttribute *)attribute {
    return @{StringFromChar(attribute->name):StringFromChar(attribute->value)};
}

/*!
 *  @brief 获取某个节点的全部属性
 *  @param element <item id='xj' name='现金资产' value='-' link='' pic='account_zc_xj' />
 *  @return @{@"id":@"xj",@"name":@"现金资产",...}
 */
- (NSMutableDictionary *)attributeDictWithElement:(TBXMLElement *)element {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //获第一个属性
    TBXMLAttribute *attribute = element->firstAttribute;
    //不存在属性,空节点
    if (attribute == nil) {
        //取空属性节点的值,例如 : <item>哈哈</item>
        if (element->text) {
            NSString *value = StringFromChar(element->text);
            if ([value length] > 0) {
                dict[StringFromChar(element->name)] = value;
            }
            return dict;
        }
        //没有值<item></item>
        return dict;
    } else {
        //存在属性时,也要取该节点的值 <item id='xj'>哈哈</item>
        //此时返回@{@"id":@"xj",@"_value_":@"哈哈"}
        //_value_在头文件中定义-> YCXMLDictionaryValue
        if (element->text) {
            NSString *value = StringFromChar(element->text);
            if ([value length] > 0) {
                dict[YCXMLDictionaryValue] = value;
            }
        }
    }
    //遍历所有属性
    while (attribute) {
        [dict setValuesForKeysWithDictionary:[self dictWithAttribute:attribute]];
        attribute = attribute->next;
    }
    return dict;
}

- (id)objectWithElement:(TBXMLElement *)element {
    if (element == NULL) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    BOOL bArray = YES;
    BOOL bOnlyChild = NO;
    TBXMLElement *next = element ->nextSibling;
    if (next) {
        //如果兄弟节点的name都相等,则认为是数组.
        while (next) {
            if (strcmp(next ->previousSibling->name, next->name) != 0) {
                bArray = NO;
                break;
            }
            next = next ->nextSibling;
        }
    } else {
        bArray = NO;
    }
//    //没有兄弟节点,独生子.
//    if (!next) {
//        bOnlyChild = YES;
//    }
    NSMutableDictionary *children = [NSMutableDictionary dictionary];
    while (element) {
        //获取当前节点的属性
        NSMutableDictionary *attributeDict = [self attributeDictWithElement:element];
        //获取子节点信息
        NSDictionary *sub = [self objectWithElement:element->firstChild];
        if (sub) {
            //子节点是字典,设置到属性中
            if ([sub isKindOfClass:[NSDictionary class]]) {
                [attributeDict setValuesForKeysWithDictionary:sub];
            } else {
                //有属性值,则设置第一个子节点的name为key值[每个节点的name都相同]
                NSString *firstChildName = StringFromChar(element->firstChild->name);
                //加后缀,以做区分 ?
                NSString *subKey = [firstChildName stringByAppendingString:YCXMLDictionaryArraySubfix];
                attributeDict[subKey] = sub;
            }
        }
        if (bArray) {//当前节点是数组中一个
            [array addObject:attributeDict];
        } else {//当前节点的所有兄弟都并非相同
            NSString *elementName = StringFromChar(element->name);
            NSString *elementArrayName = [elementName stringByAppendingString:YCXMLDictionaryArraySubfix];
            //已经存在array,当前节点有其他若干相同的兄弟
            if (children[elementArrayName]) {
                id object = children[elementArrayName];
                if ([object isKindOfClass:[NSArray class]]) {
                    children[elementArrayName] = [object arrayByAddingObject:attributeDict];
                } else {//elementArrayName 可能等于elementName.
                    [children removeObjectForKey:elementArrayName];
                    children[elementArrayName] = @[object,attributeDict];
                }
            } else {
                //当前并未存储相同的节点
                if (children[elementName] == nil) {
                    //属性只有一个值,或者一个子节点.
                    if ([[attributeDict allKeys] count] == 1 &&
                        [[[attributeDict allKeys] firstObject] isEqualToString:elementName]) {
                        [children setValuesForKeysWithDictionary:attributeDict];
                    } else {
                        children[elementName] = attributeDict;
                    }
                } else {//已经存储了相同的节点,当前节点有其他若干相同的兄弟,则设置为数组
                    id object = children[elementName];
                    //先移除原先的节点
                    [children removeObjectForKey:elementName];
                    //拼装成数组,
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        children[elementArrayName] = @[object,attributeDict];
                    }
                }
            }
        }
        element = element->nextSibling;
    }
    //如果是数组,则返回数据,
    //如果不是数组,并且只有一个节点,返回一个单元素数组
    //如果不是数组,不止有一个节点,返回一个此元素的字典
    return bArray ? array : (bOnlyChild ? @[children] : children);
}

@end
