//
//  MovieCell.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 12/25/18.
//  Copyright © 2018 Swift Enthusiast. All rights reserved.
//

import UIKit

class MovieCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewPoster: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(imageName: String) {
        let networkManager = NetworkManager.sharedInstance()
        _ = networkManager.getPosterMovie(imageName: imageName, completionHandlerForMovieImage: { (image, error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                } else {
                    self.imageViewPoster.image = image
                }
            }
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewPoster.image = nil
    }
    
}
