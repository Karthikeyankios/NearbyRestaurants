//
//  GoogleApiHelper+Nearby.swift
//  NearbyRestaurants
//  Created by Karthikeyan K on 04/02/22.

import UIKit

class NearbyExtension : NSObject {
    static let shared : NearbyExtension = NearbyExtension()
    var allResults : [GApiResponse.NearBy] = []
    var completion : GoogleApi.GCallback?
    func getAllNearBy(input:GInputParams,clearAll:Bool=true) {
        if (clearAll) {
            allResults.removeAll()
        }
        GoogleApi.shared.callApi(.nearBy, input: input) { (response) in
            if let nearByPlaces =  response.data as? [GApiResponse.NearBy]{
                self.allResults.append(contentsOf: nearByPlaces)
                if let token = response.nextPageToken {
                    var tempInput = GInputParams()
                    tempInput.destinationCoordinate = input.destinationCoordinate
                    tempInput.keyword = input.keyword
                    tempInput.nextPageToken = token
                    tempInput.originCoordinate = input.originCoordinate
                    tempInput.radius = input.radius
                    self.getAllNearBy(input: tempInput,clearAll: false)
                } else if let completion = self.completion {
                    let localResponse = GApiResponse()
                    localResponse.data = self.allResults
                    completion(localResponse)
                }
            } else if let error = response.error {
                if let completion = self.completion {
                    let localResponse = GApiResponse()
                    localResponse.error = error
                    completion(localResponse)
                }
                print(response.error ?? "ERROR")
            }
        }
    }
}
