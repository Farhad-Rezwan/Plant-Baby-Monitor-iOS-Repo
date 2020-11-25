//
//  ChartsViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 13/11/20.
//

import UIKit
import Charts
import TinyConstraints
import CocoaMQTT

class ChartsViewController: UIViewController, DatabaseListener {
    
    
    
//    let defaultHost = "XX.XXX.XXXX.XXXX" //greengrass core host.
//    let clientID = "MyPhone"
    var mqttClient = CocoaMQTT(clientID: "HelloWorld_Subscriber", host: "a3p7lfkutd41l6-ats.iot.ap-southeast-2.amazonaws.com", port: 8883)
    
    

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
        axisFormatDelegate = self
        
        // plant name show
        title = "plant: \(plant?.name ?? " ")"
        
        // adding water button action
        waterButton.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        
        // setting up the view for charts and other views
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
        chartScrollView.top(to: view, offset: 140)
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
        let url = "https://dd3363022dae.ngrok.io"
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
                    print(dataString)
                }
            }.resume()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            self.yourFuncHere()
        }
        
    }
    //Your function here
    func yourFuncHere() {
        waterButton.isEnabled = true
        print("water button is back")
    }
    
    
    /// https://forums.aws.amazon.com/thread.jspa?threadID=279322
    func ggConnect() {
        
//        mqttClient = CocoaMQTT(clientID: clientID, host: defaultHost, port: 8883)
        mqttClient.delegate = self
        mqttClient.enableSSL = true
        mqttClient.allowUntrustCACertificate = true
        //used openSSL to Create this .p;12 from device key, cert and the GreenGrass Group CA obtained by running the basicDiscovery.py of Python SDK.
        let clientCertArray = getClientCertFromP12File(certName: "ggCoreCertX", certPassword: "1234567890")
        var sslSettings: [ String : NSObject ] = [ : ] //replace ( with [
        sslSettings [ kCFStreamSSLCertificates as String ] = clientCertArray //replace ( with [
        mqttClient.sslSettings = sslSettings
        mqttClient.publish("iOS", withString: "Frin me", qos: .qos0, retained: true, dup: true)
        mqttClient.publish("iOS", withString: "from me")
        let _ = mqttClient.connect()
        mqttClient.publish("iOS", withString: "from me")
    }
    func getClientCertFromP12File(certName: String, certPassword: String) -> CFArray? {
        // get p12 file path
        let resourcePath = Bundle.main.path(forResource: certName, ofType: "p12")
        guard let filePath = resourcePath, let p12Data = NSData(contentsOfFile: filePath) else {
            print("Failed to open the certificate file: \(certName).p12")
            return nil
        }
        // create key dictionary for reading p12 file
        let key = kSecImportExportPassphrase as String
        let options : NSDictionary = [ key: certPassword ] //replace ( with [
        var items : CFArray?
        let securityError = SecPKCS12Import(p12Data, options, &items)
        guard securityError == errSecSuccess else {
            if securityError == errSecAuthFailed {
                print("ERROR: SecPKCS12Import returned errSecAuthFailed. Incorrect password?")
            } else {
                print("Failed to open the certificate file: \(certName).p12")
            }
            return nil
        }
        guard let theArray = items, CFArrayGetCount(theArray) > 0 else {
            return nil
        }
        let dictionary = (theArray as NSArray).object(at: 0)
        guard let identity = (dictionary as AnyObject).value(forKey: kSecImportItemIdentity as String) else {
            return nil
        }
        let certArray = [ identity ] as CFArray //replace ( with [
        return certArray
    }
    
}

extension ChartsViewController: CocoaMQTTDelegate {
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("didConnectAct")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didRecieveMessage")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        print("didSubscriveTopic")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("didPingMqtt")
        
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("didRecievePong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("didDisconnectMqtt")
    }
}

// Alternative actions :
/// https://github.com/awslabs/aws-sdk-ios-samples/tree/main/IoT-Sample/Swift


extension ChartsViewController: IAxisValueFormatter {
    
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
}
