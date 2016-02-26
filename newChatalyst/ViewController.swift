//
//  ViewController.swift
//  newChatalyst
//
//  Created by Robin Malhotra on 21/02/16.
//  Copyright © 2016 Robin Malhotra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SafariServices
import SDWebImage
class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    let data = 1...5
    var userMessages :[String] = []
    var botMessages :[Message] = []
    let yes = UIButton()
    let no = UIButton()

    var sessionKey = 0
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .None
        self.navigationController?.navigationBarHidden = true
        
        Alamofire.request(.GET, "http://localhost:5000/register")
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        print("JSON: \(json)")
                        self.sessionKey = json["SessionKey"].intValue
                        let firstMessage = Message()
                        firstMessage.messageString = json["SummarySentence"].string!
                        firstMessage.link = NSURL(string: json["URL"].string!)!
                        firstMessage.moreAvailable = json["MoreSummaryAvailable"].bool!
                        firstMessage.imageLink = json["Image"].string
                        self.botMessages.append(firstMessage)
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.tableView.beginUpdates()
                            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.botMessages.count + self.userMessages.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                            self.tableView.endUpdates()
                            self.emojiTime()
                        }
                    }
                case .Failure(let error):
                    print(error)
                }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userMessages.count + botMessages.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier:String
        if(indexPath.row % 2 != 0){
            identifier = "rightCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! rightCell
            cell.messageLabel.text = userMessages[indexPath.row/2]
            cell.messageLabel.sizeToFit()
            cell.messageLabel.superview?.backgroundColor = UIColor(red: 47/255, green: 161/255, blue: 250/255, alpha: 1)
            cell.messageLabel.superview?.layer.cornerRadius = 12
            cell.messageLabel.numberOfLines = 0
            cell.messageLabel.textColor = UIColor.whiteColor()
            cell.messageLabel.textAlignment = .Right
            return cell
        }
        else
        {
            identifier = "leftCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! leftCell
            cell.messageLabel.superview?.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1)
            cell.messageLabel.superview?.layer.cornerRadius = 12
            cell.messageLabel.text = botMessages[indexPath.row/2].messageString
            if let imgURL = botMessages[indexPath.row/2].imageLink
            {
                cell.messageImage.sd_setImageWithURL(NSURL(string: imgURL), placeholderImage: UIImage(named: "loading"))
            }
            else
            {
                cell.messageImage.frame.size = CGSizeZero
                cell.layoutIfNeeded()
            }
            cell.messageLabel.numberOfLines = 0
            cell.messageLabel.sizeToFit()
            return cell
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func emojiTime()
    {
        yes.frame = CGRectMake(view.frame.width/2 - 120 , view.frame.height - 50 + 100 ,100,40)
        no.frame = CGRectMake(view.frame.width/2 + 20 , view.frame.height - 50 + 100 ,100,40)
        yes.backgroundColor = UIColor.darkGrayColor()
        no.backgroundColor = UIColor.darkGrayColor()
        yes.setTitle("😁", forState: .Normal)
        no.setTitle("😒", forState: .Normal)
        yes.layer.cornerRadius = 10
        no.layer.cornerRadius = 10
        yes.addTarget(self, action: "userResponded:", forControlEvents: .TouchUpInside)
        no.addTarget(self, action: "userResponded:", forControlEvents: .TouchUpInside)
        UIView.animateWithDuration(0.5, delay: 0.3, usingSpringWithDamping: 4, initialSpringVelocity: 10, options: [], animations: { () -> Void in
            self.no.frame = CGRectMake(self.view.frame.width/2 - 120 , self.view.frame.height - 50 ,100,40)
            if(self.botMessages.last!.moreAvailable)
            {
                self.yes.frame = CGRectMake(self.view.frame.width/2 + 20 , self.view.frame.height - 50  ,100,40)
            }

            }) { (complete) -> Void in
                
        }
        view.addSubview(yes)
        view.addSubview(no)
    }
    
    func userResponded(sender:AnyObject)
    {
        let button = sender as! UIButton
        UIView.animateWithDuration(0.5, delay: 0.3, usingSpringWithDamping: 4, initialSpringVelocity: 10, options: [], animations: { () -> Void in
            self.yes.frame = CGRectMake(self.view.frame.width/2 - 120 , self.view.frame.height - 50 + 100 ,100,40)
            self.no.frame = CGRectMake(self.view.frame.width/2 + 20 , self.view.frame.height - 50 + 100 ,100,40)
            }) { (complete) -> Void in
                
        }
        
        
        if button.titleLabel?.text == yes.titleLabel?.text
        {
            userMessages.append("Yes")
            getMeNewNews("positive")
        }
        else if button.titleLabel?.text == no.titleLabel?.text
        {
            userMessages.append("No")
            getMeNewNews("negative")
        }
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.botMessages.count + self.userMessages.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
        self.tableView.endUpdates()
    }
    
    func getMeNewNews(sentiment:String)
    {
        let url = "http://localhost:5000/report/\(self.sessionKey)/\(sentiment)"
        Alamofire.request(.GET, url).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print("JSON: \(json)")
                    let message = Message()
                    message.messageString = json["SummarySentence"].string!
                    message.link = NSURL(string: json["URL"].string!)!
                    message.moreAvailable = json["MoreSummaryAvailable"].bool!
                    self.botMessages.append(message)
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        self.tableView.beginUpdates()
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.botMessages.count + self.userMessages.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                        self.tableView.endUpdates()
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: (self.userMessages.count + self.botMessages.count - 1), inSection: 0), atScrollPosition: .Bottom, animated: true)
                        self.emojiTime()
                    }

                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row%2==0)
        {
            let svc = SFSafariViewController(URL: botMessages[indexPath.row/2].link)
            self.presentViewController(svc, animated: true, completion: { () -> Void in
                
            })
        }
    }
}

