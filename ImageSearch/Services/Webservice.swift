//
//  Webservice.swift
//  ImageSearch
//
//  Created by Roi Kedarya on 02/07/2021.
//

import Foundation
import UIKit

enum NetworkManagerError: Error {
    case badResponse(URLResponse?)
    case badData
    case invalidUrl
    case badLocalUrl
}


class Webservice {
    
    private var images = NSCache<NSString, NSData>()
    static let shared: Webservice = Webservice()
    
    private init() {}
    
    func getImages(url: URL, completion: @escaping ([Image]?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else if let data = data {
                do {
                    let imageList = try JSONDecoder().decode(ImageList.self, from: data)
                    let images = imageList.hits
                        completion(images)
                    //print("found \(imageList.total) results \(imageList.totalHits)")
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    func getImageFromUrl(_ urlString: String, completion: @escaping (Data?, Error?) -> ()) {
        //check first if exist in cache
        if let imageData = images.object(forKey: urlString as NSString) {
              print("using cached images")
              completion(imageData as Data, nil)
              return
        }
        
        //download the image and store it to cache
        guard let url = URL(string: urlString) else {
            completion(nil,NetworkManagerError.invalidUrl)
            return
        }
        URLSession.shared.downloadTask(with: url) { localUrl, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            guard let localUrl = localUrl else {
                completion(nil, NetworkManagerError.badLocalUrl)
                return
            }
            
            do {
                let data = try Data(contentsOf: localUrl)
                self.images.setObject(data as NSData, forKey: urlString as NSString)
                print("downloaded new image")
                completion(data, nil)
            } catch let error {
                completion(nil, error)
              }
            }.resume()
        }
}
