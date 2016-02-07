//
//  ViewController.swift
//  flicks
//
//  Created by Charles Yeh on 2/4/16.
//  Copyright © 2016 Charles Yeh. All rights reserved.
//

import AFNetworking
import MBProgressHUD
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var flickTableView: FlickTableView!
    var data: NSArray = []
    var type: String? = "now_playing"
    
    static let IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w342"
    static let IMAGE_BASE_URL_LD = "https://image.tmdb.org/t/p/w45"
    static let IMAGE_BASE_URL_DD = "https://image.tmdb.org/t/p/original"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        self.flickTableView.insertSubview(refreshControl, atIndex: 0)
        
        self.networkErrorView.hidden = true
        
        self.flickTableView.dataSource = self;
        self.flickTableView.delegate = self;
        loadFlickData()
    }
    
    func loadFlickData(refreshControl: UIRefreshControl? = nil) {
        let api_key = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "http://api.themoviedb.org/3/movie/\(self.type!)?api_key=\(api_key)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.flickTableView, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                MBProgressHUD.hideHUDForView(self.flickTableView, animated: true)
                
                if error != nil {
                    self.networkErrorView.hidden = false
                }
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            if let innerData = responseDictionary["results"] as! NSArray? {
                                self.data = innerData
                                self.flickTableView.reloadData()
                                
                                if let control = refreshControl {
                                    control.endRefreshing()
                                }
                            }
                    }
                }
        });
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadFlickData(refreshControl)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("com.teamslice.FlickCell", forIndexPath: indexPath) as! FlickTableViewCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        if let dataRow = self.data[indexPath.row] as? NSDictionary {
            NSLog("\(dataRow)")
            if let posterPath = dataRow["poster_path"] as? String {
                cell.flickIcon.setImageWithURL(
                    NSURL(string: "\(ViewController.IMAGE_BASE_URL)\(posterPath)")!)
            }
            if let title = dataRow["title"] as? String {
                cell.flickNameLabel.text = title
            }
            if let overview = dataRow["overview"] as? String {
                cell.flickDescLabel.text = overview
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! FlickDetailsViewController
        let indexPath = self.flickTableView.indexPathForCell(sender as! UITableViewCell)
        
        if let flickData = self.data[indexPath!.row] as? NSDictionary {
            vc.flickData = flickData
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

