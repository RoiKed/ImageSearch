//
//  ImageSearchViewController.swift
//  ImageSearch
//
//  Created by Roi Kedarya on 02/07/2021.
//

import Foundation
import UIKit

class ImageSearchViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private let mainStoryboard = UIStoryboard.init(name: "Main", bundle:nil)
    private var payBoxUrlBaseString = "https://pixabay.com/api/?key=12055825-e70cbf6e70297050349021fe0"
    private var searchUrlString = ""
    private var page = 1
    private var imageListVM = ImageListViewModel(nil)
    
    //MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopSpinner()
        setup()
    }
    
    private func setup() {
        setTable()
        setSearchBar()
    }
    
    private func setTable() {
        collectionView.register(UINib(nibName: "CollectionCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
        self.collectionView.isHidden = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isPagingEnabled = true
    }
    
    private func setSearchBar() {
        searchBar.placeholder = "search"
        searchBar.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(removeKeyboard))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
        let rightBarButtonItem = UIBarButtonItem(customView:searchBar)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    private func startSpinner() {
        spinner.isHidden = false
        spinner.startAnimating()
    }
    
    private func stopSpinner() {
        spinner.isHidden = true
        spinner.stopAnimating()
    }
    
    @objc func removeKeyboard() {
        searchBar.resignFirstResponder()
    }
}

extension ImageSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchString = searchBar.text, searchString.isEmpty == false {
            clearOldResults()
            searchUrlString = payBoxUrlBaseString + "&q=\(searchString)"
            loadContent(for: searchUrlString) { [weak self] in
                let start = IndexPath(row: 0, section: 0)
                self?.collectionView.scrollToItem(at: start, at: .top, animated: true)
            }
        }
    }
    
    private func loadContent(for urlString: String, _ completion:(()->())?) {
        if let url = URL(string: urlString) {
            startSpinner()
            Webservice.shared.getImages(url: url) { [weak self] images in
                if let images = images {
                    self?.imageListVM.images.append(contentsOf: images)
                }
                DispatchQueue.main.async {
                    self?.updateScreenAfterContentLoaded()
                    if let completion = completion {
                        completion()
                    }
                }
            }
        }
    }
    
    private func updateScreenAfterContentLoaded() {
        self.collectionView.reloadData()
        self.stopSpinner()
        self.removeKeyboard()
        if collectionView.isHidden {
            self.showCollectionView()
        }
    }
    
    func clearOldResults() {
        self.imageListVM.images.removeAll()
        page = 1
        searchUrlString = ""
    }
    
    func showCollectionView() {
        collectionViewTopConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        self.collectionView.isHidden = false
    }
}

extension ImageSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.width / 3).rounded(.down) - 12
        return CGSize.init(width: size, height: size)
    }
}
extension ImageSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageListVM.numberOfItemsInSection(section: section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return ImageListViewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? CollectionCell else {
            fatalError("cell not found")
        }
        let imageVM = imageListVM.imageAtIndex(indexPath.row)
        Webservice.shared.getImageFromUrl(imageVM.previewURL) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                cell.loadImageFrom(data)
            }
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height) {
            page += 1
            //print("Reached the end...loading page \(page)")
            let urlForNextPage = searchUrlString + "&page=\(page)"
            loadContent(for: urlForNextPage, nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentFullScreenViewControllerFor(indexPath)
    }
    
    private func presentFullScreenViewControllerFor(_ indexPath: IndexPath) {
        let displayImageViewController: FullScreenViewController = mainStoryboard.instantiateViewController(identifier: "presentationViewController")
        displayImageViewController.index = indexPath.row
        displayImageViewController.imageListVM = self.imageListVM
        self.navigationController?.pushViewController(displayImageViewController, animated: true)
    }
    
}


