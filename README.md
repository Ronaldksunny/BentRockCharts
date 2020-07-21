# Bentrock Charts
Bentrock Charts are designed to work with the data provided in `json` format. It uses the same data format for rendering different types of charts, additional customizations can also be applied based on the needs. 

<img src="Docs/IMG_0098.png" width="200">  <img src="Docs/IMG_0099.png" width="200">  <img src="Docs/IMG_0100.png" width="200">  <img src="Docs/IMG_0101.png" width="200"> 

# Requirements
* Xcode 11 and above
* Swift 5

# Supports
* XCFramework
* iPhone and Simulator

## Types of charts available

* Line Chart (Multi legend)
* Bar Chart (Multi legend)
* Donut Chart (Multi legend)

## How to use

Copy the `BentrockCharts.xcframework` to your project and import the module wherever needed. Initialize the view by providing the json and add it as a subView.

```swift
var lineChartView = LineChartView(json: jsonData)
```

This view can be used like a normal `UIView`. The above line of code initializes line chart with default settings. Additional customizations can be done to the charts by providing the `LineChartSettings` object along with the initialization. The chart picks random colors for rendering the legends if no colors are provided in the `colorsArray` of the settign object.

## Customizing charts

Customizations can be done by providing `Settings` Object along with the initialization.

```swift
var lineChartSettings = LineChartSettings()
        lineChartSettings.showGrid = false
        lineChartSettings.showLegends = false
        lineChartSettings.colorsArray = [UIColor.red, .green, .blue]

let lineChartView = LineChartView(json: jsonData, settings: lineChartSettings)
```
## Customizations available

* Line Chart - colors for legends, show grid, show legends, show axis labels, show axis title
* Bar Chart (Multi legend) - colors for legends, show grid, show legends, show axis labels, show axis title
* Donut Chart (Multi legend) - colors for legends,  show legends, every segment automatically select a different gradient of the legent color.
