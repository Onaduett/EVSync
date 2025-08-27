
import SwiftUI

struct NavigationBar: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Maps")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar()
            .environmentObject(AuthenticationManager())
    }
}
