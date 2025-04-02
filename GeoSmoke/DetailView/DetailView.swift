//
//  DetailView.swift
//  GeoSmoke
//
//  Created by Ageng Tawang Aryonindito on 27/03/25.
//

import SwiftUI
import SwiftData

struct DetailView: View {

    var area: SmokingArea
    @Environment(\.modelContext) private var context

    
    var body: some View {
        NavigationStack {
            HeaderView(area: area).padding(.top, -50)
            ScrollView {
                VStack (){
                    LocationInfoView(name: area.name, location: area.location)
                    CarouselView(images: area.allPhoto.map { $0.photo })
                    CigaretteTypeView()
                    FacilitiesView(facilities: area.facilities)
                    PreferenceGaugeView()
                        .padding(.top, 5)
                    WasteBinDirectionView(photoURL: area.disposalPhotoURL, directions: area.disposalDirection)
                }
                .padding(.top, -5)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - Header (Back & Bookmark)

struct HeaderView: View {
    @Environment(\.dismiss) var dismiss
    var area: SmokingArea
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss() // Custom back action
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 10, height: 10)
                    Text("Back")
                        .font(.subheadline)
                }
                .foregroundColor(.green.mix(with: .black, by: 0.3))
                .padding()
                .background(Color.green.opacity(0.2))
                .frame(width: 85, height: 30)
                .cornerRadius(50)
            }
            Spacer()

            Button(action: {
                area.isFavorite.toggle()
                    do {
                        try context.save()
                    } catch {
                        print("Failed to save: \(error)")
                    }
            }) {
                Image(systemName: area.isFavorite ? "bookmark.fill" : "bookmark")
                    .resizable()
                    .frame(width: 20, height: 28)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
    }
}

// MARK: - Location Info
struct LocationInfoView: View {
    var name: String
    var location: String
    
    var body: some View {
        HStack {
            Text(name)
                .bold()
                .font(.title3)
            BadgeView(text: location, color: .green)
        }.padding(.bottom, -5)
    }
}

// MARK: - Cigarette Type Section
struct CigaretteTypeView: View {
    var body: some View {
        SectionView(title: "Cigarette Type") {
            HStack {
                BadgeView(text: "Cigarette", color: .orange.opacity(0.9))
                BadgeView(text: "E-Cigarette", color: .orange.opacity(0.7))
            }
            .frame(width: 340, alignment: .leading)
            .background(Color.orange.opacity(0.15))
            .cornerRadius(10)
            
        }
    }
}

// MARK: - Facilities Section
struct FacilitiesView: View {
    var facilities: [Facility]
    
    var body: some View {
        SectionView(title: "Facilities") {
            HStack {
                ForEach(facilities, id: \.name) { facility in
                    BadgeView(text: facility.name, color: .green.opacity(0.5))
                }
            }
            .frame(width: 340, alignment: .leading)
            .background(Color.green.opacity(0.15))
            .cornerRadius(10)
        }
        .padding(5)
    }
}

// MARK: - Preference Gauge
struct PreferenceGaugeView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Gauge(value: 50, in: 0...100) {
                } currentValueLabel: {
                    Text("50%")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.red.opacity(0.8))
                }
                .gaugeStyle(.accessoryCircular)
                .tint(Color.orange.opacity(0.5))

                Text("Match Your Preference")
                    .font(.headline)
                    .foregroundColor(.black)
            }

            HStack {
                PreferenceIconView(icon: "sun.max", label: "Bright")
                PreferenceIconView(icon: "moon.zzz", label: "Silent")
                PreferenceIconView(icon: "smoke", label: "Cigarette")
            }
        }
        .frame(width: 340, alignment: .leading)
    }
}

// MARK: - Waste Bin Direction
struct WasteBinDirectionView: View {
    var photoURL: String
    var directions: String

    var body: some View {
        VStack {
            Text("Waste Bin")
                .font(.body)
                .bold()
                .padding(.top, 10)
                .frame(width: 340, alignment: .leading)
                .foregroundStyle(Color.black)
            HStack {
                AsyncImage(url: URL(string: photoURL)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 140, height: 140)
                .cornerRadius(10)
                .padding(10)

                VStack(alignment: .leading) {
                    Text("Directions")
                        .font(.callout)
                        .bold()
                        .padding(.vertical, 10)
                    Text(directions)
                        .font(.caption2)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 356, height: 159)
            .background(Color.green.opacity(0.15))
            .cornerRadius(10)
        }
        .padding(10)
    }
}

// MARK: - Reusable Components

struct BadgeView: View {
    var text: String
    var color: Color

    var body: some View {
        VStack{
            Text(text)
                .font(.caption)
                .padding(5)
                .bold()
                .foregroundColor(.white)
                .background(color)
                .cornerRadius(10)
        }
        .padding(5)
        
    }
}

struct SectionView<Content: View>: View {
    var title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.body)
                .bold()
            content
        }
        .padding(5)
    }
}

struct PreferenceIconView: View {
    var icon: String
    var label: String

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.brown, lineWidth: 1.5)
                    .frame(width: 32, height: 32)
                            
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.orange)
            }
            Text(label)
                .font(.caption)
        }
        .padding(.trailing, 10)
    }
}

struct CarouselView: View {
    let images: [String]
    
    var body: some View {
        TabView {
            ForEach(images, id: \.self) { image in
                AsyncImage(url: URL(string: image)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .scaledToFill()
                .frame(width: 300, height: 200)
                .clipped()
                .cornerRadius(10)
                .padding()
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 220)
    }
}



//#Preview {
//    DetailView(area: SmokingArea(
//        name: "The Shady",
//        location: "GOP 1",
//        latitude: -6.3009886,
//        longitude: 106.6510372,
//        photoURL: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png",
//        disposalPhotoURL: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png",
//        disposalDirection: "disitu",
//        facilities: [
//            Facility(name: "Chair"),
//            Facility(name: "Waste Bin"),
//            Facility(name: "Roof")
//        ],
//        isFavorite: false,
//        allPhoto: [
//            LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"),
//            LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"),
//            LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"),
//            LocationAllPhoto(photo: "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png")
//        ]
//    ))
//}
