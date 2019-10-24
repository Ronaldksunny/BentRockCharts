//
//  DonutChartView.swift

import UIKit

public struct DonutChartSettings {
    public var showLegends = true
    public var colorsArray:[UIColor] = []
    public init() {}
}


public class DonutChartView: ChartView {
    
    struct Constants {
        static let legendBoxSize: CGFloat = 20.0
        static let legendLabelFontSize: CGFloat = 10
    }
    
    private var chartData: ChartData?
    private let chartSettings: DonutChartSettings
    private var colorsArray: [UIColor]
    
    public init?(json: Data?, settings: DonutChartSettings = DonutChartSettings()) {
        
        guard let jsonData = json, let chartData = ChartData.validateAndCreateChartData(jsonData) else { assertionFailure("Donut chart date is not in correct format"); return nil }
        self.chartData = chartData
        self.chartSettings = settings
        self.colorsArray = settings.colorsArray
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.colorsArray = []
        self.chartSettings = DonutChartSettings()
        super.init(coder: aDecoder)
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        renderBarChart()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
       // renderBarChart()
    }
    
    private func cleanAllSubLayers() {
        layer.sublayers?.forEach({ layer in
            layer.removeFromSuperlayer()
        })
    }
    
    private func renderBarChart() {
        cleanAllSubLayers()
        renderPaths()
        showLegends()
    }
    
    private func segmentColor(for color: UIColor, index: Int) -> UIColor {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        var newBrightness = brightness + CGFloat(index) * 0.05
        if newBrightness > 1.0 {
            newBrightness = brightness - CGFloat(index) * 0.05
        }
        return UIColor(hue: hue, saturation: saturation, brightness: max(newBrightness, 0.0), alpha: alpha)
    }
    
    private func renderPaths() {
        
        func colorForPath(_ index: Int) -> UIColor {
            if let color = colorsArray[safe: index] {
                return color
            } else {
                let pathColor = UIColor.random()
                self.colorsArray.append(pathColor)
                return pathColor
            }
        }
        
        guard let data = chartData?.data, !data.isEmpty  else { assertionFailure("data can not be empty"); return }
        
        let width = frame.width
        let height = frame.height
        
        let heightMargin = height * 0.05
        leftMargin = 0.0
        topMargin = heightMargin
        
        let renderAreaWidth = min(width - leftMargin*2, height - topMargin*2)
        let totalRadius = renderAreaWidth/2
        let legendRadiusFactor = totalRadius/CGFloat(data.count+1)
        let arcCenter = CGPoint(x: width/2, y: height/2)
        
        var legendIndex = 0
        var startAngle: CGFloat = 0
        data.forEach { legend in
            var sum = 0.0
            legend.vertical.forEach({ value in
                if case .double(let doubleValue) = value {
                    sum = sum + doubleValue
                }
            })
            guard sum != 0.0 else { return }
            let pathColor: UIColor = colorForPath(legendIndex)
            let drawRadius = legendRadiusFactor+legendRadiusFactor * CGFloat(legendIndex)
            startAngle = startAngle + 10*CGFloat.pi/180
            legendIndex = legendIndex + 1

            for (index, value) in legend.vertical.enumerated() {
                guard let value = Double(value.stringValue) else { return }
                let segmentColor = self.segmentColor(for: pathColor, index: index)
                let endAngle = startAngle + CGFloat(Double(2*CGFloat.pi) * value/sum)
                let radius = drawRadius
                let path = UIBezierPath.init(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                let pathLayer = layerFromPath(path: path, color: segmentColor.cgColor)
                pathLayer.lineWidth = legendRadiusFactor
                self.layer.addSublayer(pathLayer)
                startAngle = endAngle
               
                let animation = CABasicAnimation(keyPath: "lineWidth")
                animation.fromValue = 0
                animation.duration = 2
                pathLayer.add(animation, forKey: "pathAnimation")
            }
        }
    }
    
    private func showLegends() {
        guard let data = chartData?.data, !colorsArray.isEmpty else { assertionFailure("colors array can not be empty. Consider rendering last"); return }
        guard chartSettings.showLegends else { return }
        let allowedLength = frame.width * 0.9
        let startXPoint = frame.width - allowedLength
        let startYPoint = frame.height - Constants.legendBoxSize/2 - 10
        let legendSpacing = allowedLength/CGFloat(colorsArray.count)
        let labelWidth = legendSpacing - Constants.legendBoxSize/2 - 5
        
        for (index, color) in colorsArray.enumerated() {
            if let title = data[safe: index]?.title {
                let xPoint = startXPoint + legendSpacing*CGFloat(index)
                let path = legendPath
                path.move(to: CGPoint(x: xPoint, y: startYPoint))
                path.addLine(to: CGPoint(x: xPoint+Constants.legendBoxSize/2, y: startYPoint))
                let pathLayer = layerFromPath(path: path, color: color.cgColor)
                pathLayer.fillColor = color.cgColor
                pathLayer.lineWidth = Constants.legendBoxSize/2
                self.layer.addSublayer(pathLayer)
                
                let labelLayer = CATextLayer()
                labelLayer.frame = CGRect(x: xPoint + Constants.legendBoxSize/2 + 5, y: startYPoint-Constants.legendLabelFontSize/2, width: labelWidth, height: Constants.legendLabelFontSize+5)
                labelLayer.foregroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).cgColor
                labelLayer.fontSize = Constants.legendLabelFontSize
                labelLayer.string = title
                self.layer.addSublayer(labelLayer)
            }
        }
        
    }

}
