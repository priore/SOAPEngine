<p align="center">
  <img src="screen/soapengine.png" alt="SOAPEngine" width="50%">
</p><br/>

[![Version](https://img.shields.io/cocoapods/v/SOAPEngine.svg?style=flat)](http://cocoapods.org/pods/SOAPEngine)
[![Language](https://img.shields.io/badge/languages-Swift%20%7C%20ObjC-red.svg)]()
[![Platform](https://img.shields.io/badge/platforms-iOS%20%7C%20tvOS%20%7C%20macOS-red.svg)](http://cocoapods.org/pods/SOAPEngine)
[![License](https://img.shields.io/cocoapods/l/SOAPEngine.svg?style=flat)](http://cocoapods.org/pods/SOAPEngine)
[![codebeat badge](https://codebeat.co/badges/106e60ae-9f4c-4970-a505-770beb429605)](https://codebeat.co/projects/github-com-priore-soapengine-master)
[![Twitter: @DaniloPriore](https://img.shields.io/badge/contact-@DaniloPriore-blue.svg?style=flat)](https://twitter.com/DaniloPriore)

This generic [SOAP](http://www.wikipedia.org/wiki/SOAP) client allows you to access web services using a your [iOS](http://www.wikipedia.org/wiki/IOS) app, [Mac OS X](http://www.wikipedia.org/wiki/OS_X) app and [Apple TV](http://www.apple.com/tv/) app.

With this Framework you can create [iPhone](http://www.wikipedia.org/wiki/IPhone), [iPad](http://www.wikipedia.org/wiki/IPad), [Mac OS X](http://www.wikipedia.org/wiki/OS_X) and [Apple TV](http://www.apple.com/tv/) apps that supports [SOAP](http://www.wikipedia.org/wiki/SOAP) Client Protocol. This framework able executes methods at remote web services with [SOAP](http://www.wikipedia.org/wiki/SOAP) standard protocol.

## Features
---
* Support both 2001 (v1.1) and 2003 (v1.2) [XML](http://www.wikipedia.org/wiki/XML) schema.
* Support array, array of structs, dictionary and sets.
* Support for user-defined object with serialization of complex data types and array of complex data types, even embedded multilevel structures.
* Supports [ASMX](http://www.wikipedia.org/wiki/ASP.NET#Other_files) Services, [WCF](http://www.wikipedia.org/wiki/Windows_Communication_Foundation) Services ([SVC](http://www.wikipedia.org/wiki/ASP.NET#Other_files)) and now also the [WSDL](http://www.wikipedia.org/wiki/Web_Services_Description_Language) definitions.
* Supports [Basic](http://www.wikipedia.org/wiki/Basic_access_authentication), [Digest](http://www.wikipedia.org/wiki/Digest_access_authentication) and [NTLM](http://www.wikipedia.org/wiki/Integrated_Windows_Authentication) Authentication, [WS-Security](http://www.wikipedia.org/wiki/WS-Security), Client side Certificate and custom security header.
* Supports [iOS](http://www.wikipedia.org/wiki/IOS) Social Account to send [OAuth2.0](http://www.wikipedia.org/wiki/OAuth) token on the request.
* [AES256](http://www.wikipedia.org/wiki/Advanced_Encryption_Standard) or [3DES](http://www.wikipedia.org/wiki/Triple_DES) Encrypt/Decrypt data without [SSL](http://www.wikipedia.org/w/index.php?title=Transport_Layer_Security) security.
* An example of service and how to use it is included in source code.

## Requirements for [iOS](http://www.wikipedia.org/wiki/IOS)
---
* [iOS](http://www.wikipedia.org/wiki/IOS) 8.0 and later
* [Xcode](http://www.wikipedia.org/wiki/Xcode) 8.0 or later
* Security.framework
* Accounts.framework
* Foundation.framework
* UIKit.framework
* libxml2.dylib

## Requirements for [Mac OS X](http://www.wikipedia.org/wiki/OS_X)
---
* [OS X](http://www.wikipedia.org/wiki/OS_X) 10.9 and later
* [Xcode](http://www.wikipedia.org/wiki/Xcode) 8.0 or later
* Security.framework
* Accounts.framework
* Foundation.framework
* AppKit.framework
* Cocoa.framework
* libxml2.dylib

## Requirements for [Apple TV](http://www.apple.com/tv/)
---
* [iOS](http://www.wikipedia.org/wiki/IOS) 9.0 and later
* [Xcode](http://www.wikipedia.org/wiki/Xcode) 8.0 or later
* Security.framework
* Foundation.framework
* UIKit.framework
* libxml2.dylib

## Limitations
---
* for [WCF](http://www.wikipedia.org/wiki/Windows_Communication_Foundation) services, only supports basic http bindings ([basicHttpBinding](https://msdn.microsoft.com/library/ms731361.aspx)).
* in [Mac OS X](http://www.wikipedia.org/wiki/OS_X) unsupported image objects, instead you can use the [NSData](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSData_Class/index.html).

## Known issues
---
- **Swift 4**: the library is currently written in Objective-C and when you import the swift library you will get build errors like this `The use of Swift 3 @objc inference in Swift 4 mode is deprecated`.

	For silent this warning is need sets `Swift 3 @objc Inference` to default value in the the Build settings of target. __but It's not all__; the classes used to create requests must be declared with `@objcMembers` and `NSObject`, eg:

	``` swift
	class MyClass { ... }

    let param = MyClass()
    // ...
    // ...
    let soap = SOAPEngine()
    soap.setValue(param, forKey: "myKey")
    // ...
    // ...
	```

	the declaration of MyClass must become :

	``` swift
	@objcMembers class MyClass: NSObject { ... }
	```

## Security for Xcode 8.x or later
---
From the new Xcode 8 is required an additional setting for the apps, if this setting does not exist you will see a log message like this:

`App Transport Security has blocked a cleartext HTTP (http://) resource load since it is insecure. Temporary exceptions can be configured via your app's Info.plist file.`

To resolve this, add few keys in info.plist, the steps are:

1. Open `info.plist` file of your project.
2. Add a Key called `NSAppTransportSecurity` as a Dictionary.
3. Add a Subkey called `NSAllowsArbitraryLoads` as Boolean and set its value to YES as like following image.

![NSAppTransportSecurity](https://github.com/priore/SOAPEngine/raw/master/screen/NSAppTransportSecurity.png)

ref link: http://stackoverflow.com/a/32631185/4069848

## How to use
---
with [**Delegates**](https://developer.apple.com/library/ios/documentation/General/Conceptual/CocoaEncyclopedia/DelegatesandDataSources/DelegatesandDataSources.html) :

``` swift
import SOAPEngine64

class ViewController: UIViewController, SOAPEngineDelegate {

	var soap: SOAPEngine = SOAPENgine()

	override func viewDidLoad() {
		soap.delegate = self
		soap.actionNamespaceSlash = true
		soap.setValue("Genesis", forKey: "BookName")
		soap.setIntegerValue(1, forKey: "chapter")

		// standard soap service (.asmx)
		soap.requestURL("http://www.prioregroup.com/services/americanbible.asmx",
	    		soapAction: "http://www.prioregroup.com/GetVerses")

		func soapEngine(_ soapEngine: SOAPEngine!, 
		   didFinishLoadingWith dict: [AnyHashable : Any]!, 
					data: Data!) 
		{
			let dict = soapEngine.dictionaryValue()
			print(dict)
		}
	}
}
```

with [**Block programming**](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html) :

``` swift
import SOAPEngine64

class ViewController: UIViewController {

	var soap: SOAPEngine = SOAPENgine()

	override func viewDidLoad() {
		super.viewDidLoad()
		soap.actionNamespaceSlash = true
		soap.setValue("Genesis", forKey: "BookName")
        	soap.setIntegerValue(1, forKey: "chapter")
        
        	soap.requestURL("http://www.prioregroup.com/services/americanbible.asmx",
	    		    soapAction: "http://www.prioregroup.com/GetVerses",
		completeWithDictionary: { (statusCode: Int?, dict: [AnyHashable: Any]?) -> Void in
                            
			let book:NSDictionary = dict! as NSDictionary
			let verses = book["BibleBookChapterVerse"] as! NSArray
			print(verses)

		}) { (error: Error?) -> Void in
			print(error!)
		}
	}
}
```	

with [**Notifications**](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSNotificationCenter_Class/index.html) :

``` swift
import SOAPEngine64

class ViewController: UIViewController {

	var soap: SOAPEngine = SOAPENgine()

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, 
			selector: #selector(soapEngineDidFinishLoading(_:)), 
			name: NSNotification.Name.SOAPEngineDidFinishLoading, 
			object: nil)

		soap.actionNamespaceSlash = true
		soap.setValue("Genesis", forKey: "BookName")
		soap.setIntegerValue(1, forKey: "chapter")

		// standard soap service (.asmx)
		soap.requestURL("http://www.prioregroup.com/services/americanbible.asmx",
	    	soapAction: "http://www.prioregroup.com/GetVerses")
	}

	@objc func soapEngineDidFinishLoading(_ notification: NSNotification) {
		let engine = notification.object as? SOAPEngine
		let dict = engine()
		print(dict)
	}
}
```

[**Synchronous**]() request :

``` swift
import SOAPEngine64

class ViewController: UIViewController {

	var soap: SOAPEngine = SOAPENgine()

	override func viewDidLoad() {
		super.viewDidLoad()
		soap.actionNamespaceSlash = true
		soap.setValue("Genesis", forKey: "BookName")
		soap.setIntegerValue(1, forKey: "chapter")

		// standard soap service (.asmx)
		do {
			let result = try soap.syncRequestURL("http://www.prioregroup.com/services/americanbible.asmx", 
						 soapAction: "http://www.prioregroup.com/GetVerses")
			print(result)
		}
		catch {
			print(error)
		}	
	}
}
```
	
settings for [**SOAP Authentication**](http://www.whitemesa.com/soapauth.html) :

``` swift
soap.authorizationMethod = .AUTH_BASICAUTH; // basic auth
soap.username = "my-username";
soap.password = "my-password";
```	

settings for Social [**OAuth2.0**](http://www.wikipedia.org/wiki/OAuth) token :

``` swift
// token authorization
soap.authorizationMethod = .AUTH_SOCIAL;
soap.apiKey = "1234567890"; // your apikey https://dev.twitter.com/
soap.socialName = ACAccountTypeIdentifierTwitter; // import Accounts
```	

[**Encryption/Decryption**](https://it.wikipedia.org/wiki/Advanced_Encryption_Standard) data without SSL/HTTPS :

``` swift
soap.encryptionType = ._ENCRYPT_AES256; // or SOAP_ENCRYPT_3DES
soap.encryptionPassword = "my-password";
```	

Params with [**Attributes**](http://www.w3schools.com/xml/xml_attributes.asp) :

``` swift
// book
var book = ["name": "Genesis"] as! NSMutableDictionary
var attr = ["order": "asc"]
// chapter
var child = soap.dictionary(forKey: "chapter", value: "1", attributes: attr)
book.addEntries(from: child!)
// book attributes
soap.setValue(book, forKey: "Book", attributes: ["rack": "2"])
```
it builds a request like this:
``` xml
<Book rack="2">
	<name>Genesis</name>
	<chapter order="asc">1</chapter>
</Book>
```

## Optimizations
---
First of all, if you note a slowdown in the response of the request, try to change the value of the property named `actionNamespaceSlash`.
After, when using the method named `requestWSDL` three steps are performed : 

1. retrieve the WSDL with an http request
2. processing to identify the soapAction
3. calls the method with an http request [http request](https://www.scaler.com/topics/hypertext-transfer-protocol/#what-is-in-an-http-request-)

this is not optimized, very slow, instead you can use the optimization below : 

1. retrieving manually the SOAPAction directly from WSDL (once with your favorite browser).
2. use the method named requestURL instead of requestWSDL without WSDL extension.

## Install in your apps
---
### Swift Package Manager

SOAPEngine is available as a Swift package. The repository [URL](https://github.com/priore/SOAPEngine.git) is valid for adding the package in your app through the Xcode.

### Cocoapods

Read the ["Getting Started" guide](https://github.com/priore/SOAPEngine/wiki/Cocoapods-Installation-guide)

### Cocoapods and Swift

Read the [Integrating SOAPEngine with a Swift project](https://github.com/priore/SOAPEngine/wiki/Integrating-SOAPEngine-with-a-Swift-project)

### Standard installation

Read the ["Standard Installation" guide](https://github.com/priore/SOAPEngine/wiki/Standard-Installation)

## Licenses

Trial<br><small>just simulator</small> | Single App<br><small>single bundle-id</small> | Enterprise<br><small><u>multi</u> bundle-id</small>
------------- | ------------- | -------------
[**DOWNLOAD**](https://github.com/priore/SOAPEngine/archive/master.zip)  | [**BUY 12,99€**](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=G3RXTN3YD7VRG) | [**BUY 77,47€**](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6YH9LJRNXPTHE)



