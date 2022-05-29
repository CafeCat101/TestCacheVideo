//
//  ScorewindData.swift
//  TestCacheVideo
//
//  Created by Leonore Yardimli on 2022/5/25.
//

import Foundation
import AVFoundation

class ScorewindData: ObservableObject {
	@Published var testVideos:[TestVideo] = [TestVideo()]
	@Published var currentTestVideo = TestVideo()
	@Published var videoPlayer:AVPlayer?
	var cachedURL: URL?
	@Published var downloadList = [DownloadItem()]
	
	init() {
		
		testVideos = [
			TestVideo(
				id:1,
				title:"Introduction to &#8216;Guitar Method (Demo): First Position Foundations&#8217;",
				videoMP4:"https://scorewind.com/wp-content/uploads/2021/02/01-Ricardo-1St-Lesson.mp4",
				videom3u8:"https://scorewind.com/wp-content/uploads/2021/02/01-Ricardo-1St-Lesson.m3u8"),
			TestVideo(
				id:2,
				title:"C major Scale in First Position One Octave &#8211; Guitar Exercises",
				videoMP4:"https://scorewind.com/sw-music/pdfProject/Sheet12119/12119 3731 C Major Scale.mp4",
				videom3u8:"https://scorewind.com/sw-music/pdfProject/Sheet12119/12119_3731_C_Major_Scale.m3u8"),
			TestVideo(
				id:3,
				title:"Introduction to &#8216;Violin Method (Demo): Basis for Even Sounding Bow Strokes&#8217;",
				videoMP4:"https://scorewind.com/wp-content/uploads/2021/02/01-Intro-Lesson-Basis-For-Even-Sounding-Bow-Strokes.mp4",
				videom3u8:"https://scorewind.com/wp-content/uploads/2021/02/01-Intro-Lesson-Basis-For-Even-Sounding-Bow-Strokes.m3u8"),
			TestVideo(
				id:4,
				title:"Bow Workout &#8211; Open String Playing &#8211; Violin Exercise",
				videoMP4:"https://scorewind.com/sw-music/pdfProject/Sheet12127/3711 12127 Bow Workout Open String Playing.mp4",
				videom3u8:"https://scorewind.com/sw-music/pdfProject/Sheet12127/3711_12127_Bow_Workout_Open_String_Playing.m3u8"),
			TestVideo(
				id:5,
				title:"G101.1.1 &#8211; Learning the Parts of the Instrument",
				videoMP4:"https://scorewind.com/sw-music/pdfProject/Sheet13579/13579 01 Guitar 101 Parts of the Instrument Timing Corrected.mp4",
				videom3u8:"https://scorewind.com/sw-music/pdfProject/Sheet13579/13579_01_Guitar_101_Parts_of_the_Instrument_Timing_Corrected.m3u8"),
			TestVideo(
				id:6,
				title:"V101.1.1 &#8211; Introduction to Violin &#8211; Parts of the Violin",
				videoMP4:"https://scorewind.com/sw-music/pdfProject/Sheet13597/01 - Violin 101 - Introduction to violin - parts of the violin.mp4",
				videom3u8:"https://scorewind.com/sw-music/pdfProject/Sheet13597/01_-_Violin_101_-_Introduction_to_violin_-_parts_of_the_violin.m3u8")]
		
		currentTestVideo = testVideos[0]
		
		downloadList = []
	}
	
	func decodeVideoURL(videoURL:String)->String{
		let decodedURL = videoURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
		print(decodedURL)
		return decodedURL
	}
	
	func downloadVideo(_ url: URL) {
		let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		let destinationUrl = docsUrl?.appendingPathComponent(url.lastPathComponent)
		print("dest:\(destinationUrl!.path)")
		let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard
				error == nil,
				let httpResponse = response as? HTTPURLResponse,
				200 ..< 300 ~= httpResponse.statusCode,
				let data = data
			else {
				return
			}
			
			DispatchQueue.main.async {
				do {
					try data.write(to: destinationUrl!, options: Data.WritingOptions.atomic)
					
					DispatchQueue.main.async {
						print("downloaded")
					}
				} catch let error {
					print("Error decoding: ", error)
				}
			}
			

		}
		
		dataTask.resume()
	}
	
	
}

struct TestVideo: Hashable {
	var id = 0
	var title = ""
	var videoMP4 = ""
	var videom3u8 = ""
}

struct DownloadItem: Hashable {
	var lessonID = 0
	var downloadStatus = 0
}
