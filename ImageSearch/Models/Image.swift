//
//  Image.swift
//  ImageSearch
//
//  Created by Roi Kedarya on 02/07/2021.
//

import Foundation

struct ImageList: Decodable {
    let total: Int
    let totalHits: Int
    let hits: [Image]
}

struct Image: Decodable {
    let previewURL: String
    let largeImageURL: String
    let id: Int
}
