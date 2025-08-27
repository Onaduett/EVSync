
import SwiftUI



// Alternative more advanced glass effect version
struct NavigationBar: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                MapView()
                    .tag(0)
                
                SettingsView()
                    .tag(1)
            }
            .ignoresSafeArea(.all)
            
            // Custom glass tab bar
            CustomGlassTabBar(selectedTab: $selectedTab)
        }
    }
}

struct CustomGlassTabBar: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        (icon: "map", title: "Maps", tag: 0),
        (icon: "gear", title: "Settings", tag: 1)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tag) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab.tag
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(selectedTab == tab.tag ? .white : .white.opacity(0.6))
                            .scaleEffect(selectedTab == tab.tag ? 1.1 : 1.0)
                        
                        Text(tab.title)
                            .font(.system(size: 12, weight: selectedTab == tab.tag ? .semibold : .medium))
                            .foregroundColor(selectedTab == tab.tag ? .white : .white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background {
            // Glass morphism effect
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.3),
                                    Color.black.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 34)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
    }
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar()
            .environmentObject(AuthenticationManager())
    }
}
