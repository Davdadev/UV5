import Foundation
import CoreLocation

final class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?
    private var cityContinuation: CheckedContinuation<String?, Never>?

    private override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() async -> CLLocation? {
        requestPermission()
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            manager.startUpdatingLocation()
        }
    }

    func requestCity() async -> String? {
        guard let location = await requestLocation() else { return nil }
        
        return await withCheckedContinuation { continuation in
            self.cityContinuation = continuation
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                let city = placemarks?.first?.locality
                self.cityContinuation?.resume(returning: city)
                self.cityContinuation = nil
            }
        }
    }

    private func requestPermission() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()
        
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            let city = placemarks?.first?.locality
            self.cityContinuation?.resume(returning: city)
            self.cityContinuation = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(returning: nil)
        locationContinuation = nil
        cityContinuation?.resume(returning: nil)
        cityContinuation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
}

