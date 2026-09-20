import SwiftUI
import Charts
import MapKit
import CoreLocation

// MARK: - App

@main
struct StudiApp: App {
    @StateObject private var model = StudiModel()
    var body: some Scene { WindowGroup { RootView().environmentObject(model) } }
}

// MARK: - Design system

extension Color {
    static let parchment = Color(red: 247/255, green: 241/255, blue: 232/255)
    static let plum = Color(red: 74/255, green: 40/255, blue: 77/255)
    static let copper = Color(red: 201/255, green: 107/255, blue: 59/255)
    static let mauve = Color(red: 238/255, green: 229/255, blue: 233/255)
    static let ink = Color(red: 37/255, green: 31/255, blue: 34/255)
    static let muted = Color(red: 117/255, green: 102/255, blue: 107/255)
    static let border = Color(red: 225/255, green: 213/255, blue: 210/255)
}

extension View {
    @ViewBuilder
    func studiNavigationBarHidden() -> some View {
        #if os(iOS)
        self.navigationBarHidden(true)
        #else
        self
        #endif
    }

    @ViewBuilder
    func studiInlineNavigationTitle() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

struct Pill: View {
    let title: String; var active = false
    var body: some View { Text(title).font(.caption.weight(.semibold)).foregroundStyle(active ? .white : Color.plum).padding(.horizontal, 12).padding(.vertical, 8).background(active ? Color.plum : Color.mauve).clipShape(Capsule()) }
}

struct Avatar: View { let initials: String; var size: CGFloat = 30
    var body: some View { Text(initials).font(.caption.weight(.bold)).foregroundStyle(.white).frame(width: size, height: size).background(Color.copper).clipShape(Circle()).overlay(Circle().stroke(Color.parchment, lineWidth: 2)) }
}

struct StudiLogo: View {
    enum Placement { case header, loading }
    var size: CGFloat = 180
    var placement: Placement = .header
    var body: some View {
        Image(placement == .loading ? "StudiLogoLoadingFinal" : "StudiLogoHeaderFinal")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.16, style: .continuous))
            .accessibilityLabel("Studi")
    }
}

struct LaunchView: View {
    var body: some View {
        ZStack {
            Color.parchment.ignoresSafeArea()
            StudiLogo(size: 210, placement: .loading)
                .shadow(color: Color.plum.opacity(0.12), radius: 20, y: 8)
        }
    }
}

// MARK: - Seeded domain

struct Spot: Identifiable, Hashable {
    let id = UUID(); let name, building, description: String; let score: Double?; let active: Int; let vibe: String; let attributes: [String]; let quiet, crowded, productive: Double; let friends: [String]; let hours: [Hour]
    var isNew: Bool { score == nil }
    var reservationURL: URL? { ["Hayden Library", "Rotch Library"].contains(name) ? URL(string: "https://libraries.mit.edu/study/reserve/") : nil }
}
struct Hour: Identifiable, Hashable { let id = UUID(); let hour: String; let level: Int }

