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
        
        // load big image
        if let bigImgUrl = URL(string: "https://farm\(flickrPhoto.farm).staticflickr.com/\(flickrPhoto.server)/\(flickrPhoto.photoId)_\(flickrPhoto.secret)_b.jpg") {
            DispatchQueue.global().async {
                let url = bigImgUrl
                if let data = try? Data(contentsOf: url) {
                    let img = UIImage(data: data)
                    if url == bigImgUrl {
                        DispatchQueue.main.async {
                            self.imageView.image = img
                        }
                    }
                }
            }
        }
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
