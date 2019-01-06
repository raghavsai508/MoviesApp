//
//  MoviesCollectionViewController.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 12/24/18.
//  Copyright © 2018 Swift Enthusiast. All rights reserved.
//

import UIKit
import CoreData

class MoviesCollectionViewController: UIViewController {
    
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    var movies: [Movie]?
    var dataController: DataController!
    var blockOperations: [BlockOperation] = []
    var fetchedResultsController: NSFetchedResultsController<MovieDetail>!
    var fetchedMovieIds: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadPopularMovies()
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        fetchedResultsController = nil
//    }
    
    func loadPopularMovies() {
        let networkManager = NetworkManager.sharedInstance()
        _ = networkManager.getMovies { [weak self](moviesArray, error) in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                
                if error != nil {
                    print(error!)
                } else {
//                    print(moviesArray!)
                    if let moviesArray = moviesArray {
                        for movie in moviesArray {
                            if !strongSelf.movieDetailExists(id: movie.id) {
                                let movieDetail = MovieDetail(context: strongSelf.dataController.viewContext)
                                movieDetail.title = movie.title
                                movieDetail.movieId = Int32(movie.id)
                                movieDetail.posterPath = movie.posterPath
                                movieDetail.popularity = movie.popularity
                                movieDetail.voteCount = Int32(movie.voteCount)
                                movieDetail.voteAverage = movie.voteAverage
                                movieDetail.originalTitle = movie.originalTitle
                                movieDetail.overview = movie.overview
                                movieDetail.releaseDate = movie.releaseDate
                                movieDetail.isFavorite = false
                            }
                        }
                    }
                    
                    do {
                        try strongSelf.dataController.viewContext.save()
                        strongSelf.setupFetchedResultsController()
                        strongSelf.moviesCollectionView.dataSource = self
                        strongSelf.moviesCollectionView.delegate = self
                    } catch let error as NSError {
                        fatalError("The fetch could not store the photo: \(error.userInfo)")
                    }
                }
            }
        }
    }
    
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<MovieDetail> = MovieDetail.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
//            if let moviesDetailsFetched = fetchedResultsController.fetchedObjects {
//                for movieDetail in moviesDetailsFetched {
//                    fetchedMovieIds.append(Int(movieDetail.movieId))
//                }
//            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
}


extension MoviesCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieDetail = fetchedResultsController.object(at: indexPath)
        let movieCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        movieCell.delegate = self
        movieCell.configure(movieDetail: movieDetail, indexPath: indexPath)
        
        return movieCell
    }
    
    
    fileprivate func movieDetailExists(id: Int) -> Bool {
        let fetchRequest:NSFetchRequest<MovieDetail> = MovieDetail.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "movieId = %d", id)
        
        var results: [NSManagedObject] = []

        do {
            results = try dataController.viewContext.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return results.count > 0
        
    }
    
}

extension MoviesCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieDetail = fetchedResultsController.object(at: indexPath)
        let detailViewControler = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewControler.movieDetail = movieDetail
        navigationController?.pushViewController(detailViewControler, animated: true)
    }
    
}

extension MoviesCollectionViewController: MovieCellDelegate {
    
    func favoriteClicked(at indexPath: IndexPath) {
        
        
    }
    
}

extension MoviesCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        try? fetchedResultsController.performFetch()
        switch type {
        case .insert:
            blockOperations.append(BlockOperation(block: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.moviesCollectionView.insertItems(at: [newIndexPath!])
            }))
            break
        case .delete:
            blockOperations.append(BlockOperation(block: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.moviesCollectionView.deleteItems(at: [indexPath!])
            }))
            break
        case .update, .move:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.moviesCollectionView!.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
}

