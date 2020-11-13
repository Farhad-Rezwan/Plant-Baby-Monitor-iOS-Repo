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
    
    /// setting up the listeners for plantstatus
    var listenerType: ListenerType = .plantStatus
    weak var databaseController: DatabaseProtocol?
    var statuses: [Status]?
    /// sets reference to the database 
    var uID: String?
    var yValues: [ChartDataEntry] = []
    var plant: Plant?
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // set delegate for the Database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        
        view.addSubview(lineChartView)
        lineChartView.edgesToSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self, userCredentials: uID!)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    private func loopAndPopulateDateInyValues(){
        // sorting statuses by time stamp
        statuses?.sort(by: { $0.timeStamp > $1.timeStamp})
        print("After sorting")
        var k: Double = 0
        for i in statuses!  {
            var localDate: String = ""
            let timeResult = (i.timeStamp)
            let date = Date(timeIntervalSince1970: timeResult)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.short //Set date style
            dateFormatter.timeZone = .current
            localDate = dateFormatter.string(from: date)
            print(localDate)
            
            self.yValues.append(
                ChartDataEntry(x: k, y: i.humid)
            )
            k += 1
        }
        
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
