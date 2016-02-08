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

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var viewOption: UISegmentedControl!
    
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var flickTableView: FlickTableView!
    @IBOutlet weak var gridView: UICollectionView!
    
    @IBOutlet weak var listSearch: UISearchBar!
    
    var data: NSArray = []
    var filteredData: NSArray = []
    var searchText: String? = ""
    
    var endpoint: String? = "now_playing"
    
    static let IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w342"
    static let IMAGE_BASE_URL_LD = "https://image.tmdb.org/t/p/w45"
    static let IMAGE_BASE_URL_DD = "https://image.tmdb.org/t/p/original"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        self.flickTableView.insertSubview(refreshControl, atIndex: 0)
        
        self.networkErrorView.hidden = true
        
        self.flickTableView.dataSource = self
        self.flickTableView.delegate = self
        
        self.gridView.dataSource = self
        self.gridView.delegate = self
        self.gridView.hidden = true
        
        listSearch.delegate = self;
        viewOption.addTarget(self, action: "changeView:",
            forControlEvents: UIControlEvents.ValueChanged)
        
        loadFlickData()
        
        let tapper = UITapGestureRecognizer(target: self, action:Selector("dismissKeyboardOnTap"))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper);
    }
    
    func dismissKeyboardOnTap() {
        dispatch_async(dispatch_get_main_queue(),{
            self.listSearch.endEditing(true)
        })
    }
    
    func changeView(segmentedControl: UISegmentedControl) {
        self.listSearch.endEditing(true)
        if segmentedControl.selectedSegmentIndex == 0 {
            // list
            self.flickTableView.hidden = false
            self.gridView.hidden = true
        } else {
            // grid
            self.flickTableView.hidden = true
            self.gridView.hidden = false
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        refreshListing()
    }
    
    func loadFlickData(refreshControl: UIRefreshControl? = nil) {
        let api_key = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "http://api.themoviedb.org/3/movie/\(self.endpoint!)?api_key=\(api_key)")
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
                                self.refreshListing()
                                
                                if let control = refreshControl {
                                    control.endRefreshing()
                                }
                            }
                    }
                }
        });
        task.resume()
    }
    
    func refreshListing() {
        if self.searchText != "" {
            filteredData = data.filter({ (row) in
                if let title = row["title"] as? String {
                    return title.uppercaseString.containsString(self.searchText!.uppercaseString)
                } else {
                    return false
                }
            })
        } else {
            filteredData = data
        }
        
        self.flickTableView.reloadData()
        self.gridView.reloadData()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadFlickData(refreshControl)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("com.teamslice.FlickCell", forIndexPath: indexPath) as! FlickTableViewCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        if let dataRow = self.filteredData[indexPath.row] as? NSDictionary {
            if let posterPath = dataRow["poster_path"] as? String {
                cell.flickIcon.setImageWithURLRequest(
                    NSURLRequest(URL: NSURL(
                        string: "\(ViewController.IMAGE_BASE_URL_LD)\(posterPath)")!),
                    placeholderImage: nil,
                    success: { (request, response, image) -> Void in
                        if response != nil {
                            cell.flickIcon.alpha = 0.0
                            cell.flickIcon.image = image
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                cell.flickIcon.alpha = 1.0
                            })
                        } else {
                            cell.flickIcon.image = image
                        }
                    }, failure: nil)
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
        return self.filteredData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = gridView.dequeueReusableCellWithReuseIdentifier(
            "com.teamslice.FlickGridCell", forIndexPath: indexPath) as! CollectionViewCell
        
        if let dataRow = self.filteredData[indexPath.row] as? NSDictionary {
            if let posterPath = dataRow["poster_path"] as? String {
                cell.movieIcon.setImageWithURL(
                    NSURL(string: "\(ViewController.IMAGE_BASE_URL_LD)\(posterPath)")!)
            }
            if let title = dataRow["title"] as? String {
                cell.movieName.text = title
            }
            if let overview = dataRow["overview"] as? String {
                cell.movieDesc.text = overview
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredData.count
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! FlickDetailsViewController
        var indexPath: NSIndexPath?
        if viewOption.selectedSegmentIndex == 0 {
            indexPath = self.flickTableView.indexPathForCell(sender as! UITableViewCell)
        } else {
            indexPath = self.gridView.indexPathForCell(sender as! UICollectionViewCell)
        }
        
        if let flickData = self.filteredData[indexPath!.row] as? NSDictionary {
            vc.flickData = flickData
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

