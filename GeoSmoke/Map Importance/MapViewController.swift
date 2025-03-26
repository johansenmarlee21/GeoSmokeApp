import UIKit
import MapKit

class MapViewController: UIViewController {
    var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MKMapView(frame: view.bounds)
        view.addSubview(mapView)
        
        let center = CLLocationCoordinate2D(latitude: -6.301454, longitude: 106.651853)
        let region = MKCoordinateRegion(
            center: center,
            span:  MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: true)
        
        
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        
        let maxLat = center.latitude + 0.005
        let minLat = center.latitude - 0.005
        let maxLon = center.longitude + 0.005
        let minLon = center.longitude - 0.005
        
        let restrictedRegion = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: maxLat - minLat, longitudeDelta: maxLon - minLon)
        )
        mapView.setRegion(restrictedRegion, animated: false)
            
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let center = CLLocationCoordinate2D(latitude: -6.301454, longitude: 106.651853)
            let maxLat = center.latitude + 0.005
            let minLat = center.latitude - 0.005
            let maxLon = center.longitude + 0.005
            let minLon = center.longitude - 0.005

            let currentCenter = mapView.region.center
            var newCenter = currentCenter

            if currentCenter.latitude > maxLat {
                newCenter.latitude = maxLat
            }
            if currentCenter.latitude < minLat {
                newCenter.latitude = minLat
            }
            if currentCenter.longitude > maxLon {
                newCenter.longitude = maxLon
            }
            if currentCenter.longitude < minLon {
                newCenter.longitude = minLon
            }

            mapView.setCenter(newCenter, animated: true)
    }
}
