//
//  ChartsViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 13/11/20.
//

import UIKit
import Charts
import TinyConstraints

class ChartsViewController: UIViewController, DatabaseListener {

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

    // setup custom water button
    let waterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: K.Colors.buttonTxtColor)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.red, for: .disabled)
        button.height(50)
        button.width(200)
        button.setTitle("Water Plant", for: .normal)
        
        return button
    }()
    
    
    
    // setup custom title for moisture chart view
    let titleOfMoistureChartView: UILabel = {
        let moistureLabel = UILabel()
        moistureLabel.backgroundColor = UIColor(white: 1, alpha: 0)
        moistureLabel.textAlignment = .center
        moistureLabel.text = "Plant Soil Moisture Status"
        moistureLabel.font = UIFont(name: K.defaultFont, size: 16)
        moistureLabel.height(50)
        moistureLabel.width(250)

        return moistureLabel
    }()

    // setup custom title for humidity and temperature chart view
    let titleOfTempHumidityChartView: UILabel = {
        let tempAndHumidityLabel = UILabel()
        tempAndHumidityLabel.backgroundColor = UIColor(white: 1, alpha: 0)
        tempAndHumidityLabel.textAlignment = .center
        tempAndHumidityLabel.text = "Temp & Humidity Status"
        tempAndHumidityLabel.font = UIFont(name: K.defaultFont, size: 16)
        tempAndHumidityLabel.height(50)
        tempAndHumidityLabel.width(250)

        return tempAndHumidityLabel
    }()
    
    let visualAffectView: UIVisualEffectView = {
        let visualAffectView = UIVisualEffectView()
        /// animates in depending on the selection of the user
        visualAffectView.effect = UIBlurEffect(style: .dark)
        visualAffectView.backgroundColor = UIColor.init(red: 0.0, green: 0.1, blue: 0.0, alpha: 0.5)
        return visualAffectView
    }()
    
    let logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: K.logoImage)
        return logoImageView
    }()
    
    let noDataFoundLabel: UILabel = {
        let noDataFoundLabel = UILabel()
        return noDataFoundLabel
    }()
    
    // setup custom scroll view for the two chart views
    lazy var chartScrollView: UIScrollView = {
        let chartScrollView = UIScrollView()
        chartScrollView.backgroundColor = UIColor(white: 1, alpha: 0)
        chartScrollView.autoresizingMask = .flexibleWidth
        chartScrollView.showsHorizontalScrollIndicator = true
        chartScrollView.bounces = true
        
        return chartScrollView
    }()
    
    // setup custom chart view for moisture data
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
    
    // setup custom chart view for temperature and humidity data
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

        // plant name show
        title = "plant: \(plant?.name ?? " ")"
        
        // adding water button action
        waterButton.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        
        // setting up the view for charts and other views
        setupViews()
        
        // setting up the right bar button item
        setUpRightBarButtonItem()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let userId = uID else {return}
        databaseController?.addListener(listener: self, userCredentials: userId, plantID: plant?.id ?? " ")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    /// helps to setup and customize the views, and adds subviews
    fileprivate func setupViews() {

        view.addSubview(waterButton)
        view.addSubview(chartScrollView)
        
        // title foer first chart view of moisuture
        chartScrollView.addSubview(titleOfMoistureChartView)
        // first chart view - Moisture
        chartScrollView.addSubview(firstChartViewOfMoisture)
        // title foer second chart view of moisuture
        chartScrollView.addSubview(titleOfTempHumidityChartView)
        // second chart view - Temperature and Humidity
        chartScrollView.addSubview(secondChartViewOfHumidityAndTemperature)

        waterButton.top(to: view, offset: 90)
        waterButton.right(to: view, offset: -30)
        
        // water button design
        waterButton.layer.cornerRadius = 40
        /// designing the plant add to make sure it is consistent in the viewcontroller (adding border)
        waterButton.layer.borderColor = UIColor.black.cgColor
        waterButton.layer.borderWidth = 1

        // chart scroll view constraints
        chartScrollView.edgesToSuperview(excluding: .none, usingSafeArea: true)
        chartScrollView.top(to: view, offset: 150)
        chartScrollView.bottom(to: view, offset: -10)
        chartScrollView.widthToSuperview()
        
        // moisture intro title
        titleOfMoistureChartView.centerX(to: chartScrollView)
        titleOfMoistureChartView.top(to: chartScrollView, offset: 10)
        titleOfMoistureChartView.layer.cornerRadius = 40
        /// designing the text view to make sure it is consistent in the viewcontroller (adding border)
        titleOfMoistureChartView.layer.borderColor = UIColor.black.cgColor
        titleOfMoistureChartView.layer.borderWidth = 1
        
        /// Moisture chart ciew constraints
        firstChartViewOfMoisture.centerX(to: chartScrollView)
        firstChartViewOfMoisture.top(to: chartScrollView, offset: 70)
        firstChartViewOfMoisture.height(300)
        firstChartViewOfMoisture.width(300)
        
        // humidity and temperature intro title
        titleOfTempHumidityChartView.centerX(to: chartScrollView)
        titleOfTempHumidityChartView.bottom(to: firstChartViewOfMoisture, offset: 70)
        titleOfTempHumidityChartView.layer.cornerRadius = 40
        /// designing the text view to make sure it is consistent in the viewcontroller (adding border)
        titleOfTempHumidityChartView.layer.borderColor = UIColor.black.cgColor
        titleOfTempHumidityChartView.layer.borderWidth = 1
        
        
        /// Temperature and Humidity  chart ciew constraints
        secondChartViewOfHumidityAndTemperature.centerX(to: chartScrollView)
        secondChartViewOfHumidityAndTemperature.top(to: firstChartViewOfMoisture, offset: 380)
        secondChartViewOfHumidityAndTemperature.height(300)
        secondChartViewOfHumidityAndTemperature.width(300)
        chartScrollView.contentSize = CGSize(width: chartScrollView.frame.width, height: 800)
    }
    
    private func setUpRightBarButtonItem() {
        let btnBluetooth = UIButton()
        btnBluetooth.setBackgroundImage(UIImage(systemName: "calendar.badge.clock.rtl"), for: .normal)
//        btnBluetooth.setImage(UIImage(systemName: "calendar.badge.clock.rtl"), for: .highlighted)
        btnBluetooth.tintColor = UIColor(named: K.Colors.buttonTxtColor)
        btnBluetooth.addTarget(self, action: #selector(addTapped), for: UIControl.Event.touchUpInside)

        let barButton = UIBarButtonItem(customView: btnBluetooth)
        self.navigationItem.rightBarButtonItem = barButton
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(style: .plain, target: self, action: #selector(addTapped))
    }
//    @objc func addTapped() {
//        print("Tapped")
//    }
    
    
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
        
        /// adding data in the datasets
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
        
        /// looping through the last 20 statuses and
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
        
        
        /// loooping through the last status and get the status count
        let last1 = last20?.suffix(1)
        
        for j in last1!  {
            /// date time requried?
            var localDate: String = ""
            let timeResult = (j.timeStamp)
            let date = Date(timeIntervalSince1970: timeResult)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.short //Set date style
            dateFormatter.timeZone = .current
            localDate = dateFormatter.string(from: date)
            print("lat one here")
            print(localDate, j.moist, j.humid, j.temp)
            if (j.moist > 7.00) {
                // desabled
                waterButton.isEnabled = false
            }
        }
        
        if statuses?.count == 0 {
            
            /// set the views when the plant data not available
            setViewForNoData()
        } else {
            waterButton.isEnabled = true
            /// remove no data view from the scroll view
            visualAffectView.removeFromSuperview()
            logoImageView.removeFromSuperview()
            noDataFoundLabel.removeFromSuperview()
        }

        

    }
    
    /// UIDesign for no data available.
    private func setViewForNoData() {
        chartScrollView.addSubview(visualAffectView)
        visualAffectView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        visualAffectView.top(to: chartScrollView, offset: 10)
        visualAffectView.center(in: chartScrollView)
        chartScrollView.addSubview(logoImageView)
        logoImageView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        logoImageView.top(to: chartScrollView, offset: 20)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.centerInSuperview()
        chartScrollView.addSubview(noDataFoundLabel)
        noDataFoundLabel.text = ("no data found for: \(plant?.name ?? " ")")
        noDataFoundLabel.font = UIFont(name: K.defaultFont, size: 12)
        noDataFoundLabel.textColor = UIColor(named: K.Colors.buttonTxtColor)
        noDataFoundLabel.centerX(to: chartScrollView)
        noDataFoundLabel.top(to: chartScrollView, offset: 15)
        waterButton.isEnabled = false
    }
    
    /// did nothing
    func onUserChange(change: DatabaseChange, userPlants: [Plant]) {
    }
    
    /// did nothing
    func onPlantListChange(change: DatabaseChange, plants: [Plant]) {
    }
    
    func onPlantStatusChange(change: DatabaseChange, statuses: [Status]) {
        self.statuses = []
        self.statuses = statuses
        loopAndPopulateDateInyValues()
        setData()
    }
    
    /// objective c function for the water button
    @objc func buttonTapped(sender : UIButton) {
        print("pressed")
        let url = K.trigger_water_URL
        waterButton.isEnabled = false
        print(" button is disabled")
        
        if let myUrl = URL(string: url)
        {
            URLSession.shared.dataTask(with: myUrl)
            {
                (data, response, err) in
                
                if let data = data
                {
                    let dataString = String(data: data, encoding: .utf8)
                    print("\(String(describing: dataString))")
                }
            }.resume()
        }
        
        databaseController?.removeListener(listener: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.makeWaterButtonBack()
        }
        
        /// taptic feedback correct
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        /// highlight button feedback
        waterButton.showsTouchWhenHighlighted = true
        
    }
    
    //function to make the water button back
    func makeWaterButtonBack() {
        waterButton.isEnabled = true
        guard let userId = uID else {return}
        guard let plantID = plant?.id else {return}
        databaseController?.addListener(listener: self, userCredentials: userId, plantID: plantID)
        print("water button is back")
    }
}


