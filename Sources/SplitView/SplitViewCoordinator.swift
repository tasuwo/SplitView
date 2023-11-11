//
//  Copyright ©︎ 2023 Tasuku Tozawa. All rights reserved.
//

import SwiftUI

public final class SplitViewCoordinator<Content, Item: SidebarItem> where Content: View {
    let parent: SplitView<Content, Item>

    init(_ parent: SplitView<Content, Item>) {
        self.parent = parent
    }

    func didSelect(_ item: Item) {
        parent.selection = item
    }
}
