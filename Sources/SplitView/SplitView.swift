//
//  Copyright ©︎ 2023 Tasuku Tozawa. All rights reserved.
//

import SwiftUI

public struct SplitView<Content, Item: SidebarItem> where Content: View {
    private let title: String

    @Binding var selection: Item

    @ViewBuilder
    let content: () -> Content

    public init(title: String, selection: Binding<Item>, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self._selection = selection
        self.content = content
    }
}

extension SplitView: UIViewControllerRepresentable {
    public func makeCoordinator() -> SplitViewCoordinator<Content, Item> {
        return SplitViewCoordinator(self)
    }

    public func makeUIViewController(context: Context) -> SplitViewController<Content, Item> {
        let viewController = SplitViewController<Content, Item>(
            title: title, initialItem: selection, content: UIHostingController(rootView: content()))
        viewController.coordinator = context.coordinator
        return viewController
    }

    public func updateUIViewController(_ uiViewController: SplitViewController<Content, Item>, context: Context) {
        uiViewController.replace(content())
    }
}

struct SplitView_PreviewProvider: PreviewProvider {
    enum Item: CaseIterable, SidebarItem {
        static var order: [SplitView_PreviewProvider.Item] = Self.allCases

        case one
        case two
        case three

        var text: String {
            switch self {
            case .one: "One"
            case .two: "Two"
            case .three: "Three"
            }
        }

        var image: UIImage {
            switch self {
            case .one: UIImage(systemName: "gearshape")!
            case .two: UIImage(systemName: "gearshape")!
            case .three: UIImage(systemName: "gearshape")!
            }
        }
    }

    struct Preview: View {
        @State private var selection: Item = .one

        var body: some View {
            SplitView(title: "MyApp", selection: $selection) {
                switch selection {
                case .one:
                    Color.red
                        .ignoresSafeArea()

                case .two:
                    Color.orange
                        .ignoresSafeArea()

                case .three:
                    Color.yellow
                        .ignoresSafeArea()
                }
            }
            .ignoresSafeArea()
        }
    }

    static var previews: some View {
        Preview()
    }
}
