//
//  MoviesTableViewController.swift
//  MoviesAppUIKit
//
//  Created by Mohammad Azam on 10/12/23.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class MoviesViewController: UIViewController {
    
    let viewModel: MovieListViewModel
    private var cancellables: Set<AnyCancellable> = []
    init(viewModel: MovieListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        return searchBar
    }()
    
    lazy var moviesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.$loadingCompleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completed in
                if completed {
                    self?.moviesTableView.reloadData()
                    // reload tableview
                }
            }.store(in: &cancellables)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        moviesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieTableViewCell")
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        stackView.addArrangedSubview(searchBar)
        stackView.addArrangedSubview(moviesTableView)
        
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
}

extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.movies.count
    }
    /*
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath)
        let movie = viewModel.movies[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = movie.title
        content.secondaryText = movie.year
        content.image = nil
        cell.contentConfiguration = content
        
        if let url = URL(string: movie.poster!) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        var updatedContent = cell.defaultContentConfiguration()
                        updatedContent.text = movie.title
                        updatedContent.secondaryText = movie.year
                        updatedContent.imageProperties.maximumSize = CGSize(width: 60, height: 60)
                        let resizedImage = image.preparingThumbnail(of: CGSize(width: 60, height: 60)) ?? image
                        updatedContent.image = resizedImage
                        cell.contentConfiguration = updatedContent
                    }
                } else {
                    // 若 poster 為空或無效，使用預設圖示
                    var fallbackContent = cell.defaultContentConfiguration()
                    fallbackContent.text = movie.title
                    fallbackContent.secondaryText = movie.year
                    fallbackContent.image = UIImage(systemName: "film")
                    cell.contentConfiguration = fallbackContent
                }
            }.resume()
        }
        
        
        return cell
    }*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath)
        let movie = viewModel.movies[indexPath.row]
        
        // 先設定預設內容，不顯示圖片，避免 cell 顯示空白
        var content = cell.defaultContentConfiguration()
        content.text = movie.title
        content.secondaryText = movie.year
        content.image = nil
        cell.contentConfiguration = content
        
        // 安全解包 poster，如果 poster 存在且不為空，才嘗試下載圖片
        if let posterString = movie.poster, !posterString.isEmpty, let url = URL(string: posterString) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        var updatedContent = cell.defaultContentConfiguration()
                        updatedContent.text = movie.title
                        updatedContent.secondaryText = movie.year
                        updatedContent.imageProperties.maximumSize = CGSize(width: 60, height: 60)
                        let resizedImage = image.preparingThumbnail(of: CGSize(width: 60, height: 60)) ?? image
                        updatedContent.image = resizedImage
                        cell.contentConfiguration = updatedContent
                    }
                } else {
                    DispatchQueue.main.async {
                        var fallbackContent = cell.defaultContentConfiguration()
                        fallbackContent.text = movie.title
                        fallbackContent.secondaryText = movie.year
                        fallbackContent.image = UIImage(systemName: "film")
                        cell.contentConfiguration = fallbackContent
                    }
                }
            }.resume()
        } else {
            // 如果 poster 為 nil 或空字串，直接使用預設圖片
            var fallbackContent = cell.defaultContentConfiguration()
            fallbackContent.text = movie.title
            fallbackContent.secondaryText = movie.year
            fallbackContent.image = UIImage(systemName: "film")
            cell.contentConfiguration = fallbackContent
        }
        
        return cell
    }
}

extension MoviesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setSearchText(searchText)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

struct MoviesViewControllerRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = MoviesViewController
    
    func updateUIViewController(_ uiViewController: MoviesViewController, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> MoviesViewController {
        MoviesViewController(viewModel: MovieListViewModel(httpClient: HTTPClient()))
    }
}

#Preview {
    MoviesViewControllerRepresentable()
}