let seededSpots: [Spot] = [
    Spot(name: "Hayden Library", building: "Building 14 · MIT", description: "A sunlit library classic with quiet floors, deep tables, and reservable group rooms.", score: 8.8, active: 6, vibe: "Quiet now", attributes: ["Outlets", "Wi‑Fi", "Natural light", "Late night"], quiet: 9.1, crowded: 5.0, productive: 9.0, friends: ["MS", "JL"], hours: demoHours),
    Spot(name: "Rotch Library", building: "Building 7 · MIT", description: "Architecture library with soaring ceilings, excellent spaces to settle in, and reservable group spaces.", score: 8.5, active: 4, vibe: "Moderate now", attributes: ["Outlets", "Whiteboards", "Group OK"], quiet: 8.2, crowded: 5.8, productive: 8.6, friends: ["AK"], hours: demoHours),
    Spot(name: "Barker Library", building: "Building 10 · MIT", description: "Under the dome: ornate, hushed, and perfect for a no-distractions session.", score: 9.0, active: 2, vibe: "Quiet now", attributes: ["Outlets", "Wi‑Fi", "Natural light"], quiet: 9.4, crowded: 4.3, productive: 9.2, friends: ["MS"], hours: demoHours),
    Spot(name: "Stata Center Student Street", building: "Building 32 · MIT", description: "Lively open seating with coffee nearby and room for collaboration.", score: 7.9, active: 8, vibe: "Busy now", attributes: ["Food", "Outlets", "Group OK", "Whiteboards"], quiet: 5.9, crowded: 8.1, productive: 7.8, friends: ["JL", "AK"], hours: demoHours),
    Spot(name: "Tatte Kendall", building: "325 Main St · Kendall", description: "A bright café for a productive coffee study break.", score: 8.1, active: 5, vibe: "Moderate now", attributes: ["Food", "Outlets", "Public access"], quiet: 6.5, crowded: 6.4, productive: 8.0, friends: [], hours: demoHours),
    Spot(name: "Lobby 10", building: "Building 10 · MIT", description: "Historic lobby tables for an in-between-classes study sprint.", score: 7.7, active: 3, vibe: "Moderate now", attributes: ["Outlets", "Public access", "Natural light"], quiet: 6.7, crowded: 7.0, productive: 7.5, friends: ["AK"], hours: demoHours),
    Spot(name: "Flour Bakery", building: "Central Square", description: "Warm coffee-shop tables for a quick, delicious study session.", score: 7.8, active: 1, vibe: "Moderate now", attributes: ["Food", "Outlets", "Public access"], quiet: 6.1, crowded: 6.3, productive: 7.4, friends: [], hours: demoHours),
    Spot(name: "Simmons Hall Lounge", building: "Building 229 · MIT", description: "Cozy dorm lounge with late-night energy and plenty of tables.", score: nil, active: 0, vibe: "Quiet now", attributes: ["Outlets", "Late night", "Group OK"], quiet: 7.4, crowded: 4.0, productive: 7.8, friends: [], hours: demoHours),
    Spot(name: "Hayden Lounge", building: "Building 14 · MIT", description: "Soft seating just off Hayden for a relaxed reading session.", score: 8.2, active: 3, vibe: "Moderate now", attributes: ["Outlets", "Wi‑Fi", "Natural light"], quiet: 7.7, crowded: 5.6, productive: 8.1, friends: [], hours: demoHours),
    Spot(name: "Building 7 Lobby", building: "Building 7 · MIT", description: "A central, elegant table spot with a steady campus hum.", score: 7.6, active: 4, vibe: "Busy now", attributes: ["Outlets", "Public access", "Natural light"], quiet: 6.3, crowded: 7.3, productive: 7.1, friends: [], hours: demoHours),
    Spot(name: "Student Center, 5th Floor", building: "W20 · MIT", description: "A practical group-work floor with quick food access.", score: 7.4, active: 7, vibe: "Busy now", attributes: ["Food", "Outlets", "Group OK"], quiet: 5.8, crowded: 8.0, productive: 7.6, friends: [], hours: demoHours),
    Spot(name: "Darwin’s", building: "Harvard Square", description: "Neighborhood café tables and a welcoming all-afternoon pace.", score: 7.9, active: 2, vibe: "Moderate now", attributes: ["Food", "Outlets", "Public access"], quiet: 6.6, crowded: 5.9, productive: 7.7, friends: [], hours: demoHours),
    Spot(name: "1369 Coffeehouse", building: "Central Square", description: "A cozy, dependable coffee study destination.", score: 8.0, active: 3, vibe: "Moderate now", attributes: ["Food", "Outlets", "Public access"], quiet: 6.8, crowded: 6.2, productive: 7.9, friends: [], hours: demoHours),
    Spot(name: "Cafe Luna", building: "Central Square", description: "Sunny café seating, ideal for a short productive break.", score: 7.3, active: 1, vibe: "Moderate now", attributes: ["Food", "Public access"], quiet: 6.0, crowded: 6.4, productive: 7.0, friends: [], hours: demoHours),
    Spot(name: "Area Four", building: "Technology Square", description: "Spacious pizza café with friendly group tables.", score: 7.5, active: 4, vibe: "Busy now", attributes: ["Food", "Outlets", "Group OK", "Public access"], quiet: 5.9, crowded: 7.0, productive: 7.4, friends: [], hours: demoHours),
    Spot(name: "Harvard Book Store Cafe", building: "Harvard Square", description: "A bookish, low-key setting for thoughtful work.", score: 8.3, active: 0, vibe: "Quiet now", attributes: ["Food", "Public access", "Natural light"], quiet: 8.3, crowded: 4.8, productive: 8.2, friends: [], hours: demoHours),
    Spot(name: "Pavement Coffeehouse", building: "Harvard Square", description: "Well-loved coffee, communal tables, and lively energy.", score: 7.7, active: 5, vibe: "Busy now", attributes: ["Food", "Outlets", "Public access"], quiet: 5.7, crowded: 7.5, productive: 7.5, friends: [], hours: demoHours),
    Spot(name: "Toscanino’s", building: "Kendall Square", description: "A sweet escape for a quick session near campus.", score: nil, active: 0, vibe: "Quiet now", attributes: ["Food", "Public access"], quiet: 7.0, crowded: 4.4, productive: 7.1, friends: [], hours: demoHours),
    Spot(name: "MIT Museum Cafe", building: "Kendall Square", description: "Modern museum café tables with a peaceful daytime flow.", score: 7.8, active: 3, vibe: "Moderate now", attributes: ["Food", "Outlets", "Public access"], quiet: 7.1, crowded: 5.4, productive: 7.9, friends: [], hours: demoHours),
    Spot(name: "Kendall/MIT Open Space", building: "Kendall Square", description: "Fresh-air tables for an energizing study reset.", score: 7.2, active: 2, vibe: "Moderate now", attributes: ["Public access", "Natural light", "Group OK"], quiet: 6.4, crowded: 5.9, productive: 7.0, friends: [], hours: demoHours)
]
let demoHours = [Hour(hour: "8a", level: 2), Hour(hour: "10a", level: 4), Hour(hour: "12p", level: 7), Hour(hour: "2p", level: 8), Hour(hour: "4p", level: 6), Hour(hour: "6p", level: 5), Hour(hour: "8p", level: 7), Hour(hour: "10p", level: 3)]

extension Spot {
    var coordinate: CLLocationCoordinate2D {
        let locations: [String: CLLocationCoordinate2D] = [
            "Hayden Library": .init(latitude: 42.3592, longitude: -71.0927),
            "Rotch Library": .init(latitude: 42.3595, longitude: -71.0921),
            "Barker Library": .init(latitude: 42.3587, longitude: -71.0934),
            "Stata Center Student Street": .init(latitude: 42.3615, longitude: -71.0905),
            "Tatte Kendall": .init(latitude: 42.3620, longitude: -71.0867),
            "Lobby 10": .init(latitude: 42.3594, longitude: -71.0938),
            "Flour Bakery": .init(latitude: 42.3653, longitude: -71.1033),
            "Simmons Hall Lounge": .init(latitude: 42.3573, longitude: -71.1017),
            "Darwin’s": .init(latitude: 42.3735, longitude: -71.1203),
            "1369 Coffeehouse": .init(latitude: 42.3668, longitude: -71.1055),
            "Cafe Luna": .init(latitude: 42.3635, longitude: -71.1016),
            "Area Four": .init(latitude: 42.3630, longitude: -71.0877),
            "Harvard Book Store Cafe": .init(latitude: 42.3727, longitude: -71.1166),
            "Pavement Coffeehouse": .init(latitude: 42.3730, longitude: -71.1182),
            "Toscanino’s": .init(latitude: 42.3654, longitude: -71.0832),
            "MIT Museum Cafe": .init(latitude: 42.3624, longitude: -71.0857)
        ]
        if let location = locations[name] { return location }
        let offset = Double(abs(name.hashValue % 8)) * 0.0013
        return .init(latitude: 42.355 + offset, longitude: -71.101 + offset)
    }
}

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var location: CLLocationCoordinate2D?
    @Published private(set) var locationError: CLError?
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        #if os(macOS)
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        #else
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            manager.requestLocation()
        default:
            break
        }
        #endif
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        #if os(macOS)
        manager.startUpdatingLocation()
        #else
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            manager.requestLocation()
        }
        #endif
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self.location = locations.last?.coordinate
            self.locationError = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { self.locationError = error as? CLError }
    }
}

