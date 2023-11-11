//
//  Copyright ©︎ 2023 Tasuku Tozawa. All rights reserved.
//

import UIKit

public protocol SidebarItem: Hashable {
    static var order: [Self] { get }

    var text: String { get }
    var image: UIImage { get }
}
