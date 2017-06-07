//
//  FlickrPhotoViewController.swift
//  FlickrSearch
//
//  Created by Ju on 2017/6/7.
//  Copyright © 2017年 Ju. All rights reserved.
//

import UIKit

class FlickrPhotoViewController: UIViewController {
    
    var flickrPhoto: FlickrPhoto! {
        didSet {
            configureImageView()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
    }
    
    @IBOutlet var imageswipeGestureDown: UISwipeGestureRecognizer!
    
    private func configureImageView() {
        if let image = flickrPhoto?.thumbnail {
            imageView?.image = image
        }
    }
    
}

extension FlickrPhotoViewController: ViewSwipeable {
    
    var direction: UISwipeGestureRecognizerDirection {
        return imageswipeGestureDown.direction
    }
}
