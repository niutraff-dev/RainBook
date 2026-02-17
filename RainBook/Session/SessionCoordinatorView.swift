import SwiftUI
import UIKit

struct SessionCoordinatorView: View {
    
    @ObservedObject var coordinator: SessionCoordinator
    
    @StateObject private var feature1Coordinator: Feature1Coordinator
    @StateObject private var feature2Coordinator: Feature2Coordinator
    @StateObject private var feature3Coordinator: Feature3Coordinator
    @StateObject private var feature4Coordinator: Feature4Coordinator
    
    init(coordinator: SessionCoordinator) {
        self.coordinator = coordinator
        self._feature1Coordinator = StateObject(wrappedValue: coordinator.buildFeature1Coordinator())
        self._feature2Coordinator = StateObject(wrappedValue: coordinator.buildFeature2Coordinator())
        self._feature3Coordinator = StateObject(wrappedValue: coordinator.buildFeature3Coordinator())
        self._feature4Coordinator = StateObject(wrappedValue: coordinator.buildFeature4Coordinator())
    }
    
    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            Feature1CoordinatorView(coordinator: feature1Coordinator)
                .tabItem {
                    Image(coordinator.selectedTab == .feature1 ? .selTabCalendar : .tabCalendar)
                    Text("tab.feature1".localized())
                }
                .tag(SessionTab.feature1)
            
            Feature2CoordinatorView(coordinator: feature2Coordinator)
                .tabItem {
                    Image(coordinator.selectedTab == .feature2 ? .selTabHistory : .tabHistory)
                    Text("tab.feature2".localized())
                }
                .tag(SessionTab.feature2)
            
            Feature3CoordinatorView(coordinator: feature3Coordinator)
                .tabItem {
                    Image(coordinator.selectedTab == .feature3 ? .selTabChart: .tabChart)
                    Text("tab.feature3".localized())
                }
                .tag(SessionTab.feature3)
            
            Feature4CoordinatorView(coordinator: feature4Coordinator)
                .tabItem {
                    Image(coordinator.selectedTab == .feature4 ? .selTabSettings: .tabSettings)
                    Text("tab.feature4".localized())
                }
                .tag(SessionTab.feature4)
        }
        .onAppear() {
            UITabBar.appearance().backgroundColor = UIColor.white
            
            UITabBar.appearance().unselectedItemTintColor = UIColor(Color.palette(.lightGray))
            
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.palette(.white))
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .tint(Color.palette(.blueColor))
    }
}

#Preview {
    SessionCoordinatorView(coordinator: SessionCoordinator())
}
