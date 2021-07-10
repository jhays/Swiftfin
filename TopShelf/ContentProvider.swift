//
//  ContentProvider.swift
//  TopShelf
//
//  Created by Stephen Byatt on 10/7/21.
//

import TVServices

class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        // Fetch content and call completionHandler
        completionHandler(nil);
    }

}

