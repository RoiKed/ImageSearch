//
//  CollectionCell.swift
//  ImageSearch
//
//  Created by Roi Kedarya on 02/07/2021.
//

import Foundation
import UIKit

class CollectionCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    
    func loadImageFrom(_ data: Data) {
        DispatchQueue.global().async { [weak self] in
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image.image = image
                }
            }
        }
    }
}