enum ExploreSort: String, CaseIterable, Identifiable {
    case recommended = "Recommended"
    case nearest = "Nearest"
    case highestRated = "Highest rating"
    case quietest = "Quietest"
    case busiest = "Busiest"
    var id: String { rawValue }
}

struct CommunityUser: Identifiable, Hashable {
    let initials: String
    let name: String
    let subtitle: String
    let bio: String
    let followers: Int
    let following: Int
    let favoriteSpot: String
    var id: String { initials }
}

let communityUsers = [
    CommunityUser(initials: "MS", name: "Maya Singh", subtitle: "MIT · Class of 2027", bio: "Always looking for the sunniest quiet corner on campus.", followers: 128, following: 94, favoriteSpot: "Hayden Library"),
    CommunityUser(initials: "SL", name: "Sam Lee", subtitle: "MIT · Class of 2026", bio: "Problem sets, espresso, and late-night sessions.", followers: 86, following: 72, favoriteSpot: "Stata Center Student Street"),
    CommunityUser(initials: "JL", name: "Jordan Lee", subtitle: "MIT · Class of 2028", bio: "Architecture student and coffee-shop study regular.", followers: 63, following: 81, favoriteSpot: "Rotch Library")
]

struct FeedEvent: Identifiable {
    let user: CommunityUser
    let message: String
    let metadata: String
    let spotName: String?
    var id: String { user.id + message }
}

final class StudiModel: ObservableObject {
    @Published var selectedTab = 0; @Published var activeSession: Spot?; @Published var sessionStart = Date(); @Published var favorites: Set<UUID> = []; @Published var wantToTry: Set<UUID> = []; @Published var completedSpot: Spot?; @Published var followedUsers: Set<String> = ["MS"]
    func begin(_ spot: Spot) { activeSession = spot; sessionStart = Date() }
    func finish() { completedSpot = activeSession; activeSession = nil }
    func isFollowing(_ user: CommunityUser) -> Bool { followedUsers.contains(user.id) }
    func toggleFollow(_ user: CommunityUser) { if followedUsers.contains(user.id) { followedUsers.remove(user.id) } else { followedUsers.insert(user.id) } }
    func refresh() async { try? await Task.sleep(nanoseconds: 600_000_000) }
}

// MARK: - Root and Explore

struct RootView: View {
    @EnvironmentObject var model: StudiModel
    @StateObject private var locationManager = LocationManager()
    @State private var isLaunching = true
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Group {
                    switch model.selectedTab {
                    case 0: ExploreView()
                    case 1: FeedView()
                    default: ProfileView()
                    }
                }
                Divider().overlay(Color.border)
                HStack(spacing: 0) {
                    RootTabButton(title: "Explore", icon: "map", selected: model.selectedTab == 0) { model.selectedTab = 0 }
                    RootTabButton(title: "Feed", icon: "rectangle.stack", selected: model.selectedTab == 1) { model.selectedTab = 1 }
                    RootTabButton(title: "Profile", icon: "person", selected: model.selectedTab == 2) { model.selectedTab = 2 }
                }
                .padding(.vertical, 8)
                .background(Color.parchment)
            }
            .environmentObject(locationManager)
            .opacity(isLaunching ? 0 : 1)
            if model.activeSession != nil && !isLaunching { TimerOverlay() }
            LaunchView().opacity(isLaunching ? 1 : 0).allowsHitTesting(isLaunching)
        }.preferredColorScheme(.light).task {
            locationManager.requestLocation()
            try? await Task.sleep(nanoseconds: 900_000_000)
            withAnimation(.easeInOut(duration: 0.65)) { isLaunching = false }
        }
    }
}

