//
//  LoggingViewController.swift
//  WalkingLogger
//
//  Created by SASAKI, Iori on 2022/04/15.
//

import UIKit
import CoreLocation
import MapKit

class LoggingViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // properties
    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D!
    enum RecordingStatus {
        case pause, recording
    }
    var currentRecordingStatus: RecordingStatus = .pause
    var recordingTimer: Timer!
    var trajectory: Trajectory!
    
    // UI Components
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var zoomLocationButton: UIBarButtonItem!
    @IBOutlet weak var baseMap: MKMapView!
    @IBOutlet weak var recordingButton: UIBarButtonItem!
    @IBOutlet weak var recordingStatusLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupLocationManager()
        baseMap.delegate = self
    }

    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latitude = locations.last?.coordinate.latitude
        let longitude = locations.last?.coordinate.longitude
        
        latitudeLabel.text = "Latitude: \(latitude!)"
        longitudeLabel.text = "Longitude: \(longitude!)"
        
        currentLocation = locations.last?.coordinate
    }

    
    @IBAction func zoomLocation(_ sender: UIBarButtonItem) {
        guard let currentLocation = currentLocation else { return }
        
        let region = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 300, longitudinalMeters: 300)
        baseMap.setRegion(region, animated: true)
    }
    
    @IBAction func didPushRecordingButton(_ sender: UIBarButtonItem) {
        
        switch currentRecordingStatus {
        case .pause:
            // ????????????????????????
            let actionSheet = UIAlertController(title: "??????????????????????????????", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "????????????", style: .default, handler: { _ in
                // ???????????????????????????
                self.startRecording()
            }))
            actionSheet.addAction(UIAlertAction(title: "???????????????", style: .cancel, handler: nil))
            self.present(actionSheet, animated: true, completion: nil)
        case .recording:
            // ??????????????????
            let actionSheet = UIAlertController(title: "??????????????????????????????", message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "????????????", style: .default, handler: { _ in
                //???????????????????????????
                self.stopRecording()
            }))
            actionSheet.addAction(UIAlertAction(title: "???????????????", style: .cancel, handler: nil))
            self.present(actionSheet, animated: true, completion: nil)
        }
        
    }
    
    func startRecording() {
        currentRecordingStatus = .recording
        recordingStatusLabel.text = "under recording"
        //
//        trajectory = []
        
        let age = 20
        let device = "iPhoneXR??????"
        let description = "???????????????????????????????????????????????????"
        trajectory = Trajectory(age: age, device: device, description: description)
        
        recordingTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateRecording), userInfo: nil, repeats: true)
    }
    
    func stopRecording() {
        currentRecordingStatus = .pause
        recordingStatusLabel.text = "pause"
        //
        // trajectory???????????????????????????
        if let jsonData = trajectory.json {
            // ??????????????????(~/Documents/***.json)
            let documentsPath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "TrajectoryRecord-" + trajectory.createdAt + ".json"
            let savePath = documentsPath.appendingPathComponent(fileName)
            // ??????
            do {
                try jsonData.write(to: savePath)
            } catch {
                fatalError("Could not save JSON")
            }
        }
        //
        recordingTimer.invalidate()
        recordingTimer = nil
        trajectory = nil
        baseMap.removeOverlays(baseMap.overlays)
    }
    
    // 3????????????????????????
    @objc func updateRecording() {
        guard let currentLocation = currentLocation else { return }
        
//        trajectory.append(currentLocation)
        let latitude = currentLocation.latitude
        let longitude = currentLocation.longitude
        let timestamp = Tools.generateStringTimestamp()
        let locationData = LocationData(latitude: latitude, longitude: longitude, timestamp: timestamp)
        trajectory.locationList.append(locationData)
        
        // ?????????????????????
//        let count = trajectory.count
        let count = trajectory.locationList.count
        if count < 2 { return }
        
//        let preLocation: CLLocationCoordinate2D = trajectory[count-2]
        let preLocation = CLLocationCoordinate2D(
            latitude: trajectory.locationList[count-2].latitude,
            longitude: trajectory.locationList[count-2].longitude
        )
        
        let coordinates = [preLocation, currentLocation]
        let newLine = MKPolyline(coordinates: coordinates, count: 2)
        baseMap.addOverlay(newLine)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyLine = overlay as? MKPolyline {
            // ????????????
            let lineRenderer = MKPolylineRenderer(polyline: polyLine)
            lineRenderer.strokeColor = .blue
            lineRenderer.lineWidth = 5.0
            return lineRenderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    
}

