//
 /* 
  * SwiftFin is subject to the terms of the Mozilla Public
  * License, v2.0. If a copy of the MPL was not distributed with this
  * file, you can obtain one at https://mozilla.org/MPL/2.0/.
  *
  * Copyright 2021 Aiden Vigue & Jellyfin Contributors
  */

import SwiftUI

struct ConfirmCloseOverlay: View {
    var body: some View {
        VStack {
            HStack {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 96))
                        .padding(3)
                        .background(Color.black.opacity(0.4).mask(Circle()))

                Spacer()
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}

struct ConfirmCloseOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.red.ignoresSafeArea()

            ConfirmCloseOverlay()
                .ignoresSafeArea()
        }
    }
}