struct RootTabButton: View {
    let title, icon: String
    let selected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.subheadline.weight(.semibold))
                Text(title).font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(selected ? Color.plum : Color.muted)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct ExploreView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var model: StudiModel
    @State private var search = ""; @State private var mapMode = false; @State private var selectedIntent = "Quiet focus"; @State private var activeFilters: Set<String> = []; @State private var sort = ExploreSort.recommended
    private let intents = ["Quiet focus", "Group work", "Quick session", "Late-night", "Coffee study"]
    private var spots: [Spot] {
        let filtered = seededSpots.filter { spot in
        (search.isEmpty || spot.name.localizedCaseInsensitiveContains(search) || spot.building.localizedCaseInsensitiveContains(search)) &&
        (!activeFilters.contains("Quiet now") || spot.vibe == "Quiet now") &&
        activeFilters.filter { ["Outlets", "Food", "Group OK", "Public access", "Late night"].contains($0) }.allSatisfy { spot.attributes.contains($0) }
        }
        return filtered.sorted { first, second in
            switch sort {
            case .recommended:
                return first.productive + first.quiet > second.productive + second.quiet
            case .nearest:
                let origin = locationManager.location ?? CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0942)
                let firstDistance = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude).distance(from: CLLocation(latitude: origin.latitude, longitude: origin.longitude))
                let secondDistance = CLLocation(latitude: second.coordinate.latitude, longitude: second.coordinate.longitude).distance(from: CLLocation(latitude: origin.latitude, longitude: origin.longitude))
                return firstDistance < secondDistance
            case .highestRated:
                return (first.score ?? 0) > (second.score ?? 0)
            case .quietest:
                return first.quiet > second.quiet
            case .busiest:
                return first.active > second.active
            }
        }
    }
    private func toggle(_ filter: String) { if activeFilters.contains(filter) { activeFilters.remove(filter) } else { activeFilters.insert(filter) } }
    var body: some View {
        NavigationStack {
            ScrollView { VStack(alignment: .leading, spacing: 18) {
                header
                HStack { Image(systemName: "magnifyingglass"); TextField("Search spots or buildings", text: $search) }.padding(12).background(.white).clipShape(RoundedRectangle(cornerRadius: 14)).overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.border))
                ScrollView(.horizontal, showsIndicators: false) { HStack { ForEach(["Outlets", "Food", "Quiet now", "Open now", "Group OK", "Public access", "Late night"], id: \.self) { item in Button { toggle(item) } label: { Pill(title: item, active: activeFilters.contains(item)) } } } }
                recommendation
                HStack {
                    HStack(spacing: 3) {
                        Button { mapMode = false } label: { Text("List").font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity).padding(.vertical, 9).foregroundStyle(mapMode ? Color.muted : .white).background(mapMode ? Color.clear : Color.plum).clipShape(Capsule()) }
                        Button { mapMode = true } label: { Text("Map").font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity).padding(.vertical, 9).foregroundStyle(mapMode ? .white : Color.muted).background(mapMode ? Color.plum : Color.clear).clipShape(Capsule()) }
                    }
                    .padding(3)
                    .background(Color.mauve)
                    .clipShape(Capsule())
                    .buttonStyle(.plain)
                    Menu { Picker("Sort", selection: $sort) { ForEach(ExploreSort.allCases) { Text($0.rawValue).tag($0) } } } label: { Label("Sort", systemImage: "arrow.up.arrow.down").font(.subheadline.weight(.semibold)).foregroundStyle(Color.plum).padding(.horizontal, 10).padding(.vertical, 8).background(Color.mauve).clipShape(Capsule()) }
                }
                Text("\(spots.count) matching study spots · \(sort.rawValue)").font(.subheadline).foregroundStyle(Color.muted)
                if mapMode { MapDemo(spots: spots) } else { LazyVStack(spacing: 14) { ForEach(spots) { SpotCard(spot: $0) } } }
            }
            }
            .padding(16)
            .background(Color.parchment)
            .studiNavigationBarHidden()
            .task { locationManager.requestLocation() }
            .refreshable { await model.refresh() }
            .navigationDestination(for: Spot.self) { SpotDetail(spot: $0) }
        }
    }
    var header: some View { HStack { HStack(spacing: 9) { StudiLogo(size: 74, placement: .header).padding(.top, 2); VStack(alignment: .leading, spacing: 2) { Text("Where are you studying today?").foregroundStyle(Color.muted) } }; Spacer(); Avatar(initials: "LM", size: 38) } }
    var recommendation: some View { VStack(alignment: .leading, spacing: 12) { Text("Where should I go?").font(.title3.weight(.bold)).foregroundStyle(Color.ink); ScrollView(.horizontal, showsIndicators: false) { HStack { ForEach(intents, id: \.self) { intent in Button { selectedIntent = intent } label: { Pill(title: intent, active: selectedIntent == intent) } } } }; HStack(spacing: 14) { Image(systemName: selectedIntent == "Coffee study" ? "cup.and.saucer.fill" : "books.vertical.fill").font(.title).foregroundStyle(Color.copper).frame(width: 46, height: 46).background(Color.mauve).clipShape(RoundedRectangle(cornerRadius: 12)); VStack(alignment: .leading) { Text(selectedIntent == "Coffee study" ? "Tatte Kendall" : "Hayden Library").font(.headline); Text(selectedIntent == "Coffee study" ? "Great coffee, outlets, and a productive buzz." : "Quiet now, plenty of outlets, and one of your highest-rated focus spots.").font(.caption).foregroundStyle(Color.muted) }; Spacer(); Image(systemName: "arrow.right") } }.padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius: 20)).overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.border)) }
}

struct SpotCard: View { let spot: Spot
    var body: some View { NavigationLink(value: spot) { HStack(alignment: .top, spacing: 12) { ScoreBadge(spot: spot); VStack(alignment: .leading, spacing: 6) { Text(spot.name).font(.headline).foregroundStyle(Color.ink); Text(spot.building).font(.caption).foregroundStyle(Color.muted); Text(spot.vibe + (spot.active >= 3 ? " · \(spot.active) studying" : "")).font(.caption.weight(.semibold)).foregroundStyle(spot.vibe == "Busy now" ? Color.copper : Color.plum); HStack { ForEach(spot.attributes.prefix(3), id: \.self) { Text($0).font(.caption2).foregroundStyle(Color.muted) } } }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(Color.muted) } .padding(14).background(.white).clipShape(RoundedRectangle(cornerRadius: 18)).overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.border)) } }
}

struct ScoreBadge: View { let spot: Spot
    var body: some View { VStack(spacing: 1) { Text(spot.score.map { String(format: "%.1f", $0) } ?? "New").font(.system(size: spot.isNew ? 14 : 21, weight: .bold, design: .serif)); Text("score").font(.system(size: 9, weight: .semibold)) }.foregroundStyle(.white).frame(width: 55, height: 55).background(Color.plum).clipShape(RoundedRectangle(cornerRadius: 14)) }
}

