//
//  ViewController.swift
//  SOAPEngine Swift
//
//  Created by Danilo Priore on 29/01/17.
//  Copyright © 2017 Danilo Priore. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SOAPEngineDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    
    var verses:NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let soap = SOAPEngine()
        soap.delegate = self // if you need you can combine closures with delegates
        
        soap.licenseKey = "eJJDzkPK9Xx+p5cOH7w0Q+AvPdgK1fzWWuUpMaYCq3r1mwf36Ocw6dn0+CLjRaOiSjfXaFQBWMi+TxCpxVF/FA=="
        soap.actionNamespaceSlash = true
        soap.setValue("Genesis", forKey: "BookName")
        soap.setIntegerValue(1, forKey: "chapter")
        
        soap.requestURL("http://www.prioregroup.com/services/americanbible.asmx",
                        soapAction: "http://www.prioregroup.com/GetVerses",
                        completeWithDictionary: { (statusCode: Int?, dict: [AnyHashable: Any]?) -> Void in
                            
                            let book:NSDictionary = dict! as NSDictionary
                            self.verses = book["BibleBookChapterVerse"] as! NSArray
                            self.tableView?.reloadData()
                            
        }) { (error: Error?) -> Void in
            
            print(error!)
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.verses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        }
        
        let chapter_verse:NSDictionary = self.verses[indexPath.row] as! NSDictionary
        
        let chapter:String = chapter_verse["Chapter"] as! String
        let verse:String = chapter_verse["Verse"] as! String
        let text:String = chapter_verse["Text"] as! String
        
        cell!.textLabel?.text = String(format: "Chapter %@ Verse %@", chapter, verse)
        cell!.detailTextLabel?.text = text
        
        return cell!
    }
    
    // MARK: - SOAPEngineDelegate

    func soapEngine(_ soapEngine: SOAPEngine!, didBeforeSending request: NSMutableURLRequest!) -> NSMutableURLRequest! {
        
        // TODO: use this delegate to customize the request header.
        debugPrint(request.allHTTPHeaderFields as Any)
        
        return request
    }
    
    func soapEngine(_ soapEngine: SOAPEngine!, didBeforeParsingResponseData data: Data!) -> Data! {
        
        // TODO: use this delegate to use your favorite parser, in this case the delegate must return nil.
        // let dict = YCXMLDictionary.dictionary(fromXMLData: data) // <-- to increase performance
        // debugPrint(dict as Any)
        // return nil
        
        return data
    }
}

