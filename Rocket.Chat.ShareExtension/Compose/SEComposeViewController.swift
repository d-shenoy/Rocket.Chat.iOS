//
//  SEComposeViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SEComposeViewController: SEViewController {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(SEComposeTextCell.self)
            collectionView.register(SEComposeFileCell.self)

            collectionView.delegate = self
            collectionView.dataSource = self

            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0.0
            layout.minimumInteritemSpacing = 0.0
            collectionView.collectionViewLayout = layout

            collectionView.isPagingEnabled = true
        }
    }

    @IBOutlet weak var pageControl: UIPageControl!

    var viewModel = SEComposeViewModel(cells: []) {
        didSet {
            pageControl.numberOfPages = viewModel.cells.count
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func stateUpdated(_ state: SEState) {
        viewModel = SEComposeViewModel(state: state)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
    }
}

// MARK: UICollectionViewDataSource

extension SEComposeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        let cellModel = viewModel.cellForItemAt(indexPath)

        if let cellModel = cellModel as? SEComposeTextCellModel {
            let textCell = collectionView.dequeue(SEComposeTextCell.self, forIndexPath: indexPath)
            textCell.cellModel = cellModel
            cell = textCell
        } else if let cellModel = cellModel as? SEComposeFileCellModel {
            let fileCell = collectionView.dequeue(SEComposeFileCell.self, forIndexPath: indexPath)
            fileCell.cellModel = cellModel
            cell = fileCell
        } else {
            return UICollectionViewCell()
        }

        return cell
    }
}

// MARK: UICollectionViewFlowLayout

extension SEComposeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
}