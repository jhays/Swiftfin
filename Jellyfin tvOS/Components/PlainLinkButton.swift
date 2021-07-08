import SwiftUI
import JellyfinAPI

struct PlainLinkButton: View {
    @Environment(\.isFocused) var envFocused: Bool
    @State var focused: Bool = false
    @State var label: String

    var body: some View {
        Text(label)
            .fontWeight(focused ? .bold : .regular)
            .foregroundColor(.blue)
            .onChange(of: envFocused) { envFocus in
                withAnimation(.linear(duration: 0.15)) {
                    self.focused = envFocus
                }
            }
            .scaleEffect(focused ? 1.1 : 1)
    }
}
