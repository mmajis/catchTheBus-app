//
//  ViewController.swift
//  CatchTheBus
//
//  Created by Mika Majakorpi on 29/05/16.
//  Copyright © 2016 Mika Majakorpi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var mainLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    var isPausedCatchCheck = true
    var catchCheckTimer: NSTimer!
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        self.catchCheck()
        let configuration = NSURLSessionConfiguration .defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        
        
        let urlString = NSString(format: "http://10.112.52.116:8080/")
        
        print("get connection url string is \(urlString)")
        //let url = NSURL(string: urlString as String)
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: NSString(format: "%@", urlString) as String)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 30
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTaskWithRequest(request) {
            (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
            
            // 1: Check HTTP Response for successful GET request
            guard let httpResponse = response as? NSHTTPURLResponse, receivedData = data
                else {
                    print("error: not a valid http response")
                    return
            }
            
            switch (httpResponse.statusCode)
            {
            case 200:
                
                let response = NSString (data: receivedData, encoding: NSUTF8StringEncoding)
                print("Response is \(response)")
                
                
                do {
                    let getResponse = try NSJSONSerialization.JSONObjectWithData(receivedData, options: .AllowFragments)
                    
                    //print("arrival is \(getResponse["connectionArrival"] as? Int)")
                    dispatch_async(dispatch_get_main_queue()) {
                        if let
                            arrival = getResponse["connectionArrival"] as? Int,
                            walkTime = getResponse["walkTime"] as? Int,
                            leadTime = getResponse["leadTime"] as? Int,
                            busNumber = getResponse["busNumber"] as? String,
                            scheduledArrival = getResponse["scheduledArrival"] as? Int
                        {
                            let arrivalDate = self.secondsAfterMidnightAsNSDate(arrival)
                            let formatter = NSDateFormatter()
                            formatter.dateFormat = "HH:mm"
                            formatter.timeZone = NSTimeZone.localTimeZone()
                            let arrivalTime = formatter.stringFromDate(arrivalDate)
                            let leave = arrival - walkTime - leadTime
                            let leaveDate = self.secondsAfterMidnightAsNSDate(leave)
                            let leaveTime = formatter.stringFromDate(leaveDate)
                            let onTimeStr = self.getOnTimeString(arrival, scheduledArrival: scheduledArrival)
                            
                            let alert = UIAlertController(
                                title: "Hello!",
                                message: "Your usual bus \(busNumber) is \(onTimeStr), arriving at \(arrivalTime). Leave at \(leaveTime) to catch it!",
                                preferredStyle: UIAlertControllerStyle.Alert)
                            
                            let okAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default) {
                                (UIAlertAction) -> Void in
                            }
                            alert.addAction(okAction)
                            
                            let changeAction = UIAlertAction(title: "Change", style: UIAlertActionStyle.Default) {
                                (UIAlertAction) -> Void in
                                exit(0)
                            }
                            alert.addAction(changeAction)
                            
                            self.presentViewController(alert, animated: true)
                            {
                                () -> Void in
                            }
                        } else {
                            
                        }
                    }
                    
                } catch {
                    print("Error serializing JSON: \(error)")
                }
                
                break
            case 400:
                
                break
            default:
                print("catchCheck GET request got response \(httpResponse.statusCode)")
            }
        }
        dataTask.resume()

    }
    
    override func viewWillAppear(animated: Bool) {
        pauseResumeCatchCheck(self)
    }
    
    func getOnTimeString(arrival: Int, scheduledArrival: Int) -> String {
        if (arrival == scheduledArrival) {
            return "on time"
        } else if (arrival > scheduledArrival) {
            return "late"
        } else {
            return "early"
        }
    }
    
    func secondsAfterMidnightAsNSDate(seconds: Int) -> NSDate {
        let date = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let newDate = cal.startOfDayForDate(date)
        return newDate.dateByAddingTimeInterval(NSTimeInterval(seconds))
    }
    
    func nowAsSecondsAfterMidnight() -> Int {
        let now = NSDate()
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let midnight = cal.startOfDayForDate(now)
        return Int(round(-midnight.timeIntervalSinceNow))
    }

    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    @IBAction func pauseResumeCatchCheck(sender: AnyObject) {
        if isPausedCatchCheck {
            catchCheckTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController.catchCheck), userInfo: nil, repeats: true)
            isPausedCatchCheck = false
        } else {
            catchCheckTimer.invalidate()
            isPausedCatchCheck = true
        }
    }
    
    func catchCheck() {
        let configuration = NSURLSessionConfiguration .defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        
        
        let urlString = NSString(format: "http://10.112.52.116:8080/")
        
        print("get connection url string is \(urlString)")
        //let url = NSURL(string: urlString as String)
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: NSString(format: "%@", urlString) as String)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 30
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTaskWithRequest(request) {
            (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
            
            // 1: Check HTTP Response for successful GET request
            guard let httpResponse = response as? NSHTTPURLResponse, receivedData = data
                else {
                    print("error: not a valid http response")
                    return
            }
            
            switch (httpResponse.statusCode)
            {
            case 200:
                
                let response = NSString (data: receivedData, encoding: NSUTF8StringEncoding)
                print("Response is \(response)")
                
                
                do {
                    let getResponse = try NSJSONSerialization.JSONObjectWithData(receivedData, options: .AllowFragments)
                    
                    //print("arrival is \(getResponse["connectionArrival"] as? Int)")
                    dispatch_async(dispatch_get_main_queue()) {
                        if let
                            arrival = getResponse["connectionArrival"] as? Int,
                            walkTime = getResponse["walkTime"] as? Int,
                            leadTime = getResponse["leadTime"] as? Int,
                            busNumber = getResponse["busNumber"] as? String,
                            scheduledArrival = getResponse["scheduledArrival"] as? Int
                        {
                            let arrivalDate = self.secondsAfterMidnightAsNSDate(arrival)
                            let formatter = NSDateFormatter()
                            formatter.dateFormat = "HH:mm"
                            formatter.timeZone = NSTimeZone.localTimeZone()
                            let arrivalTime = formatter.stringFromDate(arrivalDate)
                            let leave = arrival - walkTime - leadTime
                            let leaveDate = self.secondsAfterMidnightAsNSDate(leave)
                            let leaveTime = formatter.stringFromDate(leaveDate)
                            let onTimeStr = self.getOnTimeString(arrival, scheduledArrival: scheduledArrival)
                            let secondsLeft = Int(round(arrivalDate.timeIntervalSinceNow))
                            let leftDate = self.secondsAfterMidnightAsNSDate(secondsLeft)
                            let msFormatter = NSDateFormatter()
                            msFormatter.dateFormat = "mm:ss"
                            let leftString = msFormatter.stringFromDate(leftDate)
                            self.mainLabel.center = self.view.center
                            self.mainLabel.text = "Time left:\n\(leftString)"
                            self.mainLabel.font = self.mainLabel.font.fontWithSize(30)
                            self.mainLabel.sizeToFit()
                            
                        } else {
                            
                        }
                    }
                    
                } catch {
                    print("Error serializing JSON: \(error)")
                }
                
                break
            case 400:
                
                break
            default:
                print("catchCheck GET request got response \(httpResponse.statusCode)")
            }
        }
        dataTask.resume()
        
    }
}

