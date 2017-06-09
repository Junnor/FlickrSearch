//
//  FlickrCell.swift
//  FlickrSearch
//
//  Created by Ju on 2017/6/6.
//  Copyright © 2017年 Ju. All rights reserved.
//

import UIKit

class FlickrCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let bgView = UIView(frame: self.frame)
        bgView.backgroundColor = UIColor.red
        self.selectedBackgroundView = bgView
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    var flickrPhoto: FlickrPhoto! {
        didSet {
            if flickrPhoto != nil {
                configureFlickCell()
            }
        }
    }
    
    
    private func configureFlickCell() {
        imageView.image = flickrPhoto.thumbnail

//        if let url = flickrPhoto.bigPhotoUrl {
//            DispatchQueue.global().async {
//                
//                let tmpUrl = url
//                let data = try? Data(contentsOf: tmpUrl)
//                if let data = data, let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        if url == tmpUrl {
//                            self.imageView.image = image
//                        }
//                    }
//                }
//            }
//        }
    }
    
//    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
//        super.apply(layoutAttributes)
//        if let attributes = layoutAttributes as? PinterestLayoutAttributes {
//            imageViewHeightLayoutConstraint.constant = attributes.photoHeight
//        }
//    }
}