struct MapDemo: View {
    let spots: [Spot]
    @EnvironmentObject var locationManager: LocationManager
    @State private var selected: Spot?
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(center: .init(latitude: 42.3617, longitude: -71.0965), span: .init(latitudeDelta: 0.028, longitudeDelta: 0.038))
    )
    @State private var visibleRegion = MKCoordinateRegion(center: .init(latitude: 42.3617, longitude: -71.0965), span: .init(latitudeDelta: 0.028, longitudeDelta: 0.038))

    var body: some View {
        Map(position: $position, interactionModes: .all) {
            if let coordinate = locationManager.location {
                Annotation("Your location", coordinate: coordinate, anchor: .center) {
                    CurrentLocationMarker()
                }
            }
            ForEach(spots) { spot in
                Annotation(spot.name, coordinate: spot.coordinate, anchor: .bottom) {
                    Button { selected = spot } label: { MapScorePin(spot: spot) }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls { MapCompass(); MapScaleView() }
        .onMapCameraChange(frequency: .onEnd) { context in visibleRegion = context.region }
        .frame(height: 480)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.border, lineWidth: 1))
        .overlay(alignment: .topLeading) {
            VStack(spacing: 10) {
                VStack(spacing: 1) {
                    Button { changeZoom(by: 0.65) } label: { Image(systemName: "plus").font(.headline.weight(.bold)).frame(width: 42, height: 38) }
                    Divider().frame(width: 42)
                    Button { changeZoom(by: 1.55) } label: { Image(systemName: "minus").font(.headline.weight(.bold)).frame(width: 42, height: 38) }
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                Button { recenterOnUser() } label: { Image(systemName: "location.fill").font(.headline.weight(.bold)).frame(width: 42, height: 42) }
                    .background(.white)
                    .clipShape(Circle())
            }
            .foregroundStyle(Color.plum)
            .shadow(radius: 3)
            .padding(12)
        }
        .sheet(item: $selected) { spot in
            NavigationStack {
                VStack(alignment: .leading, spacing: 14) {
                    HStack { ScoreBadge(spot: spot); VStack(alignment: .leading) { Text(spot.name).font(.title3.weight(.bold)); Text(spot.building).font(.subheadline).foregroundStyle(Color.muted) }; Spacer() }
                    Text(spot.description).font(.subheadline).foregroundStyle(Color.muted)
                    Text(spot.active >= 3 ? "\(spot.active) people studying here now" : spot.vibe).font(.subheadline.weight(.semibold)).foregroundStyle(Color.copper)
                    Text(spot.attributes.prefix(3).joined(separator: " · ")).font(.caption.weight(.semibold)).foregroundStyle(Color.plum)
                    NavigationLink { SpotDetail(spot: spot) } label: { Text("View spot").font(.headline).frame(maxWidth: .infinity).padding().foregroundStyle(.white).background(Color.plum).clipShape(RoundedRectangle(cornerRadius: 14)) }
                }.padding(20).presentationDetents([.height(300)])
            }
        }
        .onAppear { locationManager.requestLocation() }
        .onReceive(locationManager.$location.compactMap { $0 }) { coordinate in
            visibleRegion = MKCoordinateRegion(center: coordinate, span: .init(latitudeDelta: 0.018, longitudeDelta: 0.026))
            position = .region(visibleRegion)
        }
    }

    private func changeZoom(by factor: CLLocationDegrees) {
        visibleRegion.span.latitudeDelta = min(max(visibleRegion.span.latitudeDelta * factor, 0.002), 0.18)
        visibleRegion.span.longitudeDelta = min(max(visibleRegion.span.longitudeDelta * factor, 0.002), 0.18)
        position = .region(visibleRegion)
    }

    private func recenterOnUser() {
        locationManager.requestLocation()
        guard let coordinate = locationManager.location else { return }
        visibleRegion = MKCoordinateRegion(center: coordinate, span: .init(latitudeDelta: 0.018, longitudeDelta: 0.026))
        position = .region(visibleRegion)
    }
}

struct MapScorePin: View {
    let spot: Spot
    var body: some View {
        Text(spot.score.map { String(format: "%.1f", $0) } ?? "New")
            .font(.system(size: 15, weight: .bold, design: .serif))
            .foregroundStyle(.white)
            .padding(.horizontal, 11).padding(.vertical, 9)
            .background(Color.plum).clipShape(Capsule())
            .overlay(Capsule().stroke(Color.parchment, lineWidth: 3)).shadow(radius: 3)
    }
}

struct CurrentLocationMarker: View {
    var body: some View {
        Circle()
            .fill(Color.copper)
            .frame(width: 18, height: 18)
            .overlay(Circle().stroke(.white, lineWidth: 4))
            .shadow(color: Color.ink.opacity(0.3), radius: 3)
            .accessibilityLabel("Your location")
    }
}

// MARK: - Detail and session

struct SpotDetail: View { let spot: Spot; @EnvironmentObject var model: StudiModel
    var body: some View { ScrollView { VStack(alignment: .leading, spacing: 20) { ZStack(alignment: .bottomLeading) { LinearGradient(colors: [Color.plum, Color.copper.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing).frame(height: 210); VStack(alignment: .leading) { Text(spot.name).font(.system(size: 30, weight: .bold, design: .serif)).foregroundStyle(.white); Text(spot.building).foregroundStyle(.white.opacity(0.8)) }.padding(18) }.clipShape(RoundedRectangle(cornerRadius: 24)); HStack { ScoreBadge(spot: spot); VStack(alignment: .leading) { Text(spot.vibe).font(.headline).foregroundStyle(Color.plum); Text(spot.active >= 3 ? "\(spot.active) people studying here now" : "A calm place to study right now").font(.caption).foregroundStyle(Color.muted) }; Spacer(); Button { if model.favorites.contains(spot.id) { model.favorites.remove(spot.id) } else { model.favorites.insert(spot.id) } } label: { Image(systemName: model.favorites.contains(spot.id) ? "heart.fill" : "heart").foregroundStyle(Color.copper).padding(10).background(Color.mauve).clipShape(Circle()) } }; HStack { Button { if model.wantToTry.contains(spot.id) { model.wantToTry.remove(spot.id) } else { model.wantToTry.insert(spot.id) } } label: { Label(model.wantToTry.contains(spot.id) ? "Want to try saved" : "Want to try", systemImage: model.wantToTry.contains(spot.id) ? "bookmark.fill" : "bookmark").font(.subheadline.weight(.semibold)).foregroundStyle(Color.plum).padding(.horizontal, 14).padding(.vertical, 10).background(Color.mauve).clipShape(Capsule()) }; Spacer() }; Text(spot.description).foregroundStyle(Color.muted); if let reservationURL = spot.reservationURL { Link(destination: reservationURL) { Label("Reserve a study room", systemImage: "calendar.badge.plus").font(.subheadline.weight(.semibold)).foregroundStyle(Color.plum).padding(.horizontal, 14).padding(.vertical, 10).background(Color.mauve).clipShape(Capsule()) } }; HStack { ForEach(spot.attributes, id: \.self) { Pill(title: $0) } }.fixedSize(horizontal: false, vertical: true); VStack(alignment: .leading) { Text("Study insight").font(.title3.weight(.bold)); HStack { MiniScore(title: "Quiet", score: spot.quiet); MiniScore(title: "Crowded", score: spot.crowded); MiniScore(title: "Productive", score: spot.productive) } }; VStack(alignment: .leading) { Text("Busyness by hour").font(.title3.weight(.bold)); Chart(spot.hours) { BarMark(x: .value("Hour", $0.hour), y: .value("Activity", $0.level)).foregroundStyle(Color.copper) }.frame(height: 130) }.padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius: 18)); if !spot.friends.isEmpty { VStack(alignment: .leading) { Text("Friends have been here").font(.title3.weight(.bold)); HStack { ForEach(spot.friends, id: \.self) { Avatar(initials: $0) }; Text("Friends rated this a favorite").font(.caption).foregroundStyle(Color.muted) } } }; Button { model.begin(spot) } label: { Label("I’m studying here", systemImage: "timer").font(.headline).frame(maxWidth: .infinity).padding().background(Color.plum).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 16)) } }.padding(16) }.background(Color.parchment).studiInlineNavigationTitle() }
}
struct MiniScore: View { let title: String; let score: Double
    var body: some View { VStack { Text(String(format: "%.1f", score)).font(.title2.weight(.bold)).foregroundStyle(Color.plum); Text(title).font(.caption).foregroundStyle(Color.muted) }.frame(maxWidth: .infinity).padding(.vertical, 10).background(Color.mauve).clipShape(RoundedRectangle(cornerRadius: 12)) }
}

