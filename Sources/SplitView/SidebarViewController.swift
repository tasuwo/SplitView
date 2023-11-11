//
//  Copyright ©︎ 2023 Tasuku Tozawa. All rights reserved.
//

import Combine
import UIKit

final class SidebarViewController<Item: SidebarItem>: UIViewController, UICollectionViewDelegate {
    class CollectionViewDelegate: NSObject, UICollectionViewDelegate {
        weak var dataSource: UICollectionViewDiffableDataSource<Section, Item>?

        private let onSelect: (Item) -> Void

        init(onSelect: @escaping (Item) -> Void) {
            self.onSelect = onSelect
        }

        func collectionView(
            _ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath
        ) {
            guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
            onSelect(item)
        }
    }

    enum Section: Int { case main }

    private var collectionView: UICollectionView!
    private var collectionViewDelegate: CollectionViewDelegate!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private let currentItem: CurrentValueSubject<Item, Never>

    var items: AsyncStream<Item> {
        AsyncStream { continuation in
            let cancellable =
                currentItem
                .sink { continuation.yield($0) }

            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }

    init(title: String, initialItem: Item) {
        currentItem = .init(initialItem)
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewHierarchy()
        configureDataSource()
    }

    func select(_ item: Item) {
        guard let indexPath = dataSource.indexPath(for: item) else { return }
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }

    private func configureViewHierarchy() {
        navigationItem.title = title
        navigationController?.navigationBar.prefersLargeTitles = true

        collectionView = UICollectionView(
            frame: view.frame, collectionViewLayout: Self.createLayout())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func configureDataSource() {
        dataSource = Self.configureDataSource(collectionView: collectionView)

        collectionViewDelegate = .init(onSelect: { [weak self] item in
            self?.currentItem.send(item)
        })
        collectionViewDelegate.dataSource = dataSource
        collectionView.delegate = collectionViewDelegate

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Item.order)
        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            self.select(self.currentItem.value)
        }
    }

    private static func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, environment -> NSCollectionLayoutSection? in
            let configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            return NSCollectionLayoutSection.list(
                using: configuration, layoutEnvironment: environment)
        }
    }

    private static func configureDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Section, Item> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
            cell, _, item in
            var contentConfiguration = UIListContentConfiguration.sidebarCell()
            contentConfiguration.image = item.image
            contentConfiguration.text = item.text
            cell.contentConfiguration = contentConfiguration
        }

        return .init(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration, for: indexPath, item: item)
        }
    }
}
