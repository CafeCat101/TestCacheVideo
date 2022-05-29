//
//  LessonView.swift
//  TestCacheVideo
//
//  Created by Leonore Yardimli on 2022/5/25.
//

import SwiftUI
import AVKit

struct LessonView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@State private var playerStatus = "--"
	
	var body: some View {
		VStack {
			Text(scorewindData.currentTestVideo.title)
				.font(.title2)
			VideoPlayer(player: scorewindData.videoPlayer)
				.onDisappear(perform: {
					scorewindData.videoPlayer?.pause()
				})
			Spacer().frame(height:10)
			Text("\(playerStatus)")
			Spacer()
		}
		.onAppear(perform: {
			print("LessonView onappear")
			setupPlayer()
			playerStatus = scorewindData.currentTestVideo.videom3u8
		})
	}
	
	private func setupPlayer() {
		let interval = CMTime(seconds: 0.5,preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		scorewindData.videoPlayer = AVPlayer(url: URL(string:scorewindData.currentTestVideo.videom3u8)!)
		scorewindData.videoPlayer!.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
			time in
			
			// update player transport UI
		}
	}
}

struct LessonView_Previews: PreviewProvider {
	static var previews: some View {
		LessonView().environmentObject(ScorewindData())
	}
}
