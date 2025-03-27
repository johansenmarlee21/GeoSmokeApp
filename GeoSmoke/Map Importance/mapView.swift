import SwiftUI
import UIKit
import SwiftData

struct MapView: UIViewControllerRepresentable {
    var context: ModelContext  

    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController(context: self.context)
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        // No updates needed for now
    }
}
