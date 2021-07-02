//
//  ImageViewModel.swift
//  ImageSearch
//
//  Created by Roi Kedarya on 02/07/2021.
//

import Foundation

struct ImageViewModel {
    private let image: Image
    
    init(_ image: Image) {
        self.image = image
    }
    
    var previewURL: String {
        return image.previewURL
    }
    
    var largeImageURL: String {
        return image.largeImageURL
    }
}

struct ImageListViewModel {
    var images: [Image]
    
    init(_ images: [Image]?) {
        if let images = images {
            self.images = images
        } else {
            self.images = [Image]()
        }
    }
    
    static let numberOfSections = 1
    
    func numberOfItemsInSection(section: Int) -> Int {
        return images.count
    }
    
    func imageAtIndex(_ index: Int) -> ImageViewModel {
        let image = ImageViewModel(images[index])
        return image
    }
}
