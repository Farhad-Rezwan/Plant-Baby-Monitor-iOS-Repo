//
//  PlantDetailsViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 3/11/20.
//

import UIKit
import Charts
import Firebase
import TinyConstraints



struct Status: CustomStringConvertible {
    let humid: Double
    let moist: Double
    let temp: Double
    let timeStamp: Double
    
    init(dictionary: [String: Any]) {
        self.humid = dictionary["humid"] as? Double ?? 0
        self.moist = dictionary["moist"] as? Double ?? 0
        self.temp = dictionary["temp"] as? Double ?? 0
        self.timeStamp = dictionary["timestamp"] as? Double ?? 0
    }
    var description: String {
        return "Humid#: " + String(humid) + " - name: " +  String(moist) + " - temp: " +  String(temp) + " - temeStamp: " +  String(timeStamp)
    }
}





class PlantDetailsViewController: UIViewController {
    
    var ref: DatabaseReference = Database.database().reference()
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
    
    var yValues: [ChartDataEntry] = []

    func setData() {
        let set1 = LineChartDataSet(entries: yValues, label: "Plants")
        set1.drawCirclesEnabled = false
        
        // remove the sharp edges
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

        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
        
        fetchData()
    }
    
    func fetchData() {
        
        ///--------- test
        
        ref.child("7MBL5Bbt48NnpWcZappr").observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
            let value = snapshot.value as! NSDictionary
            print(value)
            var i: Double = 0
            for key in value.allKeys {
                let s = Status(dictionary: value[key] as! [String: Any])
                print(s.timeStamp)
                print(s.moist)
                self.yValues.append(
                    
                    ChartDataEntry(x: i, y: s.humid)
                )
                i += 1
            }
          // ...
          }) { (error) in
            print(error.localizedDescription)
        }
        
        

        ///--------- test
        
    }
    
    @IBAction func populateChartPressed(_ sender: Any) {
        setData()
    }
    
}
