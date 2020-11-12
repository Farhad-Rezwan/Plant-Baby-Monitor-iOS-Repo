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
//import CodableFirebase


class PlantDetailsViewController: UIViewController, DatabaseListener {
    var listenerType: ListenerType = .plantStatus
    weak var databaseController: DatabaseProtocol?

    var statuses: [Status]?
    /// sets reference to the database 
    var ref: DatabaseReference = Database.database().reference()
    var uID: String?
    
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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)

        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self, userCredentials: uID!)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func fetchData() {
        
////        ///--------- test
////        /// Obesrve events of single plant status changes
////        ref.child("7MBL5Bbt48NnpWcZappr").observeSingleEvent(of: .value, with: { (snapshot) in
////          // Get user value
////            let value = snapshot.value as! NSDictionary
////            print(value)
////            var i: Double = 0
////            for key in value.allKeys {
////                let s = Status(dictionary: value[key] as! [String: Any])
////                print(s.timeStamp)
////                print(s.humid)
////                self.yValues.append(
////
////                    ChartDataEntry(x: i, y: s.moist)
////                )
////                i += 1
////            }
////          // ...
////          }) { (error) in
////            print(error.localizedDescription)
////        }
//
//
//
//        ///--------- Code
//        ref.child("7MBL5Bbt48NnpWcZappr").observeSingleEvent(of: .value, with: { (snapshot) in
//          // Get user value
//            let value = snapshot.value as! NSDictionary
//            var i: Double = 0
//            for key in value.allKeys {
//                let s = Status(dictionary: value[key] as! [String: Any])
//
//
//                // converting date to string date
//                var localDate: String = ""
//                let timeResult = (s.timeStamp)
//                let date = Date(timeIntervalSince1970: timeResult)
//                let dateFormatter = DateFormatter()
//                dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
//                dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
//                dateFormatter.timeZone = .current
//                localDate = dateFormatter.string(from: date)
//
//                //print(" timeStamp: \(localDate), humidity: \(s.humid), temperature: \(s.temp), moisture: \(s.moist)")
//
//
//
//                self.yValues.append(
//
//                    ChartDataEntry(x: i, y: s.moist)
//                )
//                i += 1
//            }
//          // ...
//          }) { (error) in
//            print(error.localizedDescription)
//        }
        
    }
    
    private func loopAndPopulateDateInyValues(){
        // sorting statuses by time stamp
        print("BeforeSortign")
        for i in statuses!  {
            var localDate: String = ""
            let timeResult = (i.timeStamp)
            let date = Date(timeIntervalSince1970: timeResult)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = .current
            localDate = dateFormatter.string(from: date)
            print(localDate)
        }
        

        
        statuses?.sort(by: { $0.timeStamp > $1.timeStamp})
        

        print("After sorting")
        for i in statuses!  {
            var localDate: String = ""
            let timeResult = (i.timeStamp)
            let date = Date(timeIntervalSince1970: timeResult)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = .current
            localDate = dateFormatter.string(from: date)
            print(localDate)
        }
        
        self.yValues.append(
            ChartDataEntry(x: 1, y: 1)
        )
    }
    
    @IBAction func populateChartPressed(_ sender: Any) {
        setData()
    }
    
    func onUserChange(change: DatabaseChange, userPlants: [Plant]) {
        // do nothing
    }
    
    func onPlantListChange(change: DatabaseChange, plants: [Plant]) {
        // do nothing
    }
    
    func onPlantStatusChange(change: DatabaseChange, statuses: [Status]) {
        self.statuses = statuses
//        print("Plant status invoked from Plant Details View Controller")
//        print(statuses)
        loopAndPopulateDateInyValues()
    }
    
    
}
