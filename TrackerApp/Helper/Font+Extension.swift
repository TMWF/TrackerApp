import UIKit

extension UIFont {
    class func mediumSystemFont(ofSize pointSize: CGFloat) -> UIFont {
        return self.systemFont(ofSize: pointSize, weight: .medium)
    }
}
