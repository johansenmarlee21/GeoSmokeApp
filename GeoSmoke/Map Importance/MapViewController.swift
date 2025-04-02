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
        let region = MKCoordinateRegion(
            center: center,
            span:  MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)
        
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
        
        let maxLat = center.latitude + 0.003
        let minLat = center.latitude - 0.003
        let maxLon = center.longitude + 0.003
        let minLon = center.longitude - 0.003
        
        let restrictedRegion = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: maxLat - minLat, longitudeDelta: maxLon - minLon)
        )
        mapView.setRegion(restrictedRegion, animated: false)
        
        loadSmokingAreas()
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
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)->MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "SmokingAreaPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            annotationView?.glyphImage = UIImage(systemName: "mappin.circle.fill")
            
            let detailButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = detailButton
        }else{
            annotationView?.annotation = annotation
        }
        if let smokingAnnotation = annotation as? SmokingAreaAnnotation,
           let area = smokingAnnotation.area {
            
            if let overrideColor = colorOverride {
                annotationView?.markerTintColor = overrideColor // 👈 override applied
            } else{
                switch area.facilityGrade.lowercased() {
                case "high":
                    annotationView?.markerTintColor = .systemGreen
                case "moderate":
                    annotationView?.markerTintColor = .systemYellow
                case "low":
                    annotationView?.markerTintColor = .systemRed
                default:
                    annotationView?.markerTintColor = .orangetheme
                }
                
                
            }
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = annotationView.annotation as? SmokingAreaAnnotation,
              let area = annotation.area else {
            return
        }
        onDetailNavigation?()
        let detailView = DetailView(area: area)
        
        let hostingController = UIHostingController(rootView: detailView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func centerMap(on area: SmokingArea) {
        
        let testCoor = area.latitude + -0.0015
        
        let coordinate = CLLocationCoordinate2D(latitude: testCoor, longitude: area.longitude)
        let region = MKCoordinateRegion(center: coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        mapView.setRegion(region, animated: true)
    }
    
    func setSmokingAreas(_ areas: [SmokingArea], colorOverride: UIColor? = nil) {
        self.smokingAreas = areas
        self.colorOverride = colorOverride
        mapView.removeAnnotations(mapView.annotations)
        addAnnotations()
    }
    
}

class SmokingAreaAnnotation: MKPointAnnotation {
    var area: SmokingArea?
}
