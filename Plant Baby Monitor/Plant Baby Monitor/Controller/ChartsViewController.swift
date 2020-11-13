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

        setupViews()
    }
    
    fileprivate func setupViews() {
//        view.addSubview(headerImageView)
        view.addSubview(waterButton)
        view.addSubview(updateButton)

        view.addSubview(chartScrollView)
        
        chartScrollView.addSubview(moistureChartView)
        
        
//        headerImageView.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
//        headerImageView.height(headerImageViewHeight)
        
        waterButton.top(to: view, offset: 30)
        waterButton.right(to: view, offset: -16)

        updateButton.top(to: view, offset: 30)
        updateButton.left(to: view, offset: 16)
        
        chartScrollView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        chartScrollView.top(to: view, offset: 110)
        chartScrollView.autoresizingMask = .flexibleHeight
        chartScrollView.showsHorizontalScrollIndicator = true
        chartScrollView.bounces = true
        
        moistureChartView.top(to: view, offset: 20)
        moistureChartView.left(to: view, offset: 40)
        moistureChartView.right(to: view, offset: -40)
        moistureChartView.height(300)

    }

}
