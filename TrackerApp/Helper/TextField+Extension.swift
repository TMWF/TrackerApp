import UIKit

extension UITextField {
    func indent(by:CGFloat) {
        self.leftView = UIView(frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: by, height: self.frame.height))
        self.leftViewMode = .always
    }
}