struct TimerOverlay: View { @EnvironmentObject var model: StudiModel; @State private var checkout = false
    var body: some View { if let spot = model.activeSession { ZStack { Color.parchment.ignoresSafeArea(); VStack(spacing: 24) { Spacer(); Text("studying at").font(.headline).foregroundStyle(Color.muted); Text(spot.name).font(.system(size: 30, weight: .bold, design: .serif)).multilineTextAlignment(.center).foregroundStyle(Color.plum); TimelineView(.periodic(from: .now, by: 1)) { _ in Text(elapsed).font(.system(size: 66, weight: .medium, design: .rounded)).monospacedDigit().foregroundStyle(Color.copper) }; Text("Stay present. Your session is safely running.").font(.subheadline).foregroundStyle(Color.muted); Spacer(); Button("End session") { checkout = true }.font(.headline).frame(maxWidth: .infinity).padding().foregroundStyle(.white).background(Color.plum).clipShape(RoundedRectangle(cornerRadius: 16)); Button("Keep studying") { }.foregroundStyle(Color.plum) }.padding(24) }.sheet(isPresented: $checkout) { CheckoutView(spot: spot) } } }
    var elapsed: String { let secs = max(1, Int(Date().timeIntervalSince(model.sessionStart))); return String(format: "%02d:%02d", secs / 60, secs % 60) }
}

struct CheckoutView: View { let spot: Spot; @EnvironmentObject var model: StudiModel; @Environment(\.dismiss) var dismiss; @State private var sentiment = "Loved it"; @State private var quiet = 8.0; @State private var productive = 8.0; @State private var pickedNewSpot = true; @State private var note = ""; @State private var ranked = false
    var comparisonSpot: Spot { seededSpots.first(where: { $0.id != spot.id }) ?? spot }
    var body: some View { NavigationStack { ScrollView { VStack(alignment: .leading, spacing: 20) { if ranked { VStack(spacing: 14) { Image(systemName: "checkmark.seal.fill").font(.system(size: 56)).foregroundStyle(Color.copper); Text("Added to your ranking").font(.system(size: 28, weight: .bold, design: .serif)); Text("\(spot.name) is now your #3 quiet-focus study spot.").multilineTextAlignment(.center).foregroundStyle(Color.muted); Button("Done") { model.finish(); dismiss() }.buttonStyle(.borderedProminent).tint(Color.plum) } .frame(maxWidth: .infinity).padding(.top, 80) } else { Text("How was your session?").font(.system(size: 28, weight: .bold, design: .serif)); Text("Your comparisons shape personal scores—no direct overall rating.").foregroundStyle(Color.muted); HStack(spacing: 0) { ForEach(["Loved it", "Fine", "Didn’t like it"], id: \.self) { option in Button(option) { sentiment = option }.font(.caption.weight(.semibold)).foregroundStyle(sentiment == option ? .white : Color.plum).frame(maxWidth: .infinity).padding(.vertical, 10).background(sentiment == option ? Color.plum : Color.mauve).clipShape(Capsule()).buttonStyle(.plain) } }.padding(3).background(Color.mauve).clipShape(Capsule()); RatingSlider(title: "Quiet", value: $quiet); RatingSlider(title: "Productivity", value: $productive); VStack(alignment: .leading) { Text("Quick comparison").font(.headline); Text("Which was better for quiet focus?").font(.subheadline).foregroundStyle(Color.muted); HStack { Choice(title: spot.name, selected: pickedNewSpot) { pickedNewSpot = true }; Choice(title: comparisonSpot.name, selected: !pickedNewSpot) { pickedNewSpot = false } } }.padding(16).background(Color.mauve).clipShape(RoundedRectangle(cornerRadius: 18)); VStack(alignment: .leading, spacing: 8) { Text("Add a note").font(.headline); TextEditor(text: $note).frame(height: 96).padding(8).background(.white).clipShape(RoundedRectangle(cornerRadius: 12)).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.border)); Text("Optional — share a detail you’ll remember.").font(.caption).foregroundStyle(Color.muted) }; Button("Save & rank spot") { ranked = true }.font(.headline).frame(maxWidth: .infinity).padding().foregroundStyle(.white).background(Color.plum).clipShape(RoundedRectangle(cornerRadius: 16)) } }.padding(20) }.background(Color.parchment).navigationTitle("Check out").studiInlineNavigationTitle() } }
}
struct RatingSlider: View { let title: String; @Binding var value: Double
    var body: some View { VStack(alignment: .leading) { HStack { Text(title).font(.headline); Spacer(); Text(String(format: "%.0f / 10", value)).foregroundStyle(Color.copper).fontWeight(.bold) }; Slider(value: $value, in: 1...10, step: 1).tint(Color.copper) } }
}
struct Choice: View { let title: String; let selected: Bool; let action: () -> Void
    var body: some View { Button(action: action) { Text(title).font(.caption.weight(.semibold)).multilineTextAlignment(.center).frame(maxWidth: .infinity).padding().foregroundStyle(selected ? .white : Color.plum).background(selected ? Color.plum : .white).clipShape(RoundedRectangle(cornerRadius: 12)) } }
}

// MARK: - Community

