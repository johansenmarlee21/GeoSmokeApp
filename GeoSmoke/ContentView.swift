//
//  ContentView.swift
//  GeoSmoke
//
//  Created by Johansen Marlee on 25/03/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        Text("Hleoow orl")
    }

}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
