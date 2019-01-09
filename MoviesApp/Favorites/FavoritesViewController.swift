//
//  FavoritesViewController.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 12/24/18.
//  Copyright © 2018 Swift Enthusiast. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    
    var dataController: DataController!
    var blockOperations: [BlockOperation] = []
    
    var fetchedResultsController: NSFetchedResultsController<MovieDetail>!
    
    var isEditingMode: Bool = false

    fileprivate let kLeftPadding: CGFloat = 4.5
    fileprivate let kRightPadding: CGFloat = 4.5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupFetchedResultsController()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isEditingMode = false
        btnEdit.title = "Edit"
    }
    
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<MovieDetail> = MovieDetail.fetchRequest()
        
        let predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
        fetchRequest.predicate = predicate
        
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
    
    fileprivate func setupCollectionView() {
        favoritesCollectionView.delegate = self
        favoritesCollectionView.dataSource = self
    }
    
    //MARK: Action Methods
    @IBAction func btnEditAction(_ sender: UIBarButtonItem) {
        
        btnEdit.title = isEditingMode ? "Edit": "Done"
        isEditingMode = !isEditingMode

    }
 
}

extension FavoritesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieDetail = fetchedResultsController.object(at: indexPath)
        let favoritesCell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesCell.reuseIdentifier, for: indexPath) as! FavoritesCell
        favoritesCell.configure(movieDetail: movieDetail, indexPath: indexPath)
        
        return favoritesCell
    }
    
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieDetail = fetchedResultsController.object(at: indexPath)
        if isEditingMode {
            let movieDetail = fetchedResultsController.object(at: indexPath)
            movieDetail.isFavorite = false
        } else {
            let detailViewControler = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            detailViewControler.movieDetail = movieDetail
            navigationController?.pushViewController(detailViewControler, animated: true)
        }
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

extension FavoritesViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        try? fetchedResultsController.performFetch()
        switch type {
        case .insert:
            blockOperations.append(BlockOperation(block: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.favoritesCollectionView.insertItems(at: [newIndexPath!])
            }))
            break
        case .delete:
            blockOperations.append(BlockOperation(block: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.favoritesCollectionView.deleteItems(at: [indexPath!])
            }))
            break
        case .update, .move:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.favoritesCollectionView!.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
}
