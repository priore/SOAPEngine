//
//  YCXMLDictionary.h
//  YCXMLDictionary
//
//  Created by YeTao on 16/7/1.
//
//

#import <Foundation/Foundation.h>

static NSString * const YCXMLDictionaryValue = @"_value_";
static NSString * const YCXMLDictionaryArraySubfix = @"";
 
/*!
 *  @brief 根据TBXML解析XML
 *  @code
 *  NSDictionary *xmlDict = [YCXMLDictionary dictionaryFromXMLString:<#xmlString#>];
 *  @endcode
 *  @code
 *  NSDictionary *xmlDict = [YCXMLDictionary dictionaryFromXMLData:<#xmlData#>];
 *  @endcode
 *  @code
 *  NSDictionary *xmlDict = [YCXMLDictionary dictionaryFroXMLFile:<#fileName#>];
 *  @endcode
 */

@interface YCXMLDictionary : NSObject

/*!
 *  @brief 从xmlString解析
 *  @param xmlString 需要解析的xml字符串
 *  @return 解析后的字典, 失败则返回nil
 *  @code
 *  NSDictionary *xmlDict = [YCXMLDictionary dictionaryFromXMLString:<#xmlString#>];
 */
+ (NSDictionary *)dictionaryFromXMLString:(NSString *)xmlString;

/*!
 *  @brief 从xmlData解析
 *  @param xmlData 需要解析的xml数据,接口返回时会返回NSData
 *  @return 解析后的字典, 失败则返回nil
 *  @code
 *  NSDictionary *xmlDict = [YCXMLDictionary dictionaryFromXMLData:<#xmlData#>];
 */
+ (NSDictionary *)dictionaryFromXMLData:(NSData *)xmlData;

/*!
 *  @brief xml文件从从NSBundle中读取
 *  @param fileName 文件名,例如 <b>weak_account_list</b>
 *  @warning 不需要加后缀名
 *  @return 解析后的字典, 失败则返回nil
 *  @code
 *  NSDictionary *xmlDict = [YCXMLDictionary dictionaryFroXMLFile:<#fileName#>];
 */
+ (NSDictionary *)dictionaryFromXMLFile:(NSString *)fileName;

@end
