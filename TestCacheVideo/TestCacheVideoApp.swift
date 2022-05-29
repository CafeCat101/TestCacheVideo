//
//  TestCacheVideoApp.swift
//  TestCacheVideo
//
//  Created by Leonore Yardimli on 2022/5/25.
//

import SwiftUI

@main
struct TestCacheVideoApp: App {
	@StateObject var scorewindData = ScorewindData()
	var body: some Scene {
		WindowGroup {
			ContentView().environmentObject(scorewindData)
		}
	}
}
