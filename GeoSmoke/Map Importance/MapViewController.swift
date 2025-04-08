import UIKit
import SwiftUI
import MapKit
import SwiftData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var mapView: MKMapView!
    var smokingAreas: [SmokingArea] = []
    var context: ModelContext
    var onDetailNavigation: (() -> Void)?
    var colorOverride: UIColor? = nil
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var moveToCurrentLocation: Bool = true
    
    var selectedDestination: SmokingArea?

    
    init(context: ModelContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MKMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
        
        let center = CLLocationCoordinate2D(latitude: -6.301454, longitude: 106.651853)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
        
        let maxLat = center.latitude + 0.003
        let minLat = center.latitude - 0.003
        let maxLon = center.longitude + 0.003
        let minLon = center.longitude - 0.003
        
        let restrictedRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: maxLat - minLat, longitudeDelta: maxLon - minLon))
        mapView.setRegion(restrictedRegion, animated: false)
        
        loadSmokingAreas()
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        NotificationCenter.default.addObserver(self, selector: #selector(centerToUserLocation), name: .returnToUserLocation, object: nil)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @objc private func centerToUserLocation() {
        if let userLocation = mapView.userLocation.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func loadSmokingAreas() {
        let fetchRequest = FetchDescriptor<SmokingArea>()
        do {
            smokingAreas = try context.fetch(fetchRequest)
            print("✅ Successfully loaded smoking areas: \(smokingAreas.count) locations")
            addAnnotations()
        } catch {
            print("Failed to fetch smoking areas: \(error)")
        }
    }
    
    func addAnnotations() {
        for area in smokingAreas {
            let annotation = SmokingAreaAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: area.latitude, longitude: area.longitude)
            annotation.title = area.name
            annotation.subtitle = area.location
            annotation.area = area
            mapView.addAnnotation(annotation)
        }
        
        DispatchQueue.main.async {
            if self.mapView.annotations.count > 0 {
                let userRegion = self.mapView.region
                self.mapView.setRegion(userRegion, animated: false)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let identifier = "SmokingAreaPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.glyphImage = UIImage(systemName: "mappin.circle.fill")
            let detailButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = detailButton
        } else {
            annotationView?.annotation = annotation
        }
        
        if let smokingAnnotation = annotation as? SmokingAreaAnnotation, let area = smokingAnnotation.area {
            if let overrideColor = colorOverride {
                annotationView?.markerTintColor = overrideColor
            } else {
                switch area.facilityGrade.lowercased() {
                case "high": annotationView?.markerTintColor = .systemGreen
                case "moderate": annotationView?.markerTintColor = .systemYellow
                case "low": annotationView?.markerTintColor = .systemRed
                default: annotationView?.markerTintColor = .orangetheme
                }
            }
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = annotationView.annotation as? SmokingAreaAnnotation, let area = annotation.area else { return }
        selectedDestination = area
        drawLineToDestination(area)
        onDetailNavigation?()
        let detailView = DetailView(area: area)
        let hostingController = UIHostingController(rootView: detailView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func drawLineToDestination(_ area: SmokingArea) {
        guard let userCoord = currentLocation?.coordinate else { return }
        let destinationCoord = CLLocationCoordinate2D(latitude: area.latitude, longitude: area.longitude)
        mapView.removeOverlays(mapView.overlays)
        let coords = [userCoord, destinationCoord]
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        mapView.addOverlay(polyline)
        let rect = MKMapRect.boundingRect(for: coords)
        let edgeInsets = UIEdgeInsets(
            top: 60,
            left: 40,
            bottom: 500,
            right: 40
        )
        mapView.setVisibleMapRect(rect, edgePadding: edgeInsets, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .orange
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func setSmokingAreas(_ areas: [SmokingArea], colorOverride: UIColor? = nil) {
        self.smokingAreas = areas
        self.colorOverride = colorOverride
        mapView.removeAnnotations(mapView.annotations)
        addAnnotations()
        
        if let destination = selectedDestination {
            let isStillVisible = areas.contains(where: { $0.id == destination.id})
            if !isStillVisible {
                mapView.removeOverlays(mapView.overlays)
                selectedDestination = nil
            }
        }
    }
    
    func showRoute(on area: SmokingArea) {
        self.selectedDestination = area
        drawLineToDestination(area)
    }
}

class SmokingAreaAnnotation: MKPointAnnotation {
    var area: SmokingArea?
}

extension MKMapRect {
    static func boundingRect(for coordinates: [CLLocationCoordinate2D]) -> MKMapRect {
        let points = coordinates.map { MKMapPoint($0) }
        let rects = points.map { MKMapRect(origin: $0, size: MKMapSize(width: 0, height: 0)) }
        return rects.reduce(MKMapRect.null) { $0.union($1) }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        
        if moveToCurrentLocation {
            let region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            )
            mapView.setRegion(region, animated: true)
            moveToCurrentLocation = false
        }
    }
}
