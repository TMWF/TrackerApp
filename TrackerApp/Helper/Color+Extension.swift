import UIKit

extension UIColor {
    static var backgroundColor: UIColor { UIColor(named: "backgroundColor") ?? UIColor.red }
    static let gradientColour1 = UIColor(named: "gradientColor1") ?? UIColor.red
    static let gradientColour2 = UIColor(named: "gradientColor2") ?? UIColor.green
    static let gradientColour3 = UIColor(named: "gradientColor3") ?? UIColor.blue
    static let datePickerColor = UIColor(named: "datePickerColor") ?? UIColor.gray
    static let datePickerTintColor = UIColor(named: "datePickerTintColor") ?? UIColor.black
    static let searchTextFieldColor = UIColor(named: "searchTextFieldColor") ?? UIColor.gray
    static var findColor: UIColor { UIColor(named: "findColor") ?? UIColor.gray }
    static var YPGray: UIColor { UIColor(named: "ypGray") ?? UIColor.gray }
    static var YPRed: UIColor { UIColor(named: "ypRed") ?? UIColor.red }
    static var YPBlack: UIColor { UIColor(named: "ypBlack") ?? UIColor.black }
    static var YPWhite: UIColor { UIColor(named: "ypWhite") ?? UIColor.white }
    static var lightGray: UIColor { UIColor(named: "lightGray") ?? UIColor.gray }
    static var YPBlue: UIColor { UIColor(named: "ypBlue") ?? UIColor.blue }
    static var colour1: UIColor { UIColor(named: "Color1") ?? UIColor.red }
    static var colour2: UIColor { UIColor(named: "Color2") ?? UIColor.red }
    static var colour3: UIColor { UIColor(named: "Color3") ?? UIColor.red }
    static var colour4: UIColor { UIColor(named: "Color4") ?? UIColor.red }
    static var colour5: UIColor { UIColor(named: "Color5") ?? UIColor.red }
    static var colour6: UIColor { UIColor(named: "Color6") ?? UIColor.red }
    static var colour7: UIColor { UIColor(named: "Color7") ?? UIColor.red }
    static var colour8: UIColor { UIColor(named: "Color8") ?? UIColor.red }
    static var colour9: UIColor { UIColor(named: "Color9") ?? UIColor.red }
    static var colour10: UIColor { UIColor(named: "Color10") ?? UIColor.red }
    static var colour11: UIColor { UIColor(named: "Color11") ?? UIColor.red }
    static var colour12: UIColor { UIColor(named: "Color12") ?? UIColor.red }
    static var colour13: UIColor { UIColor(named: "Color13") ?? UIColor.red }
    static var colour14: UIColor { UIColor(named: "Color14") ?? UIColor.red }
    static var colour15: UIColor { UIColor(named: "Color15") ?? UIColor.red }
    static var colour16: UIColor { UIColor(named: "Color16") ?? UIColor.red }
    static var colour17: UIColor { UIColor(named: "Color17") ?? UIColor.red }
    static var colour18: UIColor { UIColor(named: "Color18") ?? UIColor.red }
    static var switchColor = UIColor(named: "switchColor") ?? UIColor.blue
    
    var hexString: String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        return String.init(
            format: "%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }
}
