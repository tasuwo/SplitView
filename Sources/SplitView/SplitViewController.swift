//
//  Copyright ©︎ 2023 Tasuku Tozawa. All rights reserved.
//

import SwiftUI
import UIKit

public final class SplitViewController<Content, Item: SidebarItem>: UISplitViewController where Content: View {
    private let content: UIHostingController<Content>
    private let sideBarController: SidebarViewController<Item>
    private var task: Task<Void, Never>?

    var coordinator: SplitViewCoordinator<Content, Item>?

    init(title: String, initialItem: Item, content: UIHostingController<Content>) {
        self.content = content
        self.sideBarController = .init(title: title, initialItem: initialItem)
        super.init(style: .doubleColumn)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        task?.cancel()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        configureViewHierarchy()

        task = Task { [sideBarController, weak self] in
            for await item in sideBarController.items {
                self?.coordinator?.didSelect(item)
            }
        }
    }
}

extension SplitViewController {
    func replace(_ content: Content) {
        self.content.rootView = content
        // HACK: rootView切り替え後に Sidebar の開閉ボタンが機能しなくなってしまう
        //       Base ViewController を用意すると NavigationBar が二重に表示されてしまった
        //       Secondary ViewController 自体を切り替えるとうまく View が表示されなかった
        //       強制的に再描画をかけると開閉ボタンが残るようだったので、この対応とする
        self.content.view.layoutIfNeeded()
    }

    func select(_ item: Item) {
        self.sideBarController.select(item)
    }
}

extension SplitViewController {
    private func configureViewHierarchy() {
        setViewController(sideBarController, for: .primary)
        setViewController(content, for: .secondary)
    }
}
