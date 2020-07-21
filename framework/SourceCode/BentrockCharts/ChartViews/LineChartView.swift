//
//  LineChartView.swift

import UIKit

public struct LineChartSettings {
    public var showGrid = true
    public var showLegends = true
    public var showAxisLabels = true
    public var showAxisTitles = false
    public var colorsArray:[UIColor] = []
    public init() {}
}

public class LineChartView: ChartView {
    
    struct Constants {
        static let numberOfYGrids = 10
        static let axisLabelFontSize: CGFloat = 10
        static let legendBoxSize: CGFloat = 20.0
        static let legendLabelFontSize: CGFloat = 10
        static let axisTitleFontSize: CGFloat = 10
    }
    
    private var chartData: ChartData?
    private let chartSettings: LineChartSettings
    private var colorsArray: [UIColor]
    private var xDivisorLenght: CGFloat = 0
    private var yDivisorLenght: CGFloat = 0
    private var yDivisorValue: CGFloat = 0
    private var maxYValue: CGFloat = 0
    
    public init?(json: Data?, settings: LineChartSettings = LineChartSettings()) {

        guard let jsonData = json, let chartData = ChartData.validateAndCreateChartData(jsonData) else { assertionFailure("Line chart date is not in correct format"); return nil }
        self.chartData = chartData
        self.chartSettings = settings
        self.colorsArray = settings.colorsArray
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.colorsArray = []
        self.chartSettings = LineChartSettings()
        super.init(coder: aDecoder)
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        renderLineChart()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()

        renderLineChart()
    }
    
    fileprivate lazy var maximumValueOfYData: ChartData.ChartDataType? = {
        guard let data = chartData?.data, var maxVal = data.first?.vertical.max() else { return nil }
        data.forEach { legend in
            guard let legendMax = legend.vertical.max() else { return }
            maxVal = max(legendMax, maxVal)
        }
        return maxVal
    }()
    
    private func cleanAllSubLayers() {
        layer.sublayers?.forEach({ layer in
            layer.removeFromSuperlayer()
        })
    }
    
    private func renderLineChart() {
        cleanAllSubLayers()
        renderAxes()
        renderGridAndAxisLabels()
        renderPaths()
        showAxisTitles()
        showLegends()
    }
    
