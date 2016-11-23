//
//  ViewController.swift
//  SOAPEngine Swift
//
//  Created by Danilo Priore on 23/11/16.
//  Copyright © 2016 Danilo Priore. All rights reserved.
//

import UIKit
import SOAPEngine64

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SOAPEngineDelegate {

    var soap = [SOAPEngine]()
    var verses:NSArray = [NSArray]() as NSArray
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let soap = SOAPEngine()
        soap.userAgent = "SOAPEngine"
        soap.actionNamespaceSlash = true
        soap.licenseKey = "eJJDzkPK9Xx+p5cOH7w0Q+AvPdgK1fzWWuUpMaYCq3r1mwf36Ocw6dn0+CLjRaOiSjfXaFQBWMi+TxCpxVF/FA=="
        
        soap.setValue("Genesis", forKey: "BookName")
        soap.setIntegerValue(1, forKey: "chapter")
        soap.requestURL("http://www.prioregroup.com/services/americanbible.asmx",
                        soapAction: "http://www.prioregroup.com/GetVerses",
                        completeWithDictionary: { (statusCode: Int?, dict: [AnyHashable: Any]?) -> Void in

                            var book:Dictionary = dict! as Dictionary
                            let verses:NSArray = book["BibleBookChapterVerse"] as! NSArray
                            self.verses = verses
                            self.table.reloadData()
                            
        }) { (error: Error?) -> Void in
            
            print(error!)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.verses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = self.table.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
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
}

