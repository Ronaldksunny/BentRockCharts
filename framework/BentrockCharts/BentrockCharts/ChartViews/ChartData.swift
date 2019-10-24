//
//  ChartData.swift

import Foundation

public struct ChartData: Decodable {
    let axesSettings: AxesSetting?
    let data: [Legend]
    
    static func validateAndCreateChartData(_ json: Data) -> ChartData? {
        
        let decoder = JSONDecoder()
        do {
            let chartData = try decoder.decode(ChartData.self, from: json)
            
            guard chartData.data.count > 0 else { print("No data for rendering chart"); return nil }
            
            guard let horizontalCount = chartData.data.first?.horizontal.count,
                let verticalCount = chartData.data.first?.vertical.count else { print("No data for chart"); return nil }
            guard horizontalCount == verticalCount else {
                print("Horizontal and vertical legends count should be equal"); return nil
            }
            guard chartData.data.allSatisfy({ $0.horizontal.count == horizontalCount && $0.vertical.count == verticalCount }) else {
                print("Horizontal and vertical legends count should be equal"); return nil
            }
            guard chartData.data.allSatisfy({ $0.vertical.allSatisfy({ value in
                if case ChartData.ChartDataType.double(_) = value {
                    return true
                } else {
                    return false
                }})})  else {
                    print("Horizontal data should be numbers"); return nil
            }
            return chartData
            
        } catch {
            print(error)
        }
        
        return nil
    }
    
    struct AxesSetting: Decodable {
        let horizontal: AxisSetting?
        let vertical: AxisSetting?
    }
    
    struct AxisSetting: Decodable {
        let title: String?
    }
    
    struct Legend: Decodable {
        let title: String?
        let horizontal: [ChartDataType]
        let vertical: [ChartDataType]
    }
    
    enum ChartDataType: Decodable, Comparable {
        case string(String)
        case double(Double)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let doubleValue = try? container.decode(Double.self) { // Try for Double
                self = .double(doubleValue)
            } else { // if the decoder decode the data to String try to covert the data to double or Int first
                do {
                    let stringValue = try container.decode(String.self)
                    if let doubleValue = Double(stringValue) {
                        self = .double(doubleValue)
                    } else {
                        self = .string(stringValue)
                    }
                }
            }
        }
        
        var stringValue: String {
            switch self {
            case .string(let value):
                return value
            case .double(let value):
                return String(value)
            }
        }
        
        //MARK: - Equatabe and comparable protocols
        
        static func < (lhs: ChartDataType, rhs: ChartDataType) -> Bool {
            switch (lhs, rhs) {
            case (.string(let leftValue), .string(let rightValue)): return leftValue < rightValue
            case (.double(let leftValue), .double(let rightValue)): return leftValue < rightValue
            default: return false
            }
        }
        
        static func ==(lhs: ChartDataType, rhs: ChartDataType) -> Bool {
            switch (lhs, rhs) {
            case (.string(let leftValue), .string(let rightValue)): return leftValue == rightValue
            case (.double(let leftValue), .double(let rightValue)): return leftValue == rightValue
            default: return false
            }
        }
        
        static func > (lhs: ChartDataType, rhs: ChartDataType) -> Bool {
            switch (lhs, rhs) {
            case (.string(let leftValue), .string(let rightValue)): return leftValue > rightValue
            case (.double(let leftValue), .double(let rightValue)): return leftValue > rightValue
            default: return false
            }
        }
        
    }
}

