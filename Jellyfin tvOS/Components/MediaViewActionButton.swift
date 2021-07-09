import SwiftUI

struct MediaViewActionButton: View {
    @Environment(\.isFocused) var envFocused: Bool
    @State var focused: Bool = false
    var icon: String
    var scrollView: Binding<UIScrollView?>?
    var iconColor: Color?

    var body: some View {
        Image(systemName: icon)
            .foregroundColor(focused ? .black : iconColor ?? .white)
            .onChange(of: envFocused) { envFocus in
                if envFocus == true {
                    scrollView?.wrappedValue?.scrollToTop()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        scrollView?.wrappedValue?.scrollToTop()
                    }
                }

                withAnimation(.linear(duration: 0.15)) {
                    self.focused = envFocus
                }
            }
            .font(.system(size: 40))
            .padding(.vertical, 12).padding(.horizontal, 20)
    }
}
