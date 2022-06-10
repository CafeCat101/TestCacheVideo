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
	@Environment(\.scenePhase) var scenePhase
	var body: some Scene {
		WindowGroup {
			ContentView()
				.onChange(of: scenePhase, perform: { newPhase in
					if newPhase == .active {
						print("app is active")
						
					} else if newPhase == .inactive {
						print("appp is inactive")
					} else if newPhase == .background {
						print("app is in the background")
					}
				})
				.environmentObject(scorewindData)
		}
	}
}
