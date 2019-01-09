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
    
    var movieDetail: MovieDetail!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadMovieDetails()
    }
    
    
    func loadMovieDetails() {
        lblTitle.text = movieDetail.title
        lblDate.text = movieDetail.releaseDate
        lblPopularity.text = "\(movieDetail.popularity)"
        lblVoteCount.text = "\(movieDetail.voteCount)"
        lblVoteAverage.text = "\(movieDetail.voteAverage)"
        lblDescription.text = movieDetail.overview
        
        if let image = movieDetail.image {
            let image = UIImage(data: image)
            imageViewPoster.image = image
        } else if let posterPath = movieDetail.posterPath {
            let networkManager = NetworkManager.sharedInstance()
            _ = networkManager.getPosterMovie(imageName: posterPath, completionHandlerForMovieImage: { (image, error) in
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
    
    //MARK: Action Methods
    @IBAction func btnBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
}
