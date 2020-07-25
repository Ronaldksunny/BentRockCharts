//
//  Chart.swift

import UIKit

public class ChartView: UIView {
    var xAxisLength: CGFloat = 0
    var yAxisLength: CGFloat = 0
    var leftMargin: CGFloat = 0
    var topMargin: CGFloat = 0
    
    var axisPath: UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = 2.0
        return path
    }
    
    var legendPath: UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = 1.0
        return path
    }
    
    var gridPath: UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = 1.0
        return path
    }
    
    func layerFromPath(path: UIBezierPath, color: CGColor, isGrid: Bool = false) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        if isGrid {
            shapeLayer.lineDashPattern = [7, 4]
        }
        shapeLayer.strokeColor = color
        return shapeLayer
    }

}


internal extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

internal extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

internal extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    //  from: http://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings
    subscript (safeIndex index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