struct FeedView: View { @EnvironmentObject var model: StudiModel
    @State private var searchText = ""
    let events = [
        FeedEvent(user: communityUsers[0], message: "studied 2h at", metadata: "Today · MIT", spotName: "Hayden Library"),
        FeedEvent(user: communityUsers[1], message: "reached a 12-day streak.", metadata: "Today · MIT", spotName: nil),
        FeedEvent(user: communityUsers[2], message: "added", metadata: "Yesterday · MIT", spotName: "Rotch Library")
    ]
    var followedEvents: [FeedEvent] { events.filter { model.isFollowing($0.user) } }
    var matchingUsers: [CommunityUser] { communityUsers.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.subtitle.localizedCaseInsensitiveContains(searchText) } }
    var matchingSpots: [Spot] { seededSpots.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.building.localizedCaseInsensitiveContains(searchText) } }
    var body: some View { NavigationStack { ScrollView { VStack(alignment: .leading, spacing: 18) { if searchText.isEmpty { followingContent } else { searchResults } }.padding(16) }.background(Color.parchment).refreshable { await model.refresh() }.searchable(text: $searchText, prompt: "Search people or study spots").studiNavigationBarHidden() } }
    @ViewBuilder var followingContent: some View { Text("Following").font(.system(size: 30, weight: .bold, design: .serif)).foregroundStyle(Color.plum); Text("Activity from people you follow.").font(.subheadline).foregroundStyle(Color.muted); if followedEvents.isEmpty { ContentUnavailableView("Your feed is waiting", systemImage: "person.2", description: Text("Follow classmates from your profile to see their study activity here.")).frame(maxWidth: .infinity).padding(.vertical, 48) } else { ForEach(followedEvents) { event in FeedEventCard(event: event) } } }
    @ViewBuilder var searchResults: some View { Text("Search").font(.system(size: 30, weight: .bold, design: .serif)).foregroundStyle(Color.plum); if !matchingUsers.isEmpty { Text("People").font(.headline).foregroundStyle(Color.muted); ForEach(matchingUsers) { user in NavigationLink { CommunityProfileView(user: user) } label: { HStack(spacing: 12) { Avatar(initials: user.initials, size: 42); VStack(alignment: .leading) { Text(user.name).font(.headline).foregroundStyle(Color.ink); Text(user.subtitle).font(.caption).foregroundStyle(Color.muted) }; Spacer(); Text(model.isFollowing(user) ? "Following" : "View").font(.caption.weight(.semibold)).foregroundStyle(Color.plum) }.padding(14).background(.white).clipShape(RoundedRectangle(cornerRadius: 18)) } } }; if !matchingSpots.isEmpty { Text("Study spots").font(.headline).foregroundStyle(Color.muted).padding(.top, 4); ForEach(matchingSpots) { spot in SpotCard(spot: spot) } }; if matchingUsers.isEmpty && matchingSpots.isEmpty { ContentUnavailableView.search(text: searchText).frame(maxWidth: .infinity).padding(.vertical, 48) } }
}

struct FeedEventCard: View { let event: FeedEvent
    var body: some View { HStack(alignment: .top, spacing: 12) { NavigationLink { CommunityProfileView(user: event.user) } label: { Avatar(initials: event.user.initials, size: 42) }; VStack(alignment: .leading, spacing: 5) { HStack(spacing: 4) { NavigationLink(event.user.name) { CommunityProfileView(user: event.user) }.fontWeight(.semibold).foregroundStyle(Color.ink); Text(event.message).foregroundStyle(Color.ink) }.font(.subheadline); if let spotName = event.spotName, let spot = seededSpots.first(where: { $0.name == spotName }) { NavigationLink { SpotDetail(spot: spot) } label: { Label(spotName, systemImage: "mappin.and.ellipse").font(.subheadline.weight(.semibold)).foregroundStyle(Color.plum) } }; Text(event.metadata).font(.caption).foregroundStyle(Color.muted) }; Spacer() }.padding(15).background(.white).clipShape(RoundedRectangle(cornerRadius: 18)).overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.border)) }
}

