//
//  PinterestLayout.swift
//  Pinterest
//
//  Created by nyato喵特 on 2017/6/9.
//  Copyright © 2017年 Razeware LLC. All rights reserved.
//

import UIKit


protocol PinterestLayoutDelegate: class {
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAt indexPath: IndexPath, width: CGFloat) -> CGFloat
    
    func collectionView(_ collectionView: UICollectionView, heightForAnnotationAt indexPath: IndexPath, width: CGFloat) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
    
    weak var delegate: PinterestLayoutDelegate!
    
    var numberOfColumns = 3
    var cellPadding: CGFloat = 6.0
    
    private var cache = [PinterestLayoutAttributes]()
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }

    override func prepare() {
        print("prepare   #######################################")
        
        cache.removeAll()
        contentHeight = 0.0
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var colume = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)

        for section in 0..<collectionView!.numberOfSections {
            for item in 0..<collectionView!.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                
                let width = columnWidth - 2 * cellPadding
                let photoHeight = delegate.collectionView(collectionView!,
                                                          heightForPhotoAt: indexPath,
                                                          width: width)
                let annotationHeight = delegate.collectionView(collectionView!,
                                                               heightForAnnotationAt: indexPath,
                                                               width: width)
                let height = cellPadding + photoHeight + annotationHeight + cellPadding
                let frame = CGRect(x: xOffset[colume], y: yOffset[colume], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
                let attributs = PinterestLayoutAttributes(forCellWith: indexPath)
                attributs.photoHeight = photoHeight
                attributs.frame = insetFrame
                cache.append(attributs)
                
                contentHeight = max(contentHeight, frame.maxY)
                
                yOffset[colume] = yOffset[colume] + height
                
                
                if cache.count >= numberOfColumns {
                    var minColumnYOffset = yOffset[0]
                    var willAddToCoulum = 0
                    for c in 1..<numberOfColumns {
                        minColumnYOffset = min(minColumnYOffset, yOffset[c])
                        let index = yOffset.index(of: minColumnYOffset)!
                        willAddToCoulum = index
                    }
                    
                    colume = willAddToCoulum
                } else {
                    colume = colume >= (numberOfColumns - 1) ? 0 : (colume + 1)
                }
                
            }
        }
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes()
        if elementKind == UICollectionElementKindSectionHeader {
            let rect = CGRect(x: 0, y: 0, width: collectionView!.bounds.width, height: 50)
            attributes.frame = rect
        }
        return attributes
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            attributes.frame.intersects(rect)
            layoutAttributes.append(attributes)
        }
        return layoutAttributes
    }
    
    override class var layoutAttributesClass: AnyClass {
        return PinterestLayoutAttributes.self
    }
    
}


// Optional......
class PinterestLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var photoHeight: CGFloat = 0.0
    
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! PinterestLayoutAttributes
        copy.photoHeight = photoHeight
        return copy
    }
    
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? PinterestLayoutAttributes {
            if attributes.photoHeight == photoHeight {
                return super.isEqual(object)
            }
        }
        return false
    }
    
    
}
