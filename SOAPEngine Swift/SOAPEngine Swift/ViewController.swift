//
//  ViewController.swift
//  SOAPEngine Swift
//
//  Created by Danilo Priore on 03/02/15.
//  Copyright (c) 2015 Danilo Priore. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var soap = [SOAPEngine]()
    var verses:NSArray = [NSArray]()
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var soap = SOAPEngine()
        soap.userAgent = "SOAPEngine"
        soap.actionNamespaceSlash = true
        soap.licenseKey = "eJJDzkPK9Xx+p5cOH7w0Q+AvPdgK1fzWWuUpMaYCq3r1mwf36Ocw6dn0+CLjRaOiSjfXaFQBWMi+TxCpxVF/FA=="
        //soap.responseHeader = true // use only for non standard MS-SOAP service
        
        soap.setValue("Genesis", forKey: "BookName")
        soap.setIntegerValue(1, forKey: "chapter")
        soap.requestURL("http://www.prioregroup.com/services/americanbible.asmx",
            soapAction: "http://www.prioregroup.com/GetVerses",
            completeWithDictionary: { (statusCode : Int, dict : [NSObject : AnyObject]!) -> Void in
                
                var book:Dictionary = dict as Dictionary
                var verses:NSArray = book["BibleBookChapterVerse"] as! NSArray
                self.verses = verses
                self.table.reloadData()
                
            }) { (error : NSError!) -> Void in
                
                NSLog("%@", error)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.verses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = self.table?.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        var chapter_verse:NSDictionary = self.verses[indexPath.row] as! NSDictionary

        var chapter:String = chapter_verse["Chapter"] as! String
        var verse:String = chapter_verse["Verse"] as! String
        var text:String = chapter_verse["Text"] as! String
        
        cell!.textLabel?.text = String(format: "Chapter %@ Verse %@", chapter, verse)
        cell!.detailTextLabel?.text = text
        return cell!
    }
    
}

