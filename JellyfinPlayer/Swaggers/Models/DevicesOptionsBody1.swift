//
// DevicesOptionsBody1.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** Device Options. */

public struct DevicesOptionsBody1: Codable {

    public var customName: String?

    public init(customName: String? = nil) {
        self.customName = customName
    }

    public enum CodingKeys: String, CodingKey { 
        case customName = "CustomName"
    }

}