    private func showAxisTitles() {
        
        guard let axesSettings = chartData?.axesSettings, chartSettings.showAxisTitles else { return }
        let labelLayer = CATextLayer()
        labelLayer.frame = CGRect(x: leftMargin, y: topMargin+yAxisLength+Constants.axisLabelFontSize+5, width: xAxisLength, height: Constants.axisTitleFontSize+5)
        labelLayer.foregroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).cgColor
        labelLayer.fontSize = Constants.axisTitleFontSize
        labelLayer.string = axesSettings.horizontal?.title
        labelLayer.alignmentMode = .center
        self.layer.addSublayer(labelLayer)
    }
    
    private func showLegends() {
        guard let data = chartData?.data, !colorsArray.isEmpty else { assertionFailure("colors array can not be empty. Consider rendering last"); return }
        guard chartSettings.showLegends else { return }
        
        let allowedLength = frame.width * 0.9
        let startXPoint = frame.width - allowedLength
        let startYPoint = topMargin + yAxisLength + Constants.axisLabelFontSize + Constants.axisTitleFontSize + Constants.legendBoxSize/2 + 5
        let legendSpacing = allowedLength/CGFloat(colorsArray.count)
        let labelWidth = legendSpacing - Constants.legendBoxSize/2 - 5
        
        for (index, color) in colorsArray.enumerated() {
            if let title = data[safe: index]?.title {
                let xPoint = startXPoint + legendSpacing*CGFloat(index)
                let path = legendPath
                path.lineWidth = Constants.legendBoxSize/2
                path.move(to: CGPoint(x: xPoint, y: startYPoint))
                path.addLine(to: CGPoint(x: xPoint+Constants.legendBoxSize/2, y: startYPoint))
                let pathLayer = layerFromPath(path: path, color: color.cgColor)
                pathLayer.fillColor = color.cgColor
                pathLayer.lineWidth = Constants.legendBoxSize/2
                self.layer.addSublayer(pathLayer)
                
                let labelLayer = CATextLayer()
                labelLayer.frame = CGRect(x: xPoint + Constants.legendBoxSize/2 + 5, y: startYPoint-Constants.legendLabelFontSize/2, width: labelWidth, height: Constants.legendLabelFontSize+10)
                labelLayer.foregroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).cgColor
                labelLayer.fontSize = Constants.legendLabelFontSize
                labelLayer.string = title
                self.layer.addSublayer(labelLayer)
                
            }
        }
        
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
        
        guard let data = chartData?.data, let maxYData = maximumValueOfYData?.stringValue, let maximumValueOfYData = Double(maxYData)  else { return }
        
        let yMaxDiv = round(maximumValueOfYData/Double(Constants.numberOfYGrids))
        yDivisorValue = CGFloat(yMaxDiv)
        maxYValue = CGFloat(yMaxDiv * Double(Constants.numberOfYGrids))
        let yValueFactor = CGFloat(Double(yAxisLength)/Double(maxYValue))
        var legendIndex = 0
        data.forEach { legend in
            let pathColor: UIColor = colorForPath(legendIndex)
            legendIndex = legendIndex + 1
            var yPos = topMargin + yAxisLength
            var xPos = leftMargin
            let path = legendPath
            path.move(to: CGPoint(x: xPos, y: yPos))
            for (index, value) in legend.vertical.enumerated() {
                
                guard let value = Double(value.stringValue) else { return }
                
                let toYPos = topMargin + yAxisLength - (yValueFactor * CGFloat(value))
                let toXPos = leftMargin + xDivisorLenght * CGFloat(index+1)

                path.addLine(to: CGPoint(x: toXPos, y: toYPos))
                let pathLayer = layerFromPath(path: path, color: pathColor.cgColor)
                self.layer.addSublayer(pathLayer)

                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = 0
                animation.duration = 2
                pathLayer.add(animation, forKey: "pathAnimation")
                
                yPos = toYPos
                xPos = toXPos
            }
        }
    }
    
    private func renderGridAndAxisLabels() {
        guard let legend = chartData?.data.first else { return }
        
        let xLenghtDivisor: Double = Double(xAxisLength)/Double(legend.horizontal.count)
        let yLenghtDivisor: Double = Double(yAxisLength)/Double(Constants.numberOfYGrids)
        xDivisorLenght = CGFloat(xLenghtDivisor)
        yDivisorLenght = CGFloat(yLenghtDivisor)
        
        for i in 1...legend.horizontal.count {
            
            let xPos = CGFloat(Double(leftMargin) + xLenghtDivisor * Double(i))
            if chartSettings.showGrid {
                let x_grid = gridPath
                x_grid.move(to: CGPoint(x: xPos, y: topMargin))
                x_grid.addLine(to: CGPoint(x: xPos, y: topMargin + yAxisLength))
                self.layer.addSublayer(layerFromPath(path: x_grid, color: #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1).cgColor, isGrid: true))
            }
            // Add horizontal axis labels
            // shows the labels for the first legend
            if chartSettings.showAxisLabels {
                let labelLayer = CATextLayer()
                labelLayer.frame = CGRect(x: xPos, y: topMargin+yAxisLength, width: xDivisorLenght, height: Constants.axisLabelFontSize+5)
                labelLayer.foregroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).cgColor
                labelLayer.fontSize = Constants.axisLabelFontSize
                labelLayer.string = legend.horizontal[i-1].stringValue
                self.layer.addSublayer(labelLayer)
            }
        }
        
        for i in 0..<Constants.numberOfYGrids {
            
            let yPos = CGFloat(Double(topMargin) + yLenghtDivisor * Double(i))
            
            if chartSettings.showGrid {
                
                let y_grid = gridPath
                y_grid.move(to: CGPoint(x: leftMargin, y: yPos))
                y_grid.addLine(to: CGPoint(x: leftMargin + xAxisLength, y: yPos))
                self.layer.addSublayer(layerFromPath(path: y_grid, color: #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1).cgColor, isGrid: true))
            }
            
            if chartSettings.showAxisLabels {
                let labelValue = Double(yDivisorValue) * Double(Constants.numberOfYGrids - i)
                let labelLayer = CATextLayer()
                labelLayer.frame = CGRect(x: leftMargin-xDivisorLenght-5, y: yPos, width: xDivisorLenght, height: Constants.axisLabelFontSize+5)
                labelLayer.foregroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).cgColor
                labelLayer.fontSize = Constants.axisLabelFontSize
                labelLayer.alignmentMode = .right
                labelLayer.string = String(labelValue)
                self.layer.addSublayer(labelLayer)
            }
        }

    }
    
    private func renderAxes() {
        let width = frame.width
        let height = frame.height
        
        let widthMargin = width * 0.1
        let heightMargin = height * 0.2
        leftMargin = widthMargin
        topMargin = heightMargin
        
        let lenght_axis_x = width - widthMargin * 2
        let lenght_axis_y = height - heightMargin * 2
        xAxisLength = lenght_axis_x
        yAxisLength = lenght_axis_y
        
        
        let y_axis_path = axisPath
        y_axis_path.move(to: CGPoint(x: widthMargin, y: heightMargin))
        y_axis_path.addLine(to: CGPoint(x: widthMargin, y: heightMargin + lenght_axis_y))
        self.layer.addSublayer(layerFromPath(path: y_axis_path, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor))
        
        let x_axis_path = axisPath
        x_axis_path.move(to: CGPoint(x: widthMargin, y: heightMargin + lenght_axis_y))
        x_axis_path.addLine(to: CGPoint(x: widthMargin + lenght_axis_x, y: heightMargin + lenght_axis_y))
        self.layer.addSublayer(layerFromPath(path: x_axis_path, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor))
    }
    
    

}
