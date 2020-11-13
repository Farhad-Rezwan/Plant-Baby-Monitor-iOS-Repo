//
//  ChartsViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 13/11/20.
//

import UIKit
import Charts

class ChartsViewController: UIViewController {
    
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

        setupViews()
    }
////    override func viewDidLayoutSubviews() {
////        setupViews()
////    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setupViews()
//    }
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

}
