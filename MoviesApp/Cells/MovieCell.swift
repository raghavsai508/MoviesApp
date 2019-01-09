//
//  MovieCell.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 12/25/18.
//  Copyright © 2018 Swift Enthusiast. All rights reserved.
//

import UIKit

protocol MovieCellDelegate: AnyObject {
    func favoriteClicked(at indexPath: IndexPath)
}


class MovieCell: UICollectionViewCell, Cell {
    
    @IBOutlet weak var imageViewPoster: UIImageView!
    @IBOutlet weak var btnFavorite: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: MovieCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(movieDetail: MovieDetail, indexPath: IndexPath) {
        let networkManager = NetworkManager.sharedInstance()
        if let posterPath = movieDetail.posterPath, movieDetail.image == nil {
            if !activityIndicator.isAnimating {
                activityIndicator.startAnimating()
            }
            _ = networkManager.getPosterMovie(imageName: posterPath, completionHandlerForMovieImage: { (image, error) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
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
        
        btnFavorite.tag = indexPath.item
        var imageName = "unfavorite"
        if movieDetail.isFavorite {
            imageName = "favorite"
        }
        
        btnFavorite.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @IBAction func btnFavoriteAction(_ sender: UIButton) {
        let indexPath = IndexPath(item: sender.tag, section: 0)
        delegate?.favoriteClicked(at: indexPath)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewPoster.image = nil
    }
    
}
