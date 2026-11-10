//
//  SocgentTests.swift
//  SocgentTests
//
//  Created by Abdhilabs on 09/01/26.
//

import Testing
@testable import Socgent

struct SocgentTests {

    @Test func example() async throws {
        let reducer = SocialReducer()
        #expect(reducer.extractPhoneNumber(from: "628957845093") == "628957845093")
        #expect(reducer.extractPhoneNumber(from: "+628957845093") == "628957845093")
        #expect(reducer.extractPhoneNumber(from: "08957845093") == nil)
        #expect(reducer.extractPhoneNumber(from: "12345") == nil)
    }

}
