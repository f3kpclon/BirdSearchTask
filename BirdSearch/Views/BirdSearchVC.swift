import Combine
import UIKit
class BirdSearchVC: UIViewController {
    var birdListViewModel = BirdListViewModel(dataManager: BirdsDataManager())
    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UIHelper.createSingleColumnFlowLayout(in: view))
        return collection
    }()

    var dataSource: UICollectionViewDiffableDataSource<Constants.Section, BirdCellModel>?
    var filteredBirds: [BirdCellModel] = []
    var birds: [BirdCellModel] = []
    var isSearching = false
    var isLoading = false
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    private var cancelBag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubViews(
            activityIndicator,
            collectionView
        )
        configSearchController()
        view.sendSubviewToBack(collectionView)
        collectionView.delegate = self
        collectionView.register(BirdCell.self, forCellWithReuseIdentifier: BirdCell.reuseId)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // activity indicator
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        // collectcionView
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
        birdListViewModel.birds
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.activityIndicator.stopAnimating()
                    print("Stream finished")
                case let .failure(error):
                    print("Stream failed with error: \(error)")
                }
            }, receiveValue: { birds in
                self.updateDataUI(birdModel: birds)

            })
            .store(in: &cancelBag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelBag.removeAll()
    }

    func updateDataUI(birdModel: [BirdCellModel]) {
        birds.append(contentsOf: birdModel)
        birds.sort(by: { $0.uid > $1.uid })
        configDataSource()
        updateDataSource(on: birds)
    }

    func refreshView() {
        filteredBirds.removeAll()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        updateDataSource(on: birds)
    }
}

/// UIFunctions
private extension BirdSearchVC {
    func configSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Buscar pajaritos"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }

    func updateDataSource(on birds: [BirdCellModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Constants.Section, BirdCellModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(birds, toSection: .main)
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }

    func configDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Constants.Section, BirdCellModel>(
            collectionView: collectionView,
            cellProvider: {
                collectionView,
                    indexPath,
                    bird -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BirdCell.reuseId, for: indexPath) as? BirdCell
                guard let strongCell = cell else { return UICollectionViewCell() }
                strongCell.updateContent(bird)
                return strongCell
            }
        )
    }
}

extension BirdSearchVC: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text?.lowercased(), !filter.isEmpty else {
            filteredBirds.removeAll()
            updateDataSource(on: birds)
            isSearching = false
            return
        }
        isSearching = true
        filteredBirds = birds.filter { birdModel -> Bool in
            birdModel.spanishName.lowercased().contains(filter)
        }
        guard filteredBirds.count != 0 else {
            showAlertOnMainThread(title: "OOPS!!!", message: "No bird named \(filter) was found, try again")
            dataSource?.refresh(completion: { [weak self] in
                self?.refreshView()
            })
            return
        }
        updateDataSource(on: filteredBirds)
    }

    func searchBarCancelButtonClicked(_: UISearchBar) {
        isSearching = false
        updateDataSource(on: birds)
    }
}

extension BirdSearchVC: UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            dataSource?.refresh(completion: { [weak self] in
                self?.refreshView()
            })
        }
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? filteredBirds : birds
        let bird = activeArray[indexPath.item]
        let birdZoomVC = ZoomBirdVC(birdModel: bird)
        birdZoomVC.modalPresentationStyle = .popover
        present(birdZoomVC, animated: true)
    }
}
