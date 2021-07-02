//
//  FullScreenViewController.swift
//  ImageSearch
//
//  Created by Roi Kedarya on 02/07/2021.
//

import Foundation
import UIKit

class FullScreenViewController: UIViewController {
    
    //@IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    var index: Int!
    var imageListVM: ImageListViewModel!
    var pages = [ScrollerView]()
    
    override func viewDidLoad() {
        setPages()
        setupScrollView(pages: pages)
        ShowImageFor(self.index)
    }
    
    func ShowImageFor(_ index: Int) {
        let imageVM = imageListVM.imageAtIndex(index)
        Webservice.shared.getImageFromUrl(imageVM.largeImageURL) { [weak self] data, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                DispatchQueue.main.async {
                    if let scrollerView = self?.pages[index] {
                        let image = UIImage(data: data)
                        scrollerView.image = UIImageView(image: image)
                        if let imageView = scrollerView.image {
                            imageView.contentMode = .scaleToFill
                            scrollerView.addSubview(imageView)
                            imageView.frame = CGRect.init(x: 0, y: 0, width: scrollerView.frame.width, height: scrollerView.frame.height)
                            NSLayoutConstraint.activate([
                                imageView.topAnchor.constraint(equalTo: scrollerView.topAnchor),
                                imageView.bottomAnchor.constraint(equalTo: scrollerView.bottomAnchor)
                            ])
                            print(imageView.frame)
                        }
                    }
                }
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        ShowImageFor(Int(pageIndex))
    }
    
    func setupScrollView(pages: [ScrollerView]) {
        scrollView.frame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let width: CGFloat = view.frame.width * CGFloat(imageListVM.images.count)
        scrollView.contentSize = CGSize.init(width: width, height: view.frame.height)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< pages.count {
            pages[i].frame = CGRect.init(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(pages[i])
        }
        
    }
}