// Reference https://www.youtube.com/watch?v=cZbEGJOPZ98
// Code regarding push notifications:
extension ChartsViewController {
    
    /// Add tapped for water reminder in the bar button item
    @IBAction func addTapped(_ sender: Any) {
        /// gives user with selection haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        guard let plantName = plant?.name else { return }
        
        let alertController = UIAlertController(title: "Water Plant Reminder: \(plantName)", message: nil, preferredStyle: .actionSheet)
        let setLocalNotificationAction = UIAlertAction(title: "Set water-alert for every day", style: .default) { (action) in
            LocalNotificationManager.setNotification(1, of: .days, repeats: true, title: "Hey its time to water your plant: \(plantName)", body: "Click to open in app", userInfo: ["aps" : ["Alert" : "1 per day"]])
        }
        let setLocalNotificationAction2 = UIAlertAction(title: "Set Alert for after 6 sec sec(Testing)", style: .default) { (action) in
            LocalNotificationManager.setNotification(6, of: .seconds, repeats: false, title: "Hey its time to water your plant: \(plantName)", body: "Click to open in app", userInfo: ["aps" : ["Alert" : "6 in every ~ sec"]])
        }
        let removeLocalNotificationAction = UIAlertAction(title: "Remove", style: .default) { (action) in
            LocalNotificationManager.cancel()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        
        alertController.addAction(setLocalNotificationAction)
        alertController.addAction(setLocalNotificationAction2)
        alertController.addAction(removeLocalNotificationAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}


