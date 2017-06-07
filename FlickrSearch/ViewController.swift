//
//  ViewController.swift
//  FlickrSearch
//
//  Created by Ju on 2017/6/6.
//  Copyright © 2017年 Ju. All rights reserved.
//

// b2f908edd7b9350c788d8ff7e8bbc263

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    private let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    fileprivate var searchResults = [String: [FlickrPhoto]]()
    fileprivate var searchTags = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.stopAnimating()
        view.addSubview(indicator)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Flickr Photo" {
            let indexPath = collectionView.indexPathsForSelectedItems![0]
            let tag = searchTags[indexPath.section]
            let dsvc = segue.destination as! FlickrPhotoViewController
            dsvc.flickrPhoto = searchResults[tag]![indexPath.row]
        }
    }
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
    }

    @IBAction func share(_ sender: Any) {
    }
    
    
    // MARK: - Search bar delegte
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {

            indicator.startAnimating()
            FlickrProvider.fetchPhotosForSearchText(searchText: searchBar.text!, onCompletion: { [weak self] (error, photos) in
                self?.indicator.stopAnimating()
                if photos != nil && photos?.count != 0 {
                    if !(self?.searchTags.contains(searchBar.text!))! {
                        print("Found \(photos!.count) photos match \(searchBar.text!)")
                        self?.searchTags.append(searchBar.text!)
                        self?.searchResults[searchBar.text!] = photos!
                    }
                    
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                } else {
                    print("Flickr error: \(String(describing: error?.localizedDescription))")
                }
            })
        }
        
        searchBar.resignFirstResponder()
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searchResults.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = searchTags[section]
        return searchResults[key]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrCell", for: indexPath)
        if let cell = cell as? FlickrCell {
        
            let searchStr = searchTags[indexPath.section]
            let flickrPhoto = searchResults[searchStr]![indexPath.row]
            cell.flickrPhoto = flickrPhoto
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            // TODO: xxx
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FlickrHeader", for: indexPath)
            if let header = header as? FlickrPhotoHeaderView {
                let searchStr = searchTags[indexPath.section]
                header.searchLabel.text = searchStr
            }
            
            return header
        }
        return UICollectionReusableView()
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Flickr Photo", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // TODO: xxx
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if searchResults.count != 0 {
            let tag = searchTags[indexPath.section]
            let photo = searchResults[tag]![indexPath.row]
            return photo.thumbnail.size
        }
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
    }
}


// MARK: - ViewHeadabel protocol

extension ViewController: ViewHeadabel {
    
    var animatedViewFrame: CGRect {
        let attribute = collectionView.layoutAttributesForItem(at: collectionView.indexPathsForSelectedItems![0])
        let cellRect = attribute?.frame
        let animatedFrame = collectionView?.convert((cellRect)!, to: collectionView.superview)
        
        return animatedFrame!
    }
}
