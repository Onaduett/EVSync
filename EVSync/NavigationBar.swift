
import SwiftUI

struct NavigationBar: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                MapView()
                    .tag(0)
                
                SettingsView()
                    .tag(1)
                
                MyCarView()
                    .tag(2)
                
                SettingsView()
                    .tag(3)
                
            }
            .ignoresSafeArea(.all)
            
            VStack {
                Spacer()
                CustomGlassTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.all)
        }
    }
}

struct CustomGlassTabBar: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        (icon: "map", title: "Maps", tag: 0),
        (icon: "ev.charger", title: "Favourite", tag: 1),
        (icon: "car.side", title: "My Car", tag: 2),
        (icon: "person.crop.circle", title: "Account", tag: 3)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tag) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab.tag
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(selectedTab == tab.tag ? .white : .white.opacity(0.7))
                            .scaleEffect(selectedTab == tab.tag ? 1.05 : 1.0)
                        
                        Text(tab.title)
                            .font(.system(size: 11, weight: selectedTab == tab.tag ? .semibold : .medium))
                            .foregroundColor(selectedTab == tab.tag ? .white : .white.opacity(0.7))
                    }
                    .frame(width: 80, height: 50)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 330, height: 70)
        .background {
            // Glass effect
            RoundedRectangle(cornerRadius: 35)
                .fill(.regularMaterial)
                .glassEffect()
                .shadow(color: .black.opacity(0.25), radius: 15, x: 0, y: 8)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .padding(.bottom, 15)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
    }
}

extension View {
    func glassEffect() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 35)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 35)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar()
            .environmentObject(AuthenticationManager())
    }
}
