//
//  MoviesCollectionViewController.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 12/24/18.
//  Copyright © 2018 Swift Enthusiast. All rights reserved.
//

import UIKit

class MoviesCollectionViewController: UIViewController {
    
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    var movies: [Movie]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        moviesCollectionView.dataSource = self
        moviesCollectionView.delegate = self
        loadPopularMovies()
    }
    
    func loadPopularMovies() {
        let networkManager = NetworkManager.sharedInstance()
        _ = networkManager.getMovies { (moviesArray, error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                } else {
                    print(moviesArray!)
                    self.movies = moviesArray
                    self.moviesCollectionView.reloadData()
                }
            }
        }
    }
}


extension MoviesCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let count = movies?.count else {
            return 0
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.item]
        movieCell.configure(imageName: movie.posterPath)
        
        return movieCell
    }
    
}

extension MoviesCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies![indexPath.item]
        let detailViewControler = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewControler.movie = movie
        navigationController?.pushViewController(detailViewControler, animated: true)
    }
    
}
