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
						if !scorewindData.downloadList.isEmpty {
							//=>need to check "downloading" video, if they don't have file in document folder, mark them "in queue" so they can be downloaded again.
							scorewindData.downloadList = scorewindData.downloadList.map({$0.downloadStatus == 2 ?? DownloadItem(lessonID: $0.lessonID, downloadStatus: 1)})
							scorewindData.downloadVideos()
						}
					} else if newPhase == .inactive {
						print("appp is inactive")
					} else if newPhase == .background {
						print("app is in the background")
						scorewindData.downloadRunning = false
					}
				})
				.environmentObject(scorewindData)
		}
	}
}
