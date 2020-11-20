//
//  ChartsViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 13/11/20.
//

import UIKit
import Charts
import TinyConstraints

class ChartsViewController: UIViewController, DatabaseListener, IAxisValueFormatter{
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        var localDate: String = ""
        let date = Date(timeIntervalSince1970: value)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.short //Set date style
        dateFormatter.timeZone = .current
        localDate = dateFormatter.string(from: date)
        print(localDate)
        
        return localDate
    }
    
    
    //MARK:- Variables for View Data
    var listenerType: ListenerType = .plantStatus
    weak var databaseController: DatabaseProtocol?
    var statuses: [Status]?
    /// sets reference to the database
    var uID: String?
    var yDataEntriesForMoisure: [ChartDataEntry] = []
    var yDataEntriesForTemp: [ChartDataEntry] = []
    var yDataEntriesForHumid: [ChartDataEntry] = []
    var plant: Plant?
    let headerImageViewHeight: CGFloat = 100
    let waterButtonHeight: CGFloat = 50
    
    /// Formatter delegate
    weak var axisFormatDelegate: IAxisValueFormatter?

    let waterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: K.Colors.buttonColor)
        button.setTitleColor(UIColor(named:K.Colors.buttonTextColor), for: .normal)
        button.height(40)
        button.width(200)
        button.setTitle("Water Plant", for: .normal)
        
        return button
    }()

    lazy var chartScrollView: UIScrollView = {
        let chartScrollView = UIScrollView()
        chartScrollView.backgroundColor = .white
        chartScrollView.autoresizingMask = .flexibleWidth
        chartScrollView.showsHorizontalScrollIndicator = true
        chartScrollView.bounces = true
        
        return chartScrollView
    }()
    
    var firstChartViewOfMoisture: LineChartView = {
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
    
    var secondChartViewOfHumidityAndTemperature: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemRed
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
        
        axisFormatDelegate = self
        
        waterButton.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        setupViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self, userCredentials: uID!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    fileprivate func setupViews() {

        view.addSubview(waterButton)
        view.addSubview(chartScrollView)
        
        chartScrollView.addSubview(firstChartViewOfMoisture)
        chartScrollView.addSubview(secondChartViewOfHumidityAndTemperature)

        waterButton.top(to: view, offset: 100)
        waterButton.right(to: view, offset: -30)

        chartScrollView.edgesToSuperview(excluding: .none, usingSafeArea: true)
        chartScrollView.top(to: view, offset: 220)
        chartScrollView.bottom(to: view, offset: -10)
        chartScrollView.widthToSuperview()
        
        /// Moisture chart ciew constraints
        firstChartViewOfMoisture.centerX(to: chartScrollView)
        firstChartViewOfMoisture.top(to: chartScrollView, offset: 20)
        firstChartViewOfMoisture.height(300)
        firstChartViewOfMoisture.width(300)
        
        /// Temperature and Humidity  chart ciew constraints
        secondChartViewOfHumidityAndTemperature.centerX(to: chartScrollView)
        secondChartViewOfHumidityAndTemperature.top(to: firstChartViewOfMoisture, offset: 320)
        secondChartViewOfHumidityAndTemperature.height(300)
        secondChartViewOfHumidityAndTemperature.width(300)
        chartScrollView.contentSize = CGSize(width: chartScrollView.frame.width, height: 1000)
        
        

    }
    
    
    func setData() {
        let set1 = LineChartDataSet(entries: yDataEntriesForMoisure, label: "Moisture")
        set1.drawCirclesEnabled = false
        // remove the sharp edges
        set1.mode = .cubicBezier
        set1.lineWidth = 3
        set1.setColor(.white)

        /// if imgage is used better
        set1.fillAlpha = 0.8
        set1.drawFilledEnabled = true

        /// remove highlight indecator
        set1.drawVerticalHighlightIndicatorEnabled = false
        set1.highlightColor = .systemRed

        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        firstChartViewOfMoisture.data = data
        
        
        
        
        
        // MARK:- Moisture values
        
        let set2 = LineChartDataSet(entries: yDataEntriesForTemp, label: "Temperature")
        set2.drawCirclesEnabled = false
        // remove the sharp edges
        set2.mode = .cubicBezier
        set2.lineWidth = 3
        set2.setColor(.green)
        /// not fill
        
        //set2.fill = Fill(color: .white)

        /// if imgage is used better
        set2.fillAlpha = 0
        set2.drawFilledEnabled = true

        /// remove highlight indecator
        set2.drawVerticalHighlightIndicatorEnabled = false
        set2.highlightColor = .systemRed

        
        let set3 = LineChartDataSet(entries: yDataEntriesForHumid, label: "Humidity")
        set3.drawCirclesEnabled = false
        // remove the sharp edges
        set3.mode = .cubicBezier
        set3.lineWidth = 3
        set3.setColor(.blue)
        /// not fill
        
        //set2.fill = Fill(color: .white)

        /// if imgage is used better
        set3.fillAlpha = 0
        set3.drawFilledEnabled = true

        /// remove highlight indecator
        set3.drawVerticalHighlightIndicatorEnabled = false
        set3.highlightColor = .systemRed
        
        
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set2)
        dataSets.append(set3)
        
        let lineChartDataSet = LineChartData(dataSets: dataSets)

        secondChartViewOfHumidityAndTemperature.data = lineChartDataSet
    }
    
    

    
    private func loopAndPopulateDateInyValues(){
        yDataEntriesForMoisure = []
        yDataEntriesForTemp = []
        yDataEntriesForHumid = []
        
        statuses?.sort(by: { $0.timeStamp < $1.timeStamp})
        
        let last20 = statuses?.suffix(20)
        print("sortedLast20")
        print("After sorting last 20")
        var k: Double = 0
        for i in last20!  {
            var localDate: String = ""
            let timeResult = (i.timeStamp)
            let date = Date(timeIntervalSince1970: timeResult)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.short //Set date style
            dateFormatter.timeZone = .current
            localDate = dateFormatter.string(from: date)
            print("sorted last 20 status: \(k) ")
            print(localDate, i.moist, i.humid, i.temp)

            self.yDataEntriesForMoisure.append(
                ChartDataEntry(x: k, y: i.moist)
            )

            self.yDataEntriesForTemp.append(
                ChartDataEntry(x: k, y: i.temp)
            )
            self.yDataEntriesForHumid.append(
                ChartDataEntry(x: k, y: i.humid)
            )

            k += 1
        }

    }
    
    
    
    
    
    func onUserChange(change: DatabaseChange, userPlants: [Plant]) {
    }
    
    func onPlantListChange(change: DatabaseChange, plants: [Plant]) {
    }
    
    func onPlantStatusChange(change: DatabaseChange, statuses: [Status]) {
        self.statuses = []
        self.statuses = statuses
        loopAndPopulateDateInyValues()
        setData()
    }
    
    @objc func buttonTapped(sender : UIButton) {
        print("pressed")
                    //Write button action here
    }
}
