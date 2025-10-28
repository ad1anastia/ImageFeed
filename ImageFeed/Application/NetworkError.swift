//
//  NetworkError.swift
//  ImageFeed
//
//  Created by Nastya Adodina on 28.10.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}
