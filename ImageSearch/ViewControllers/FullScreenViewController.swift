//
//  FullScreenViewController.swift
//  ImageSearch
//
//  Created by Roi Kedarya on 02/07/2021.
//

import Foundation
import UIKit

class FullScreenViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var index: Int?
    var imageListVM: ImageListViewModel!
    var pages = [ScrollerView]()
    private var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        setPages()
        setupScrollView(pages: pages)
        stopSpinner()
        if let index = index {
            ShowImageFor(index)
        }
    }
    
    private func startSpinner() {
        spinner.isHidden = false
        spinner.startAnimating()
    }
    
    private func stopSpinner() {
        spinner.isHidden = true
        spinner.stopAnimating()
    }
    
    func ShowImageFor(_ index: Int) {
        let imageVM = imageListVM.imageAtIndex(index)
        startSpinner()
        Webservice.shared.getImageFromUrl(imageVM.largeImageURL) { [weak self] data, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                DispatchQueue.main.async {
                    self?.stopSpinner()
                    self?.setImageInScrollerFor(index, imageData: data)
                }
            }
        }
    }
    
    func setImageInScrollerFor(_ index: Int, imageData: Data) {
        if index < self.pages.count {
            let scrollerView = self.pages[index]
            let image = UIImage(data: imageData)
            let imageView = UIImageView(image: image)
            scrollerView.addSubview(imageView)
            imageView.frame = CGRect(x: 0, y: 0, width: scrollerView.frame.width, height: scrollerView.frame.height)
            imageView.contentMode = .scaleToFill
            print(scrollerView)
            if let xPosition = scrollerView.xPosition {
                self.scrollView.contentOffset = CGPoint(x: xPosition, y: 0)
                self.index = Int(xPosition / view.frame.width)
            }
        }
    }
    
    func setPages() {
        pages.removeAll()
        for image in imageListVM.images {
            let page: ScrollerView = ScrollerView.init()
            page.imageUrl = image.largeImageURL
            
            pages.append(page)
        }
    }
}

extension FullScreenViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var nextIndex = Int(scrollView.contentOffset.x / view.frame.width)
        self.lastContentOffset = scrollView.contentOffset.x
        if  (0 ..< pages.count).contains(nextIndex) {
            ShowImageFor(nextIndex)
        }
    }
    
    func setupScrollView(pages: [ScrollerView]) {
        let navBarHeight = self.navigationController != nil ? self.navigationController!.navigationBar.frame.height : 0
        let height = view.frame.height - navBarHeight
        let width = view.frame.width
        scrollView.frame = CGRect.init(x: 0, y: 0, width: width, height: height)
        let relativeWidth: CGFloat = width * CGFloat(imageListVM.images.count)
        scrollView.contentSize = CGSize.init(width: relativeWidth, height: height)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        for i in 0 ..< pages.count {
            let xPosition = view.frame.width * CGFloat(i)
            pages[i].frame = CGRect.init(x: xPosition , y: 0, width: width, height: height)
            pages[i].xPosition = xPosition
            scrollView.addSubview(pages[i])
        }
        
    }
        
}
