//
//  Constants.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 6/11/20.
//

import Foundation

import Foundation
import AWSCore

//WARNING: To run this sample correctly, you must set the following constants.
let CertificateSigningRequestCommonName = "IoTSampleSwift Application"
let CertificateSigningRequestCountryName = "Your Country"
let CertificateSigningRequestOrganizationName = "Your Organization"
let CertificateSigningRequestOrganizationalUnitName = "Your Organizational Unit"

let POLICY_NAME = "waterer-policy"

// This is the endpoint in your AWS IoT console. eg: https://xxxxxxxxxx.iot.<region>.amazonaws.com
let AWS_REGION = AWSRegionType.Unknown

//For both connecting over websockets and cert, IOT_ENDPOINT should look like
//https://xxxxxxx-ats.iot.REGION.amazonaws.com
let IOT_ENDPOINT = "https://xxxxxxxxxx.iot.<region>.amazonaws.com"
let IDENTITY_POOL_ID = "<REGION>:<UUID>"

//Used as keys to look up a reference of each manager
let AWS_IOT_DATA_MANAGER_KEY = "MyIotDataManager"
let AWS_IOT_MANAGER_KEY = "MyIotManager"
