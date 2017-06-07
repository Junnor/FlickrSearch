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
        let url = flickrPhoto.photoUrl
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url)
            if let data = data {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                }
            }
        }
    }
    
}
