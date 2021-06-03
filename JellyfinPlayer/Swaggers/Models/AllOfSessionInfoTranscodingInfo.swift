//
// AllOfSessionInfoTranscodingInfo.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



public struct AllOfSessionInfoTranscodingInfo: Codable {

    public var audioCodec: String?
    public var videoCodec: String?
    public var container: String?
    public var isVideoDirect: Bool?
    public var isAudioDirect: Bool?
    public var bitrate: Int?
    public var framerate: Float?
    public var completionPercentage: Double?
    public var width: Int?
    public var height: Int?
    public var audioChannels: Int?
    public var transcodeReasons: [TranscodeReason]?

    public init(audioCodec: String? = nil, videoCodec: String? = nil, container: String? = nil, isVideoDirect: Bool? = nil, isAudioDirect: Bool? = nil, bitrate: Int? = nil, framerate: Float? = nil, completionPercentage: Double? = nil, width: Int? = nil, height: Int? = nil, audioChannels: Int? = nil, transcodeReasons: [TranscodeReason]? = nil) {
        self.audioCodec = audioCodec
        self.videoCodec = videoCodec
        self.container = container
        self.isVideoDirect = isVideoDirect
        self.isAudioDirect = isAudioDirect
        self.bitrate = bitrate
        self.framerate = framerate
        self.completionPercentage = completionPercentage
        self.width = width
        self.height = height
        self.audioChannels = audioChannels
        self.transcodeReasons = transcodeReasons
    }

    public enum CodingKeys: String, CodingKey { 
        case audioCodec = "AudioCodec"
        case videoCodec = "VideoCodec"
        case container = "Container"
        case isVideoDirect = "IsVideoDirect"
        case isAudioDirect = "IsAudioDirect"
        case bitrate = "Bitrate"
        case framerate = "Framerate"
        case completionPercentage = "CompletionPercentage"
        case width = "Width"
        case height = "Height"
        case audioChannels = "AudioChannels"
        case transcodeReasons = "TranscodeReasons"
    }

}