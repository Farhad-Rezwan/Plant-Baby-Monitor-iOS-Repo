//
//  ChartsViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 13/11/20.
//

import UIKit
import Charts
import TinyConstraints

class ChartsViewController: UIViewController, DatabaseListener{
    
    //MARK:- Variables for View Data
    var listenerType: ListenerType = .plantStatus
    weak var databaseController: DatabaseProtocol?
    var statuses: [Status]?
    /// sets reference to the database
    var uID: String?
    var yValues: [ChartDataEntry] = []
    var plant: Plant?
    
    
    
    let headerImageViewHeight: CGFloat = 100
    let waterButtonHeight: CGFloat = 50
    let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .green
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "navigationTop")
        imageView.contentMode = .redraw
        return imageView
    }()
    
    let waterButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "WaterButton").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let updateButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "WaterButton").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    lazy var chartScrollView: UIScrollView = {
        let chartScrollView = UIScrollView()
        chartScrollView.backgroundColor = .gray
        chartScrollView.autoresizingMask = .flexibleWidth
        chartScrollView.showsHorizontalScrollIndicator = true
        chartScrollView.bounces = true

        
        
        return chartScrollView
    }()
    
    lazy var moistureChartView: LineChartView = {
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
    
    lazy var tempHumChartView: LineChartView = {
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
        
        setupViews()
    }

    fileprivate func setupViews() {

    
//        view.addSubview(headerImageView)
        view.addSubview(waterButton)
        view.addSubview(updateButton)

        view.addSubview(chartScrollView)
        
        chartScrollView.addSubview(moistureChartView)
        chartScrollView.addSubview(tempHumChartView)
        
//        headerImageView.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
//        headerImageView.height(headerImageViewHeight)
        
        waterButton.top(to: view, offset: 30)
        waterButton.right(to: view, offset: -16)

        updateButton.top(to: view, offset: 30)
        updateButton.left(to: view, offset: 16)
        
        chartScrollView.edgesToSuperview(excluding: .none, usingSafeArea: true)
//        chartScrollView.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        chartScrollView.top(to: view, offset: 110)
        chartScrollView.bottom(to: view, offset: -10)
        chartScrollView.left(to: view, offset: 40)
        chartScrollView.right(to: view, offset: -40)
//        chartScrollView.height(1000)
//        chartScrollView.edgesToSuperview()
//        chartScrollView.autoresizingMask = .flexibleWidth
//        chartScrollView.showsHorizontalScrollIndicator = true
//        chartScrollView.bounces = true
        
        moistureChartView.top(to: chartScrollView, offset: 20)
//        moistureChartView.left(to: view, offset: 40)
//        moistureChartView.right(to: view, offset: -40)
        moistureChartView.height(300)
        moistureChartView.width(300)
        
        tempHumChartView.top(to: moistureChartView, offset: 320)
//        tempHumChartView.left(to: chartScrollView, offset: 40)
//        tempHumChartView.right(to: chartScrollView, offset: -40)
        tempHumChartView.height(300)
        tempHumChartView.width(300)
        chartScrollView.contentSize = CGSize(width: chartScrollView.frame.width, height: 1000)
        
        

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
        moistureChartView.data = data
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
        setData()
    }

}
