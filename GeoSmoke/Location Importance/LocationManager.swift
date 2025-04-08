import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    private var locationCompletion: ((CLLocation?) -> Void)?
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        requestPermission()
    }
    
    // MARK: - Permission
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func printAuthorizationStatus() {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse: print("✅ Authorized When In Use")
        case .authorizedAlways: print("✅ Authorized Always")
        case .denied: print("❌ Denied by user")
        case .restricted: print("⚠️ Restricted")
        case .notDetermined: print("🔄 Not Determined")
        @unknown default: print("🌀 Unknown")
        }
    }
    
    // MARK: - Location Fetching
    func getUserLocation(completion: @escaping (CLLocation?) -> Void) {
        self.locationCompletion = completion
        
        let status = CLLocationManager.authorizationStatus()
        print("📍 Checking permission: \(status.rawValue)")
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .notDetermined:
            requestPermission()
        default:
            print("⚠️ Location access denied or restricted.")
            completion(nil)
        }
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("🔐 Authorization status changed to: \(status.rawValue)")
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationCompletion?(nil)
            return
        }
        
        DispatchQueue.main.async {
            self.currentLocation = location
            self.locationCompletion?(location)
            self.locationCompletion = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Failed to get user location: \(error.localizedDescription)")
        locationCompletion?(nil)
    }
}