struct CommunityProfileView: View {
    let user: CommunityUser
    @EnvironmentObject var model: StudiModel
    var body: some View { ScrollView { VStack(spacing: 20) { Avatar(initials: user.initials, size: 78); VStack(spacing: 4) { Text(user.name).font(.system(size: 28, weight: .bold, design: .serif)).foregroundStyle(Color.ink); Text(user.subtitle).foregroundStyle(Color.muted); Text(user.bio).font(.subheadline).multilineTextAlignment(.center).foregroundStyle(Color.muted).padding(.top, 4) }; Button { model.toggleFollow(user) } label: { Label(model.isFollowing(user) ? "Following" : "Follow", systemImage: model.isFollowing(user) ? "checkmark" : "person.badge.plus").font(.headline).frame(maxWidth: .infinity).padding().foregroundStyle(model.isFollowing(user) ? Color.plum : .white).background(model.isFollowing(user) ? Color.mauve : Color.plum).clipShape(RoundedRectangle(cornerRadius: 16)) }; HStack { Stat(value: "\(user.followers + (model.isFollowing(user) ? 1 : 0))", label: "followers"); Stat(value: "\(user.following)", label: "following"); Stat(value: "8", label: "day streak", copper: true) }.padding(.vertical, 4); VStack(alignment: .leading, spacing: 8) { Text("Study style").font(.title3.weight(.bold)); Text("Top spot: \(user.favoriteSpot)").foregroundStyle(Color.muted); Text("Recently active around MIT and Cambridge.").font(.subheadline).foregroundStyle(Color.muted) }.frame(maxWidth: .infinity, alignment: .leading).padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius: 20)).overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.border)) }.padding(16) }.background(Color.parchment).navigationTitle(user.name).studiInlineNavigationTitle() }
}
struct ProfileView: View { @EnvironmentObject var model: StudiModel
    var suggestions: [CommunityUser] { communityUsers.filter { !model.isFollowing($0) } }
    var rankedSpots: [Spot] { seededSpots.filter { $0.score != nil }.sorted { ($0.score ?? 0) > ($1.score ?? 0) } }
    var body: some View { NavigationStack { ScrollView { VStack(spacing: 20) { Avatar(initials: "LM", size: 78); VStack(spacing: 3) { Text("Lila Morgan").font(.system(size: 28, weight: .bold, design: .serif)); Text("MIT · Class of 2027").foregroundStyle(Color.muted) }; HStack { Stat(value: "8", label: "day streak", copper: true); Stat(value: "42.5", label: "study hours"); Stat(value: "11", label: "spots visited") }.padding(.vertical, 8); socialCard; VStack(alignment: .leading, spacing: 12) { HStack { Text("Your top study spots").font(.title3.weight(.bold)); Spacer(); NavigationLink("See all") { RankedSpotsView(spots: rankedSpots) }.font(.subheadline.weight(.semibold)).foregroundStyle(Color.plum) }; ForEach(Array(rankedSpots.prefix(3).enumerated()), id: \.element.id) { index, spot in NavigationLink { SpotDetail(spot: spot) } label: { HStack { ScoreBadge(spot: spot); VStack(alignment: .leading) { Text(spot.name).font(.headline).foregroundStyle(Color.ink); Text("Quiet focus · personal favorite").font(.caption).foregroundStyle(Color.muted) }; Spacer(); Text("#\(index + 1)").font(.title3.weight(.bold)).foregroundStyle(Color.copper) } } } }.padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius: 20)); NavigationLink { SavedPlacesView() } label: { HStack { VStack(alignment: .leading) { Text("Saved places").font(.title3.weight(.bold)).foregroundStyle(Color.ink); Text("\(model.favorites.count) favorites · \(model.wantToTry.count) want to try").foregroundStyle(Color.muted) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(Color.plum) }.frame(maxWidth: .infinity, alignment: .leading).padding(16).background(Color.mauve).clipShape(RoundedRectangle(cornerRadius: 20)) }; VStack(alignment: .leading, spacing: 12) { Text("Your activity").font(.title3.weight(.bold)); PersonalActivity(icon: "timer", prefix: "Studied at", spot: seededSpots.first { $0.name == "Hayden Library" }, detail: "2h 10m · Yesterday"); PersonalActivity(icon: "bookmark.fill", prefix: "Saved", spot: seededSpots.first { $0.name == "Rotch Library" }, detail: "Want to try · 3 days ago"); PersonalActivity(icon: "flame.fill", prefix: "Reached an 8-day streak", spot: nil, detail: "Keep it going!") }.padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius: 20)) }.padding(16) }.background(Color.parchment).refreshable { await model.refresh() }.studiNavigationBarHidden() } }
    var socialCard: some View { VStack(alignment: .leading, spacing: 14) { HStack { VStack(alignment: .leading, spacing: 3) { Text("Study with friends").font(.title3.weight(.bold)); Text("Invite classmates or follow people you may know.").font(.caption).foregroundStyle(Color.muted) }; Spacer(); ShareLink(item: URL(string: "https://studi.app/invite")!, message: Text("Join me on Studi to find great study spots.")) { Label("Invite", systemImage: "square.and.arrow.up").font(.subheadline.weight(.semibold)).foregroundStyle(.white).padding(.horizontal, 12).padding(.vertical, 9).background(Color.plum).clipShape(Capsule()) } }; if suggestions.isEmpty { Text("You’re following everyone you may know.").font(.caption).foregroundStyle(Color.muted) } else { ForEach(suggestions) { user in HStack(spacing: 10) { NavigationLink { CommunityProfileView(user: user) } label: { Avatar(initials: user.initials, size: 36) }; VStack(alignment: .leading, spacing: 1) { Text(user.name).font(.subheadline.weight(.semibold)).foregroundStyle(Color.ink); Text(user.subtitle).font(.caption).foregroundStyle(Color.muted) }; Spacer(); Button("Follow") { model.toggleFollow(user) }.font(.caption.weight(.bold)).foregroundStyle(.white).padding(.horizontal, 12).padding(.vertical, 8).background(Color.plum).clipShape(Capsule()) } } } }.padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius: 20)).overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.border)) }
}

struct RankedSpotsView: View { let spots: [Spot]
    var body: some View { List { ForEach(Array(spots.enumerated()), id: \.element.id) { index, spot in NavigationLink { SpotDetail(spot: spot) } label: { HStack(spacing: 14) { Text("#\(index + 1)").font(.title3.weight(.bold)).foregroundStyle(Color.copper).frame(width: 34, alignment: .leading); ScoreBadge(spot: spot); VStack(alignment: .leading, spacing: 3) { Text(spot.name).font(.headline).foregroundStyle(Color.ink); Text(spot.building).font(.caption).foregroundStyle(Color.muted) } } } } }.scrollContentBackground(.hidden).background(Color.parchment).navigationTitle("All ranked spots").studiInlineNavigationTitle() }
}

struct SavedPlacesView: View { @EnvironmentObject var model: StudiModel
    var body: some View { List { Section("Favorites") { savedRows(for: model.favorites, empty: "Heart a study spot to save it here.") }; Section("Want to try") { savedRows(for: model.wantToTry, empty: "Bookmark a study spot to plan your next visit.") } }.scrollContentBackground(.hidden).background(Color.parchment).navigationTitle("Saved places").studiInlineNavigationTitle() }
    @ViewBuilder private func savedRows(for ids: Set<UUID>, empty: String) -> some View { let spots = seededSpots.filter { ids.contains($0.id) }; if spots.isEmpty { Text(empty).foregroundStyle(Color.muted) } else { ForEach(spots) { spot in NavigationLink { SpotDetail(spot: spot) } label: { HStack { ScoreBadge(spot: spot); VStack(alignment: .leading) { Text(spot.name).font(.headline); Text(spot.building).font(.caption).foregroundStyle(Color.muted) } } } } } }
}

struct PersonalActivity: View { let icon, prefix: String; let spot: Spot?; let detail: String
    var body: some View { HStack(spacing: 12) { Image(systemName: icon).foregroundStyle(Color.copper).frame(width: 28); VStack(alignment: .leading, spacing: 3) { if let spot { HStack(spacing: 4) { Text(prefix).font(.subheadline.weight(.semibold)).foregroundStyle(Color.ink); NavigationLink(spot.name) { SpotDetail(spot: spot) }.font(.subheadline.weight(.semibold)).foregroundStyle(Color.plum) } } else { Text(prefix).font(.subheadline.weight(.semibold)).foregroundStyle(Color.ink) }; Text(detail).font(.caption).foregroundStyle(Color.muted) }; Spacer() } }
}
struct Stat: View { let value, label: String; var copper = false
    var body: some View { VStack { Text(value).font(.system(size: 24, weight: .bold, design: .serif)).foregroundStyle(copper ? Color.copper : Color.plum); Text(label).font(.caption).foregroundStyle(Color.muted) }.frame(maxWidth: .infinity) }
}
