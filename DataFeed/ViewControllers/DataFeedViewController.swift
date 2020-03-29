//
//  DataFeedViewController.swift
//  DataFeed
//
//  Created by Daniel Bowden on 28/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import UIKit

class DataFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50.0
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        return tableView
    }()
    private let activityIndicator = UIActivityIndicatorView(style: .gray)
    private let refreshControl = UIRefreshControl()
    private lazy var manager = DataFeedManager()
    
    private var viewModel: TopicViewModel? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: ItemTableViewCell.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .blue
        refreshControl.addTarget(self, action: #selector(loadDataFeed), for: .valueChanged)
        activityIndicator.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
        loadDataFeed()
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfItems ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel?.item(at: indexPath.row),
            let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.cellIdentifier, for: indexPath) as? ItemTableViewCell else {
                return UITableViewCell()
        }
        
        let itemViewModel = ItemViewModel(with: item)
        cell.configure(viewModel: itemViewModel)
        
        return cell
    }
    
    // MARK: - Private methods
    
    private func updateUI() {
        guard let viewModel = viewModel else {
            title = "Data Feed"
            return
        }
        
        title = viewModel.navigationTitle
        tableView.reloadSections(IndexSet(integer: 0), with: .top)
    }
    
    @objc private func loadDataFeed() {
        activityIndicator.startAnimating()
        DataFeedManager().retrieveDataFeed { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                switch result {
                case .success(let topic):
                    print("got topic: \(topic)")
                    self.viewModel = TopicViewModel(with: topic)
                case .failure(let error):
                    print("got error: \(error.localizedDescription)")
                    //TODO: Show error state
                }
            }
        }
    }
}
