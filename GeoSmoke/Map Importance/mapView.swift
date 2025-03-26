import SwiftUI
import UIKit

struct MapView: UIViewControllerRepresentable {
    
    
    func makeUIViewController(context: Context) -> MapViewController{
        return MapViewController()
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
            // No updates needed for now
    }
}
