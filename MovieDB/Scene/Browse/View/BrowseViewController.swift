//
//  BrowseViewController.swift
//  MovieDB
//
//  Created by Eldar Goloviznin on 27/08/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit

class BrowseViewController: UITableViewController {
    
    var presenter: BrowsePresenter!
    
    @IBOutlet weak var randomMovieImageView: UIImageView!
    
    @IBOutlet weak var randomMovieTitle: UILabel!
    
    @IBOutlet weak var randomMovieRatingView: RatingView!
    
    @IBOutlet weak var randomMovieYearLabel: UILabel!
    
    @IBOutlet weak var randomMovieOverview: UILabel!
    
    private var appearingAfterLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.view = self
        presenter.refresh()
        
        configureRandomMovieImageView()
        configureRefreshControl()
        configureSearchBar()
        
        tableView.separatorColor = .black
        
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .top
        
        (tableView.tableHeaderView as? UIControl)?.addTarget(self, action: #selector(showRandomMovieDetails), for: .touchUpInside)
    }
    
    func configureRandomMovieImageView() {
        randomMovieImageView.contentMode = .scaleAspectFill
        randomMovieImageView.clipsToBounds = true
        randomMovieImageView.layer.cornerRadius = Constants.RandomMovieImageView.cornerRadius
        randomMovieTitle.adjustsFontSizeToFitWidth = true
    }
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func configureSearchBar() {
        presenter.loadSearchResultsScene()
        let searchController = self.navigationItem.searchController!
        searchController.searchResultsUpdater = self
        let searchBar = searchController.searchBar
        searchBar.delegate = self
        searchBar.barStyle = .black
        searchBar.tintColor = .white
        searchBar.placeholder = Constants.SearchBar.placeholder
        searchBar.keyboardAppearance = .dark
        self.definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if appearingAfterLoading {
            self.navigationItem.searchController?.searchBar.superview?.subviews.first?.isHidden = true
            appearingAfterLoading = false
        }
    }
    
    @objc func showRandomMovieDetails() {
        presenter.showRandomMovieDetails()
    }
    
    private func updateHeader() {
        let header = self.tableView.tableHeaderView!
        
        let headerWidth = header.bounds.width
        
        let headerHeight = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        
        header.frame = CGRect(origin: .zero, size: CGSize(width: headerWidth, height: headerHeight))
        
        tableView.tableHeaderView = header
    }
    
    @objc func refresh() {
        presenter.refresh()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.genres.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        
        cell.selectionStyle = .none
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = presenter.genres[indexPath.row].localizedString
        cell.backgroundColor = self.view.backgroundColor
        
        return cell        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.select(genre: presenter.genres[indexPath.row])
    }
    
}

extension BrowseViewController: BrowseView {
    
    func update(withRandomMovie movie: Movie) {
        tableView.refreshControl?.endRefreshing()
        
        randomMovieImageView.sd_cancelCurrentImageLoad()
        
        randomMovieImageView.sd_setImage(with: movie.backdropURL ?? movie.posterURL)
        randomMovieTitle.text = movie.title
        randomMovieOverview.text = movie.overview
        
        if let releaseDate = movie.releaseDate {
            let year = Calendar.current.component(.year, from: releaseDate)
            randomMovieYearLabel.text = "\(year)"
        }
        
        if let voteAverage = movie.voteAverage, let voteCount = movie.voteCount {
            randomMovieRatingView.rating = CGFloat(voteAverage)
            randomMovieRatingView.votesCount = voteCount
        }
        
        updateHeader()
    }
    
    func showError(description: String) {
        tableView.refreshControl?.endRefreshing()
        print(description)
    }
    
}

extension BrowseViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let title = searchBar.text!
        (self.navigationItem.searchController?.searchResultsController as? TitleMovieSearchViewController)?.search(title: title)
    }
    
}

extension BrowseViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let title = searchController.searchBar.text!
        // Workaround to remove shadow image from searchbar
        self.navigationItem.searchController?.searchBar.superview?.subviews.first?.isHidden = title.count == 0
        if title.last == " " {
            (self.navigationItem.searchController?.searchResultsController as? TitleMovieSearchViewController)?.search(title: title)
        }
    }
    
}

fileprivate struct Constants {
    struct SearchBar {
        static let placeholder = NSLocalizedString("Title", comment: #file)
    }
    struct RandomMovieImageView {
        static let cornerRadius: CGFloat = 8.0
    }
}
