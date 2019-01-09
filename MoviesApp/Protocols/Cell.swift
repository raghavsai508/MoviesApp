//
//  Cell.swift
//  MoviesApp
//
//  Created by Raghav Sai Cheedalla on 1/7/19.
//  Copyright © 2019 Swift Enthusiast. All rights reserved.
//

import UIKit

protocol Cell: class {
    static var reuseIdentifier: String { get }
}

extension Cell {
    static var reuseIdentifier: String {
        return "\(self)"
    }
}
