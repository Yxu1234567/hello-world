import SwiftUI
import Foundation
import CoreLocation

@main
struct ScavengerHuntApp: App {
    var body: some Scene {
        WindowGroup {
            TaskListView()
        }
    }
}




struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
    var photoData: Data?
    var location: CLLocationCoordinate2D?
}


struct TaskListView: View {
    @State private var tasks = [
        TaskItem(title: "Find a tree"),
        TaskItem(title: "Take a picture of water"),
        TaskItem(title: "Capture something red")
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach($tasks) { $task in
                    NavigationLink(task.title) {
                        TaskDetailView(task: $task)
                    }
                }
            }
            .navigationTitle("Scavenger Hunt")
        }
    }
}



import SwiftUI
import PhotosUI
import CoreLocation
import ImageIO

struct TaskDetailView: View {
    @Binding var task: TaskItem
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 20) {

            if let data = task.photoData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
            }

            PhotosPicker(selection: $pickerItem, matching: .images) {
                Text("Attach Photo")
                    .font(.title)
            }

            if let location = task.location {
                NavigationLink("Show Photo Location") {
                    MapView(coordinate: location)
                }
                .font(.title2)
            }
        }
        .padding()
        .onChange(of: pickerItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    task.photoData = data
                    task.location = extractGPS(from: data)
                }
            }
        }
    }

    func extractGPS(from data: Data) -> CLLocationCoordinate2D? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              let gps = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any],
              let lat = gps[kCGImagePropertyGPSLatitude as String] as? Double,
              let lon = gps[kCGImagePropertyGPSLongitude as String] as? Double
        else { return nil }

        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}



import SwiftUI
import MapKit

struct MapView: View {
    let coordinate: CLLocationCoordinate2D

    var body: some View {
        Map {
            Marker("Photo Location", coordinate: coordinate)
        }
        .navigationTitle("Photo Map")
        .navigationBarTitleDisplayMode(.inline)
    }
}




