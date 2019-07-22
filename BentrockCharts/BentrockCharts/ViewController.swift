//
//  ViewController.swift
//  BentrockCharts

import UIKit

class ViewController: UIViewController {

    @IBOutlet var lineChartContainer: UIView!
    @IBOutlet var barChartContainer: UIView!
    @IBOutlet var donutChartContainer: UIView!
    
    override func loadView() {
        super.loadView()
        addLineChartView()
        addBarChartView()
        addDonutChartView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func addLineChartView() {
        guard let jsonData = dataFromFile("ChartData") else { assertionFailure("data not available"); return }
        guard let lineChartView = LineChartView(json: jsonData) else { return }
        addConstrainedSubview(containerView: lineChartContainer, chartView: lineChartView)
    }
    
    private func addBarChartView() {
        guard let jsonData = dataFromFile("ChartData") else { assertionFailure("data not available"); return }
        guard let barChartView = BarChartView(json: jsonData) else { return }
        addConstrainedSubview(containerView: barChartContainer, chartView: barChartView)
    }
    
    private func addDonutChartView() {
        guard let jsonData = dataFromFile("ChartData") else { assertionFailure("data not available"); return }
        guard let donutChartView = DonutChartView(json: jsonData) else { return }
        addConstrainedSubview(containerView: donutChartContainer, chartView: donutChartView)
    }
    
    private func addConstrainedSubview(containerView: UIView, chartView: ChartView) {
        containerView.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            chartView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            chartView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            chartView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            ])
    }
    
    private func dataFromFile(_ fileName: String) -> Data? {
        var jsonData: Data? = nil
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            } catch {
            }
        }
        return jsonData
    }


}

