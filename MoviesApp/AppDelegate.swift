//
//  AppDelegate.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 10/21/18.
//  Copyright © 2018 Swift Enthusiast. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let dataController = DataController(modelName: Constants.PersistentStore.ModelName)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        dataController.load()

        let navigationController = window?.rootViewController as! UINavigationController
        let tabbarController = navigationController.topViewController as! UITabBarController
        let moviesCollectionController = tabbarController.viewControllers![0] as! MoviesCollectionViewController
        moviesCollectionController.dataController = dataController
        
        let favoritesCollectionController = tabbarController.viewControllers![1] as! FavoritesViewController
        favoritesCollectionController.dataController = dataController
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveViewContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        deleteAllUnFavorites()
        saveViewContext()
    }

    func saveViewContext() {
        try? dataController.viewContext.save()
    }
    
    func deleteAllUnFavorites() {
        let fetchRequest:NSFetchRequest<MovieDetail> = MovieDetail.fetchRequest()
        
        let predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: false))
        fetchRequest.predicate = predicate
        
        var results: [NSManagedObject] = []

        do {
            results = try dataController.viewContext.fetch(fetchRequest)
            for object in results {
                dataController.viewContext.delete(object)
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
    }

}

