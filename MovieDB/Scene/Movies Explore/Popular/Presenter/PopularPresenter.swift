//
//  PopularPresenter.swift
//  MovieDB
//
//  Created by Eldar Goloviznin on 22/08/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation

protocol PopularPresenter {
    
    var view: MoviesExploreView? { get set }
    
    func request()
    func requestNext()
    
    func showDetails(movie: Movie)
}

class PopularPresenterDefault: MoviesExplorePresenterDefault, PopularPresenter {

    fileprivate let moviesProvider: MoviesProvider

    init(router: Router, moviesProvider: MoviesProvider) {
        self.moviesProvider = moviesProvider
        super.init(router: router)
    }
    
    func request() {
        moviesProvider.fetchPopularMovies { [weak self] result in
            self?.handleRequestResult(result: result, refreshed: true)
        }
    }
    
    func requestNext() {
        moviesProvider.fetchNext { [weak self] result in
            self?.handleRequestResult(result: result, refreshed: false)
        }
    }
    
}
