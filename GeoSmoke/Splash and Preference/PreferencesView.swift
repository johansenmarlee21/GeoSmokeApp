import SwiftUI

struct PreferencesView: View {
    @Binding var isPresented: Bool
    @Binding var selectedAmbience: String
    @Binding var selectedCrowd: String
    @Binding var selectedFacilities: Set<String>
    @Binding var selectedTypes: Set<String>
    
    var onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Preferences")
                .font(.title2)
                .bold()
                .padding(.top)
            
            
            VStack(alignment: .leading) {
                Text("Ambience")
                    .font(.headline)
                Picker("Ambience", selection: $selectedAmbience) {
                    Text("Dark").tag("Dark")
                    Text("Bright").tag("Bright")
                }
                .pickerStyle(.segmented)
            }
            
            
            VStack(alignment: .leading) {
                Text("Facilities")
                    .font(.headline)
                Toggle("Chair", isOn: binding(for: "Chair", in: $selectedFacilities))
                    .tint(Color.orangetheme)
                Toggle("Roof", isOn: binding(for: "Roof", in: $selectedFacilities))
                    .tint(Color.orangetheme)
                Toggle("Waste Bin", isOn: binding(for: "Waste Bin", in: $selectedFacilities))
                    .tint(Color.orangetheme)
            }
            
            
            VStack(alignment: .leading) {
                Text("Crowd Level")
                    .font(.headline)
                Picker("Crowd", selection: $selectedCrowd) {
                    Text("Low").tag("Low")
                    Text("High").tag("High")
                }
                .pickerStyle(.segmented)
            }
            
            
            VStack(alignment: .leading) {
                Text("Type")
                    .font(.headline)
                Toggle("E-cigarette", isOn: binding(for: "E-cigarette", in: $selectedTypes))
                    .tint(Color.orangetheme)
                Toggle("Cigarette", isOn: binding(for: "Cigarette", in: $selectedTypes))
                    .tint(Color.orangetheme)
            }
            
            
            Button(action: {
                onSave()
                isPresented = false
                print("Preferences saved: \(selectedAmbience), \(selectedCrowd), \(selectedFacilities), \(selectedTypes)")
                
            }) {
                Text("Save")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.darkGreen)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top)
            
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .padding()
        .shadow(radius: 10)
    }
    
    func binding(for item: String, in set: Binding<Set<String>>) -> Binding<Bool> {
        Binding<Bool>(
            get: { set.wrappedValue.contains(item) },
            set: { isSelected in
                if isSelected {
                    set.wrappedValue.insert(item)
                } else {
                    set.wrappedValue.remove(item)   
                }
            }
        )
    }
}


#Preview {
    PreferencesPreviewWrapper()
}

struct PreferencesPreviewWrapper: View {
    @State private var isPresented = true
    @State private var selectedAmbience = "dark"
    @State private var selectedCrowd = "low"
    @State private var selectedFacilities: Set<String> = ["Chair"]
    @State private var selectedTypes: Set<String> = ["E-cigarette"]
    
    var body: some View {
        PreferencesView(
            isPresented: $isPresented,
            selectedAmbience: $selectedAmbience,
            selectedCrowd: $selectedCrowd,
            selectedFacilities: $selectedFacilities,
            selectedTypes: $selectedTypes,
            onSave: {
                print("💾 Preview: Preferences saved")
            }
        )
    }
}

