//
//  ZoomBirdVC.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 20-08-22.
//

import UIKit

class ZoomBirdVC: UIViewController {
    private let scrollView = BirdsViewBuilder.createScrollView()
    private let zoomBirdImage = BirdsViewBuilder.createImageWith(image: Constants.Images.imgPlaceholder, contentMode: .scaleAspectFit, clipToBounds: true)
    private let headerView = BirdsViewBuilder.createView()
    private let headerTitle = BirdsViewBuilder.createLabel(color: .black, text: "TITULO", alignment: .center, font: .boldSystemFont(ofSize: 24.0), bgColor: nil)
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)

    private var birdZoomViewModel: BirdZoomViewModel
    private var birdModel: BirdsListModel
    private var viewContainer = BirdsViewBuilder.createView()

    init(birdZoomViewModel: BirdZoomViewModel, birdModel: BirdsListModel) {
        self.birdModel = birdModel
        self.birdZoomViewModel = birdZoomViewModel
        super.init(nibName: nil, bundle: nil)
        getBirdFullImage()
        birdZoomViewModel.connectCallback { [weak self] state in
            self?.stateManager(state: state)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    deinit {
        print("Vista eliminada: \(self)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUPView()
        setUpScrollView()
        setConstraints()
    }

    func getBirdFullImage() {
        Task {
            await birdZoomViewModel.getBirdZoomData(url: birdModel.birdFull, birdModel: birdModel)
        }
    }

    func stateManager(state: BirdZoomstate) {
        switch state {
        case let .loaded(model: model):
            activityIndicator.stopAnimating()
            zoomBirdImage.image = model.zoomImage
            headerTitle.text = model.title
        case .loading:
            activityIndicator.startAnimating()
        case .loadedWithError(error: _):
            activityIndicator.stopAnimating()
        }
    }

    func addActivityindicator() {
        view.addSubViews(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    func setUPView() {
        headerView.addSubViews(headerTitle)
        view.addSubViews(headerView, scrollView)
        viewContainer.addSubViews(zoomBirdImage)
        scrollView.addSubViews(viewContainer)
    }

    func setUpScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
    }

    func setConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            headerTitle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0),
            headerTitle.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant: 0),

            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            viewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            viewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            viewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            viewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            viewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            zoomBirdImage.topAnchor.constraint(equalTo: viewContainer.topAnchor),

            zoomBirdImage.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor),
            zoomBirdImage.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor),
            zoomBirdImage.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor),
        ])
    }
}

extension ZoomBirdVC: UIScrollViewDelegate {
    func viewForZooming(in _: UIScrollView) -> UIView? {
        return viewContainer
    }
}
