//
//  PlantDetailsViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 3/11/20.
//

import UIKit
import Charts
import TinyConstraints

class PlantDetailsViewController: UIViewController {
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemBlue
        
        
        /// to remove right axis
        chartView.rightAxis.enabled = false
        
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        yAxis.labelPosition = .outsideChart
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        chartView.xAxis.setLabelCount(6, force: false)
        chartView.xAxis.labelTextColor = .white
        chartView.xAxis.axisLineColor = .systemBlue
        
        chartView.animate(xAxisDuration: 1.5)
        
        return chartView
    }()
    
    let yValues: [ChartDataEntry] = [
        ChartDataEntry(x: 0.0, y: 10.0),
        ChartDataEntry(x: 1.0, y: 20.0),
        ChartDataEntry(x: 2.0, y: 10.0),
        ChartDataEntry(x: 3.0, y: 10.0),
        ChartDataEntry(x: 4.0, y: 3.0),
        ChartDataEntry(x: 5.0, y: 1.0),
        ChartDataEntry(x: 6.0, y: 19.0),
        ChartDataEntry(x: 7.0, y: 13.0),
        ChartDataEntry(x: 8.0, y: 14.0),
        ChartDataEntry(x: 9.0, y: 10.0),
        ChartDataEntry(x: 10.0, y: 10.0),
        ChartDataEntry(x: 11.0, y: 20.0),
        ChartDataEntry(x: 12.0, y: 10.0),
        ChartDataEntry(x: 13.0, y: 10.0),
        ChartDataEntry(x: 14.0, y: 20.0),
        ChartDataEntry(x: 15.0, y: 1.0),
        ChartDataEntry(x: 16.0, y: 19.0),
        ChartDataEntry(x: 17.0, y: 13.0),
        ChartDataEntry(x: 18.0, y: 14.0),
        ChartDataEntry(x: 19.0, y: 10.0),
        ChartDataEntry(x: 20.0, y: 10.0),
    ]
    
    func setData() {
        let set1 = LineChartDataSet(entries: yValues, label: "Plants")
        set1.drawCirclesEnabled = false
        
        /// remove the sharp edges
        set1.mode = .cubicBezier
        set1.lineWidth = 3
        set1.setColor(.white)
        set1.fill = Fill(color: .white)
        
        /// if imgage is used better
        set1.fillAlpha = 0.8
        set1.drawFilledEnabled = true
        
        
        /// remove highlight indecator
        set1.drawVerticalHighlightIndicatorEnabled = false
        set1.highlightColor = .systemRed
        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }
    
    var plant: Plant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(plant)
        
        
        ///--------- test
        
//        let userID = Auth.auth().currentUser?.uid
//        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
//          // Get user value
//          let value = snapshot.value as? NSDictionary
//          let username = value?["username"] as? String ?? ""
//          let user = User(username: username)
//
//          // ...
//          }) { (error) in
//            print(error.localizedDescription)
//        }
        
        
        
        
        
        
        ///--------- test
        
        
        
        
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
        
        setData()
    }
}
