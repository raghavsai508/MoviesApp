//
//  FavoritesCell.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 1/7/19.
//  Copyright © 2019 Swift Enthusiast. All rights reserved.
//

import UIKit

class FavoritesCell: UICollectionViewCell, Cell {
    
    @IBOutlet weak var imageViewPoster: UIImageView!
    @IBOutlet weak var selectionView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(movieDetail: MovieDetail, indexPath: IndexPath) {
        let networkManager = NetworkManager.sharedInstance()
        if let posterPath = movieDetail.posterPath, movieDetail.image == nil {
            _ = networkManager.getPosterMovie(imageName: posterPath, completionHandlerForMovieImage: { (image, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        print(error!)
                    } else {
                        self.imageViewPoster.image = image
                        movieDetail.image = image?.pngData()
                    }
                }
            })
        } else if let image = movieDetail.image {
            let image = UIImage(data: image)
            imageViewPoster.image = image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewPoster.image = nil
        selectionView.backgroundColor = UIColor.clear
    }
    
    
    
}
