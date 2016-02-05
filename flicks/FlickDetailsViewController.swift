//
//  FlickDetailsViewController.swift
//  flicks
//
//  Created by Charles Yeh on 2/5/16.
//  Copyright © 2016 Charles Yeh. All rights reserved.
//

import UIKit

class FlickDetailsViewController: UIViewController {
    
    @IBOutlet weak var flickDetailsScroll: UIScrollView!
    @IBOutlet weak var flickDetailsView: UIView!
    
    @IBOutlet weak var flickBackdrop: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var flickData: NSDictionary?
    
    override func viewDidLoad() {
        // set scroll
        let contentWidth = flickDetailsScroll.bounds.width
        let contentHeight = flickDetailsScroll.bounds.height * 2
        flickDetailsScroll.contentSize = CGSizeMake(contentWidth, contentHeight)
        
        if let title = self.flickData!["title"] as? String {
            titleLabel.text = title
        }
        if let releaseDate = self.flickData!["release_date"] as? String {
            dateLabel.text = releaseDate
        }
        if let voteAverage = self.flickData!["vote_average"] as? String {
            ratingLabel.text = voteAverage
        }
        if let voteCount = self.flickData!["vote_count"] as? String {
            lengthLabel.text = voteCount
        }
        if let backdropPath = self.flickData!["backdrop_path"] as? String {
            flickBackdrop.setImageWithURL(NSURL(string: "\(ViewController.IMAGE_BASE_URL)\(backdropPath)")!)
        }
        if let overview = self.flickData!["overview"] as? String {
            overviewLabel.text = overview
            overviewLabel.sizeToFit()
        }
    }
}
