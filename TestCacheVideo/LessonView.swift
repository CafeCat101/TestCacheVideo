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
		})
	}
	
	private func setupPlayer() {
		let interval = CMTime(seconds: 0.5,preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		var playVideo = URL(string:scorewindData.decodeVideoURL(videoURL:scorewindData.currentTestVideo.videom3u8))!
		let playVideoMP4 = URL(string: scorewindData.decodeVideoURL(videoURL: scorewindData.currentTestVideo.videoMP4))!
		
		let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		let destinationUrl = docsUrl?.appendingPathComponent(playVideoMP4.lastPathComponent)
		
		if FileManager.default.fileExists(atPath: destinationUrl!.path) {
			playVideo = playVideoMP4
			playerStatus = destinationUrl!.path
		} else {
			playerStatus = scorewindData.currentTestVideo.videom3u8
		}
		
		scorewindData.videoPlayer = AVPlayer(url: playVideo)
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
