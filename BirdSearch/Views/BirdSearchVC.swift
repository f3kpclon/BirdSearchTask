import UIKit

class BirdSearchVC: UIViewController {
    var birdListViewModel : BirdListViewModel?
    var collectionView : UICollectionView!
    var dataSource : UICollectionViewDiffableDataSource<Constants.Section,BirdsListModel>?
    var filteredBirds : [BirdsListModel] = []
    var birds : [BirdsListModel] = []
    var isSearching = false
    var isLoading = false
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    init(birdListViewModel: BirdListViewModel) {
        self.birdListViewModel = birdListViewModel
        super.init(nibName: nil, bundle: nil)
        addActivityindicator()
        getListOfBirds()
        configSearchController()
        configCollection()
        configDataSource()
        birdListViewModel.connectCallback { [weak self] state in
            self?.stateManager(state: state)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func getListOfBirds()  {
        Task {
            await birdListViewModel?.getBirds()
        }
    }
    
    func stateManager(state: BirdsListViewModelState)  {
        switch state {
        case .loaded(model: let model):
            activityIndicator.stopAnimating()
            updateDataUI(birdModel: model)
        case .loading:
            activityIndicator.startAnimating()
        case .loadedError(error: let error):
            print(error.rawValue)
        }
    }
    func updateDataUI(birdModel : [BirdsListModel])  {
        self.birds.append(contentsOf: birdModel)
        updateDataSource(on: self.birds)
    }
    func refreshView()  {
        birds.removeAll()
        filteredBirds.removeAll()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        getListOfBirds()
    }
}

///UIFunctions
private extension BirdSearchVC {
    
    func addActivityindicator()  {
        view.addSubViews(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    func configCollection()  {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UIHelper.createSingleColumnFlowLayout(in: view))
        view.addSubViews(collectionView)
        view.sendSubviewToBack(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(BirdCell.self, forCellWithReuseIdentifier: BirdCell.reuseId)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    func configSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Buscar pajaritos"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
    }
    func updateDataSource(on birds: [BirdsListModel])  {
        var snapshot = NSDiffableDataSourceSnapshot<Constants.Section,BirdsListModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(birds, toSection: .main)
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
        
    }
    func configDataSource()  {
        dataSource = UICollectionViewDiffableDataSource<Constants.Section,BirdsListModel>(collectionView: collectionView, cellProvider: {(collectionView, indexPath, bird) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BirdCell.reuseId, for: indexPath) as? BirdCell
            guard let strongCell = cell else { return UICollectionViewCell() }
            strongCell.setBirdCell(birdModel: bird)
            return strongCell
        })
    }
    
}

extension BirdSearchVC : UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text?.lowercased(), !filter.isEmpty else {
            filteredBirds.removeAll()
            updateDataSource(on: birds)
            isSearching = false
            return
        }
        isSearching = true
        filteredBirds = birds.filter{ birdModel -> Bool in
            return birdModel.birdSpanishName.lowercased().contains(filter)
        }
        guard filteredBirds.count != 0 else {
            self.showAlertOnMainThread(title: "OOPS!!!", message: "No bird named \(filter) was found, try again")
            self.dataSource?.refresh(completion: { [weak self] in
                self?.refreshView()
            })
            return
        }
        updateDataSource(on: filteredBirds)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateDataSource(on: birds)
    }
}
extension BirdSearchVC : UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY         = scrollView.contentOffset.y
        let contentHeight   = scrollView.contentSize.height
        let height          = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            dataSource?.refresh(completion: { [weak self] in
                self?.refreshView()
            })
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? filteredBirds : birds
        let bird = activeArray[indexPath.item]
        let viewModel = BirdZoomViewModel()
        let birdZoomVC = ZoomBirdVC(birdZoomViewModel: viewModel, birdModel: bird)
        birdZoomVC.modalPresentationStyle = .popover
        present(birdZoomVC, animated: true)
    }
    
}
