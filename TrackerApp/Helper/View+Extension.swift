import UIKit

extension UIView {

    private static let kLayerNameGradientBorder = "GradientBorderLayer"

    func setGradientBorder(
        width: CGFloat,
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0, y: 0.5),
        endPoint: CGPoint = CGPoint(x: 1, y: 0.5)
    ) {
        let existedBorder = gradientBorderLayer()
        let border = existedBorder ?? CAGradientLayer()
        border.frame = bounds
        border.colors = colors.map { return $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint

        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width

        border.mask = mask

        let exists = existedBorder != nil
        if !exists {
            layer.addSublayer(border)
        }
    }

    func removeGradientBorder() {
        self.gradientBorderLayer()?.removeFromSuperlayer()
    }

    private func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter { return $0.name == UIView.kLayerNameGradientBorder }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }
}
