import SwiftUI
import UIKit
import SwiftData
import CoreLocation

struct MapView: UIViewControllerRepresentable {
    
    var context: ModelContext
    @Binding var showModal: Bool
    @Binding var selectedArea: SmokingArea?
    var filteredAreas: [SmokingArea]
    var colorOverride: UIColor? = nil
    
    func makeUIViewController(context: Context) -> MapViewController {
        let controller = MapViewController(context: self.context)
        controller.onDetailNavigation = {
            self.showModal = false
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        if let selectedArea = selectedArea {
            uiViewController.showRoute(on: selectedArea)
        }
        uiViewController.setSmokingAreas(filteredAreas, colorOverride: colorOverride)
    }
    
}
