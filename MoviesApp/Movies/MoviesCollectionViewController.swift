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
    @IBOutlet weak var btnRefresh: UIBarButtonItem!
    
    var movies: [Movie]?
    var dataController: DataController!
    var blockOperations: [BlockOperation] = []
    var fetchedResultsController: NSFetchedResultsController<MovieDetail>!
    var fetchedMovieIds: [Int] = []
    
    fileprivate let kLeftPadding: CGFloat = 4.5
    fileprivate let kRightPadding: CGFloat = 4.5

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadPopularMovies()
    }
    
    func loadPopularMovies(page: Int = 1) {
        let networkManager = NetworkManager.sharedInstance()
        _ = networkManager.getMovies(page: page) { [weak self](moviesArray, error) in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                
                if error != nil {
                    print(error!)
                } else {
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
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    //MARK: Action Methods
    
    @IBAction func btnRefresh(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        var pageNumber = userDefaults.integer(forKey: Constants.MovieSettings.Page)
        if pageNumber == 1000 {
            pageNumber = 0
        }
        pageNumber = pageNumber + 1
        userDefaults.set(pageNumber, forKey: Constants.MovieSettings.Page)
        userDefaults.synchronize()
        
        if let movies = fetchedResultsController?.fetchedObjects {
            for movieDetail in movies {
                if movieDetail.isFavorite == false {
                    dataController.viewContext.delete(movieDetail)
                }
            }
        }
        
        loadPopularMovies(page: pageNumber)
    }
    
}


extension MoviesCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieDetail = fetchedResultsController.object(at: indexPath)
        let movieCell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.bounds.size.width/2.0)-kRightPadding-kLeftPadding
        let size = CGSize(width: width, height: width)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: kLeftPadding/2, bottom: 0, right: kRightPadding/2)
    }
    
}

extension MoviesCollectionViewController: MovieCellDelegate {
    
    func favoriteClicked(at indexPath: IndexPath) {
        let movieDetail = fetchedResultsController.object(at: indexPath)
        movieDetail.isFavorite = !movieDetail.isFavorite
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
        case .update:
            blockOperations.append(BlockOperation(block: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.moviesCollectionView.reloadItems(at: [indexPath!])
            }))
            break
            
        case .move:
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

