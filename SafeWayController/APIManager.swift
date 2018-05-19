//
//  APIManager.swift
//  SafeWay
//
//  Created by Hansen Qian on 7/11/15.
//  Copyright (c) 2015 HQ. All rights reserved.
//

import Foundation

class APIManager : NSObject {

    private static var mySharedManager = APIManager()

    public static func sharedManager() -> APIManager {
        return self.mySharedManager
    }

    override init() {
        super.init()

        

    }
}