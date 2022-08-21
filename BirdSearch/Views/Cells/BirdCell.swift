//
//  BirdCell.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 19-08-22.
//

import UIKit

class BirdCell: UICollectionViewCell {
    static let reuseId = "BirdCell"
    private let usflag : Character = "\u{1F1FA}\u{1F1F8}"
    private let clFlag : Character = "\u{1F1E8}\u{1F1F1}"
    private var birdCellViewModel = BirdCellViewModel()
    private let spanishNameLbl = BirdsViewBuilder.createLabel(color: nil, text: "TESTING", alignment: .left, font: .boldSystemFont(ofSize: 15.0), bgColor: nil)
    private let englishNameLbl = BirdsViewBuilder.createLabel(color: nil, text: "TESTING2", alignment: .left, font: .boldSystemFont(ofSize: 15.0), bgColor: nil)
    private let nameTitleLbl = BirdsViewBuilder.createLabel(color: nil, text: "TESTING3", alignment: .left, font: .italicSystemFont(ofSize: 12.0), bgColor: nil)
    private let lblStack = BirdsViewBuilder.createStackWith(alignment: .leading, axis: .vertical, distribution: .fillProportionally)
    private let imageView = BirdsViewBuilder.createView()
    private let avatarImg = BirdsViewBuilder.createImageWith(image: Constants.Images.imgPlaceholder, contentMode: .scaleAspectFit, clipToBounds: true)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setBirdCell(birdModel: BirdsListModel)  {
        birdCellViewModel.connectCallback { [weak self] state in
            self?.birdCellBindingManager(state: state)
        }
        Task {
            await birdCellViewModel.getCellData(url: birdModel.birdThumb, birdModel: birdModel)
        }
    }
    
    func birdCellBindingManager(state: BirdCellState) {
        switch state {
        case .loaded(let model):
            updateContent(model)
        case .loading:
            break
        case .loadedWithError(_):
            break
        }
    }
    
    func updateContent(_ model: BirdCellModelVM)  {
        nameTitleLbl.text = model.titleName
        spanishNameLbl.text = "\(clFlag)  \(model.spanishName )"
        englishNameLbl.text = "\(usflag)  \(model.englishName )"
        avatarImg.image = model.birdImage
    }
    func setUpView()  {
        self.backgroundColor = .white
        self.layer.borderWidth = 0.5
        imageView.addSubViews(avatarImg)
        lblStack.addStacks(nameTitleLbl,spanishNameLbl,englishNameLbl)
        contentView.addSubViews(imageView, lblStack)
        setConstraints()
    }
    
    func setConstraints()  {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            avatarImg.topAnchor.constraint(equalTo: imageView.topAnchor),
            avatarImg.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            avatarImg.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            avatarImg.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            lblStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            lblStack.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 24.0),
            lblStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            lblStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
