//
//  MovieDetail+Extensions.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 12/29/18.
//  Copyright © 2018 Swift Enthusiast. All rights reserved.
//

import Foundation
import CoreData

extension MovieDetail {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
