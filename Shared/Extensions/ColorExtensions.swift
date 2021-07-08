//
//  ColorExtensions.swift
//  Jellyfin
//
//  Created by Stephen Byatt on 8/7/21.
//

import SwiftUI


public extension Color {
    static var backgroundGradient: [Color] {
        return [Color("AccentColor"), Color("backgroundGradientEnd")]
    }
   
}

extension View {
    // Modifier allows the view to be hidden but still retains the frame within the layout
    @ViewBuilder func hidden(_ hide: Bool) -> some View {
        if hide { hidden() }
        else { self }
    }
}
