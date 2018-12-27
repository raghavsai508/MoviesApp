//
//  DetailViewController.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 12/26/18.
//  Copyright © 2018 Swift Enthusiast. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imageViewPoster: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPopularity: UILabel!
    @IBOutlet weak var lblVoteCount: UILabel!
    @IBOutlet weak var lblVoteAverage: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadMovieDetails()
    }
    
    
    func loadMovieDetails() {
        lblTitle.text = movie.title
        lblDate.text = movie.releaseDate
        lblPopularity.text = "\(movie.popularity)"
        lblVoteCount.text = "\(movie.voteCount)"
        lblVoteAverage.text = "\(movie.voteAverage)"
        lblDescription.text = movie.overview
        
        let networkManager = NetworkManager.sharedInstance()
        _ = networkManager.getPosterMovie(imageName: movie.posterPath, completionHandlerForMovieImage: { (image, error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                } else {
                    self.imageViewPoster.image = image
                }
            }
        })
    }

}
