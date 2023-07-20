//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Combine
import Defaults
import Factory
import Foundation
import JellyfinAPI
import SwiftUI

extension BaseItemDto {

    func videoPlayerViewModel(with mediaSource: MediaSourceInfo, liveTVChannel: Bool = false) async throws -> VideoPlayerViewModel {

        let builder = DeviceProfileBuilder()
        // TODO: fix bitrate settings
        let tempOverkillBitrate = 360_000_000
        builder.setMaxBitrate(bitrate: tempOverkillBitrate)
        let profile = builder.buildProfile()

        let userSession = Container.userSession.callAsFunction()

        let playbackInfo = PlaybackInfoDto(deviceProfile: profile)
        let playbackInfoParameters = Paths.GetPostedPlaybackInfoParameters(
            userID: userSession.user.id,
            maxStreamingBitrate: tempOverkillBitrate
        )

        let request = Paths.getPostedPlaybackInfo(
            itemID: self.id!,
            parameters: playbackInfoParameters,
            playbackInfo
        )

        let response = try await userSession.client.send(request)

        if liveTVChannel {
            var matchingMediaSource: MediaSourceInfo? = nil
            if let responseMediaSources = response.value.mediaSources {
                for responseMediaSource in responseMediaSources {
                    if let openToken = responseMediaSource.openToken, let mediaSourceId = mediaSource.id {
                        if openToken.contains(mediaSourceId) {
                            matchingMediaSource = responseMediaSource
                        }
                    }
                }
            }
            guard let matchingMediaSource else {
                throw JellyfinAPIError("Matching media source not in playback info")
            }

            return try matchingMediaSource.videoPlayerViewModel(
                with: self,
                playSessionID: response.value.playSessionID!,
                liveTVChannel: liveTVChannel
            )
        } else {
            guard let matchingMediaSource = response.value.mediaSources?
                .first(where: { $0.id == mediaSource.id })
            else {
                throw JellyfinAPIError("Matching media source not in playback info")
            }

            return try matchingMediaSource.videoPlayerViewModel(with: self, playSessionID: response.value.playSessionID!)
        }
    }
}
