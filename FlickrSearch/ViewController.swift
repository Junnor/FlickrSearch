//
//  ViewController.swift
//  FlickrSearch
//
//  Created by Ju on 2017/6/6.
//  Copyright © 2017年 Ju. All rights reserved.
//

// b2f908edd7b9350c788d8ff7e8bbc263

import UIKit
import MessageUI
import AVFoundation

class ViewController: UIViewController, UISearchBarDelegate {
    
    private let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate var sharing = false

    fileprivate var selectedPhotos = [IndexPath: FlickrPhoto]()
    fileprivate var historyIndexPath: IndexPath!
    
    @IBOutlet var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    fileprivate var searchResults = [String: [FlickrPhoto]]()
    fileprivate var searchTags = [String]()
    
    fileprivate var photosImg = [[UIImage]]()
    

    private var pinterestLayout: PinterestLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.color = UIColor.red
        indicator.stopAnimating()
        view.addSubview(indicator)
        
        // Layout
        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            pinterestLayout = layout
            pinterestLayout.delegate = self
        }
        collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
        
        print("viewDidLoad")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        indicator.center = view.center
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Flickr Photo" {
            let indexPath = collectionView.indexPathsForSelectedItems![0]
            let dsvc = segue.destination as! FlickrPhotoViewController
            dsvc.flickrPhoto = flickrPhoto(at: indexPath)
        }
    }
    
    private var column = 3
    @IBAction func changeColumn(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: column = 3
        case 1: column = 4
        case 2: column = 5
        default: break
        }
        
        UIView.animate(withDuration: 1.0, animations: { 
            self.pinterestLayout.numberOfColumns = self.column
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
        
    }
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
    }

    @IBAction func share(_ sender: Any) {
        if sharing {
            sharing = false
            shareButton.title = "Share"
            collectionView.allowsMultipleSelection = false
            
            if selectedPhotos.keys.count > 0 {
                showMailComposerAndSend()
            }
            
            for indexPath in selectedPhotos.keys {
                collectionView.deselectItem(at: indexPath, animated: true)
            }
            selectedPhotos.removeAll()

        } else {
            sharing = true
            shareButton.title = "Done"
            collectionView.allowsMultipleSelection = true
        }
    }
    
    private func showMailComposerAndSend() {
        if MFMessageComposeViewController.canSendAttachments() {
            let mailer = MFMessageComposeViewController()
            mailer.messageComposeDelegate = self
            mailer.subject = "Check out these flickr photos"
            var emailBody = ""
            for (_, photo) in selectedPhotos {
                emailBody.append("Flick Share With Photo")
                mailer.addAttachmentURL(photo.photoUrl, withAlternateFilename: nil)
            }
            mailer.body = emailBody
            present(mailer, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Mail Failure", message: "Your device can not send email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Search bar delegte
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {

            indicator.startAnimating()
            FlickrProvider.fetchPhotosForSearchText(searchText: searchBar.text!, onCompletion: { [weak self] (error, photos) in
                self?.indicator.stopAnimating()
                if photos != nil && photos?.count != 0 {
                    if !(self?.searchTags.contains(searchBar.text!))! {

                        // 1
                        self?.searchTags.removeAll()
                        self?.searchResults.removeAll()
                        self?.photosImg.removeAll()
                        
                        //2
                        self?.searchTags.append(searchBar.text!)
                        self?.searchResults[searchBar.text!] = photos!
                        
                        var imgs = [UIImage]()
                        if !(photos?.isEmpty)! {
                            for img in photos! {
                                imgs.append(img.thumbnail)
                            }
                        }
                        self?.photosImg.append(imgs)
                        
//                        self?.fetchHightQuantityImage()
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
    
    fileprivate func flickrPhoto(at indexPath: IndexPath) -> FlickrPhoto {
        let tag = searchTags[indexPath.section]
        return searchResults[tag]![indexPath.row]
    }
    
    fileprivate func item(of flickrPhoto: FlickrPhoto) -> Int {
        return 0
    }
}

extension ViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            print("send")
        case .cancelled:
            print("canced")
        case .failed:
            print("failed")
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searchResults.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = searchTags[section]
        return searchResults[key]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrCell", for: indexPath)
        if let cell = cell as? FlickrCell {
            let photo = flickrPhoto(at: indexPath)
            cell.flickrPhoto = photo
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
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

extension Array where Element: AnyObject {
    mutating func removeObject(object: Element) {
        if let index = index(where: { $0 === object }) {
            remove(at: index)
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if sharing {
            selectedPhotos[indexPath] = flickrPhoto(at: indexPath)
        } else {
            performSegue(withIdentifier: "Show Flickr Photo", sender: self)
            historyIndexPath = indexPath  // for custom segue ...if needed
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedPhotos.removeValue(forKey: indexPath)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if searchResults.count != 0 {
            let photo = flickrPhoto(at: indexPath)
            return photo.thumbnail.size
        }
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
    }
}

extension ViewController: PinterestLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAt indexPath: IndexPath, width: CGFloat) -> CGFloat {
        
        let photo = photosImg[indexPath.section][indexPath.row]
        let boundingRect = CGRect(x: 0.0, y: 0.0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRect(aspectRatio: photo.size, insideRect: boundingRect)
        return rect.size.height
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForAnnotationAt indexPath: IndexPath, width: CGFloat) -> CGFloat {
        
        return 0
    }
}


// MARK: - ViewHeadabel protocol

extension ViewController: ViewHeadabel {
    
    var animatedViewFrame: CGRect {

//        let attribute = collectionView.layoutAttributesForItem(at: collectionView.indexPathsForSelectedItems![0])
//        let cellRect = attribute?.frame
        
        let cell = collectionView.cellForItem(at: historyIndexPath!)
        let cellRect = cell?.frame

        let animatedFrame = collectionView?.convert((cellRect)!, to: collectionView.superview)
        
        return animatedFrame!
    }
}
