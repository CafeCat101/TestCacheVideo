//
//  ScorewindData.swift
//  TestCacheVideo
//
//  Created by Leonore Yardimli on 2022/5/25.
//

import Foundation
import AVFoundation
import SwiftUI

class ScorewindData: ObservableObject {
	@Published var testVideos:[TestVideo] = [TestVideo()]
	@Published var currentTestVideo = TestVideo()
	@Published var videoPlayer:AVPlayer?
	var cachedURL: URL?
	@Published var downloadList = [DownloadItem()]
	var swDownloadTask:URLSessionDownloadTask?
	@Published var downloadRunning = false
	var session = URLSession.shared
	@Published var newDownloadList:[DownloadItem] = []
	var canceled = false
	private var videoTask: Task<(), Error>?
	private var newVideoTask: Task<URL?,Error>?
	
	init() {
		//id2: 10MB
		testVideos = [
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
				id:2,
				title:"C major Scale in First Position One Octave &#8211; Guitar Exercises",
				videoMP4:"https://scorewind.com/sw-music/pdfProject/Sheet12119/12119 3731 C Major Scale.mp4",
				videom3u8:"https://scorewind.com/sw-music/pdfProject/Sheet12119/12119_3731_C_Major_Scale.m3u8"),
			TestVideo(
				id:6,
				title:"V101.1.1 &#8211; Introduction to Violin &#8211; Parts of the Violin",
				videoMP4:"https://scorewind.com/sw-music/pdfProject/Sheet13597/01 - Violin 101 - Introduction to violin - parts of the violin.mp4",
				videom3u8:"https://scorewind.com/sw-music/pdfProject/Sheet13597/01_-_Violin_101_-_Introduction_to_violin_-_parts_of_the_violin.m3u8"),
			TestVideo(
				id:1,
				title:"Introduction to &#8216;Guitar Method (Demo): First Position Foundations&#8217;",
				videoMP4:"https://scorewind.com/wp-content/uploads/2021/02/01-Ricardo-1St-Lesson.mp4",
				videom3u8:"https://scorewind.com/wp-content/uploads/2021/02/01-Ricardo-1St-Lesson.m3u8"),
			TestVideo(
				id:3,
				title:"Introduction to &#8216;Violin Method (Demo): Basis for Even Sounding Bow Strokes&#8217;",
				videoMP4:"https://scorewind.com/wp-content/uploads/2021/02/01-Intro-Lesson-Basis-For-Even-Sounding-Bow-Strokes.mp4",
				videom3u8:"https://scorewind.com/wp-content/uploads/2021/02/01-Intro-Lesson-Basis-For-Even-Sounding-Bow-Strokes.m3u8")]
		
		currentTestVideo = TestVideo(
			id:4,
			 title:"Bow Workout &#8211; Open String Playing &#8211; Violin Exercise",
			 videoMP4:"https://scorewind.com/sw-music/pdfProject/Sheet12127/3711 12127 Bow Workout Open String Playing.mp4",
			 videom3u8:"https://scorewind.com/sw-music/pdfProject/Sheet12127/3711_12127_Bow_Workout_Open_String_Playing.m3u8")
		downloadList = []
	}
	
	func decodeVideoURL(videoURL:String)->String{
		let decodedURL = videoURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
		print(decodedURL)
		return decodedURL
	}
	
	func downloadVideo(_ url: URL, lessonID: Int) {
		downloadList.append(DownloadItem(lessonID: lessonID, downloadStatus: 1))
		
		let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		let destinationUrl = docsUrl?.appendingPathComponent(url.lastPathComponent)
		print("dest:\(destinationUrl!.path)")
		
		let findDownloadItemIndex = downloadList.firstIndex(where: {$0.lessonID == lessonID}) ?? -1
		if findDownloadItemIndex >= 0 {
			downloadList[findDownloadItemIndex].downloadStatus = 2
		}
		
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
						if findDownloadItemIndex >= 0 {
							self.downloadList[findDownloadItemIndex].downloadStatus = 3
						}
					}
				} catch let error {
					print("Error decoding: ", error)
				}
			}
			
			
		}
		
		dataTask.resume()
	}
	
	func videoDownloadTask(_ url:URL, lessonID: Int) {
		DispatchQueue.main.async {
			self.downloadList.append(DownloadItem(lessonID: lessonID, downloadStatus: 1))
			let findDownloadItemIndex = self.downloadList.firstIndex(where: {$0.lessonID == lessonID}) ?? -1
			if findDownloadItemIndex >= 0 {
				self.downloadList[findDownloadItemIndex].downloadStatus = 2
				
			}
		}
		
		print("[debug] before calling downloadTask")
		swDownloadTask = URLSession.shared.downloadTask(with: url) {
			urlOrNil, responseOrNil, errorOrNil in
			// check for and handle errors:
			// * errorOrNil should be nil
			// * responseOrNil should be an HTTPURLResponse with statusCode in 200..<299
			
			guard let fileURL = urlOrNil else { return }
			do {
				/*let documentsURL = try
				 FileManager.default.url(for: .documentDirectory,
				 in: .userDomainMask,
				 appropriateFor: nil,
				 create: false)*/
				//let savedURL = documentsURL.appendingPathComponent(fileURL.lastPathComponent)
				let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
				let destinationUrl = docsUrl!.appendingPathComponent(url.lastPathComponent)
				print("[debug] fileURL:\(fileURL.path)")
				print("[debug] destinationUrl:\(destinationUrl.path)")
				try FileManager.default.moveItem(at: fileURL, to: destinationUrl)
				print("[debug] moved to document folder.")
				
				DispatchQueue.main.async {
					let findDownloadItemIndex = self.downloadList.firstIndex(where: {$0.lessonID == lessonID}) ?? -1
					if findDownloadItemIndex >= 0 {
						self.downloadList[findDownloadItemIndex].downloadStatus = 3
					}
				}
				
			} catch {
				print ("[debug] file error: \(error)")
			}
		}
		
		swDownloadTask!.resume()
	}
	
	func downloadVideos() {
		if !downloadList.isEmpty {
			let findDownloadItemIndex = downloadList.firstIndex(where: {$0.downloadStatus == 1}) ?? -1
			
			if findDownloadItemIndex != -1 {
				let findLesson = testVideos.first(where:{$0.id == downloadList[findDownloadItemIndex].lessonID})
				
				if findLesson != nil {
					print("[debug] before calling downloadTask")
					downloadList[findDownloadItemIndex].downloadStatus = 2
					downloadRunning = true
					let url = URL(string: decodeVideoURL(videoURL: findLesson!.videoMP4))!
					//=>!!! in betaApp. need to make sure the mp4 doesn't exist before calling URLSession
					swDownloadTask = URLSession.shared.downloadTask(with: url) {
						urlOrNil, responseOrNil, errorOrNil in
						// check for and handle errors:
						// * errorOrNil should be nil
						// * responseOrNil should be an HTTPURLResponse with statusCode in 200..<299
						
						guard let fileURL = urlOrNil else {
							DispatchQueue.main.async {
								if !self.downloadList.isEmpty {
									//make sure it's not canceled ahead of this time.
									self.downloadList[findDownloadItemIndex].downloadStatus = 1
									let checkRemainingTargets = self.downloadList.filter({$0.downloadStatus == 1})
									if !checkRemainingTargets.isEmpty {
										self.downloadVideos()
									} else {
										self.downloadRunning = false
									}
								}
							}
							return
						}
						do {
							let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
							let destinationUrl = docsUrl!.appendingPathComponent(url.lastPathComponent)
							print("[debug] fileURL:\(fileURL.path)")
							print("[debug] destinationUrl:\(destinationUrl.path)")
							try FileManager.default.moveItem(at: fileURL, to: destinationUrl)
							print("[debug] moved to document folder.")
							
							DispatchQueue.main.async {
								if !self.downloadList.isEmpty {
									self.downloadList[findDownloadItemIndex].downloadStatus = 3
									let checkRemainingTargets = self.downloadList.filter({$0.downloadStatus == 1})
									if !checkRemainingTargets.isEmpty {
										self.downloadVideos()
									}
								}
							}
							
						} catch {
							print ("[debug] file error: \(error)")
							DispatchQueue.main.async {
								if !self.downloadList.isEmpty {
									// in betaApp, needs to find the solution to prevent it from update downloadStatus at wrong item, because the cancel button will remove all downloadItem with that courseID, not just empty the downloadList.
									self.downloadList[findDownloadItemIndex].downloadStatus = 1
									let checkRemainingTargets = self.downloadList.filter({$0.downloadStatus == 1})
									if !checkRemainingTargets.isEmpty {
										self.downloadVideos()
									} else {
										self.downloadRunning = false
									}
								}
							}
						}
					}
					swDownloadTask!.resume()
				}
				
			}
		}
	}
	
	func cancelDownloads(){
		swDownloadTask?.cancel()
		downloadList = []
		downloadRunning = false
	}
	
	func newDownload(_ url: URL, lessonID: Int) async throws -> Int {
		print("newDownload is called")
		do {
			let (fileURL, _) = try await session.download(from: url)
			
			let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
			let destinationUrl = docsUrl!.appendingPathComponent(url.lastPathComponent)
			print("[debug] fileURL:\(fileURL.path)")
			print("[debug] destinationUrl:\(destinationUrl.path)")
			try FileManager.default.moveItem(at: fileURL, to: destinationUrl)
			print("[debug] moved to document folder.")
			return 3
		} catch {
			print("newDownlaod, catch, \(error)")
			return -1
		}
	}
	
	func newDownloadVideos() async throws {
		for (index, item) in newDownloadList.enumerated() {
			if canceled == true {
				break
			}
			if item.downloadStatus == 1 {
				let findLesson = testVideos.first(where:{$0.id == item.lessonID})
				if findLesson != nil {
					print("newDownloadVideos, lesson.videoMP4 = \(findLesson!.videoMP4)")
					let url = URL(string: decodeVideoURL(videoURL: findLesson!.videoMP4))!
					
					newDownloadList[index].downloadStatus = 2
					print("newDownloadVideos, newDownloadList[\(index)].downloadStatus \(newDownloadList[index].downloadStatus)")
					
					do {
						DispatchQueue.main.async {
							self.newDownloadList[index].downloadStatus = 2
							print("newDownloadVideos, newDownloadList[\(index)].downloadStatus \(self.newDownloadList[index].downloadStatus)")
						}
						let newStatus = try await newDownload(url, lessonID: item.lessonID)
						if canceled == true {
							DispatchQueue.main.async {
								self.newDownloadList[index].downloadStatus = 1
							}
							break
						}
						DispatchQueue.main.async {
							self.newDownloadList[index].downloadStatus = newStatus
							print("newDownloadVideos, newDownloadList[\(index)].downloadStatus \(self.newDownloadList[index].downloadStatus)")
						}
					} catch {
						print("newDownloadVideos, catch,\(error)")
					}
				}
			}
		}
	}
	
	func newDownloadCancel() {
		videoTask?.cancel()
		canceled = true
	}
	
	func newnewDownloadCancel() {
		newVideoTask?.cancel()
	}
	
	func newnewDownload() async {
		if !newDownloadList.isEmpty {
			let targetIndex = newDownloadList.firstIndex(where: {$0.downloadStatus == 1}) ?? -1
			
			if targetIndex != -1 {
				let findLesson = testVideos.first(where:{$0.id == newDownloadList[targetIndex].lessonID})
				
				if findLesson != nil {
					DispatchQueue.main.async {
						self.newDownloadList[targetIndex].downloadStatus = 2
					}
					print("newDownloadVideos, lesson.videoMP4 = \(findLesson!.videoMP4)")
					let url = URL(string: decodeVideoURL(videoURL: findLesson!.videoMP4))!
					
					newVideoTask = Task { () -> URL? in
						let (fileURL, _) = try await URLSession.shared.download(from: url)
						return fileURL
					}
					
					do {
						let getFileURL = try await newVideoTask!.value!
						let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
						let destinationUrl = docsUrl!.appendingPathComponent(url.lastPathComponent)
						print("[debug] fileURL:\(getFileURL.path)")
						print("[debug] destinationUrl:\(destinationUrl.path)")
						try FileManager.default.moveItem(at: getFileURL, to: destinationUrl)
						print("[debug] moved to document folder.")
						
						DispatchQueue.main.async {
							self.newDownloadList[targetIndex].downloadStatus = 3
						}
						
						print("ready to call newnewDownload again")
						await newnewDownload()
						
					} catch {
						print("newnewDownlaod, catch, \(error)")
						DispatchQueue.main.async {
							self.newDownloadList[targetIndex].downloadStatus = -1
						}
					}
				}
				
			}
			
			
		}
	}
	/*
	func newnewDownloadVideos() async throws{
		videoTask = Task {
			for (index, item) in newDownloadList.enumerated() {
				if canceled == true {
					break
				}
				if item.downloadStatus == 1 {
					let findLesson = testVideos.first(where:{$0.id == item.lessonID})
					if findLesson != nil {
						print("newDownloadVideos, lesson.videoMP4 = \(findLesson!.videoMP4)")
						let url = URL(string: decodeVideoURL(videoURL: findLesson!.videoMP4))!
						
						newDownloadList[index].downloadStatus = 2
						print("newDownloadVideos, newDownloadList[\(index)].downloadStatus \(newDownloadList[index].downloadStatus)")
						
						do {
							DispatchQueue.main.async {
								self.newDownloadList[index].downloadStatus = 2
								print("newDownloadVideos, newDownloadList[\(index)].downloadStatus \(self.newDownloadList[index].downloadStatus)")
							}
							
							let newStatus = try await newDownload(url, lessonID: item.lessonID)
							
							if canceled == true {
								DispatchQueue.main.async {
									self.newDownloadList[index].downloadStatus = 1
								}
								break
							}
							
							DispatchQueue.main.async {
								self.newDownloadList[index].downloadStatus = newStatus
								print("newDownloadVideos, newDownloadList[\(index)].downloadStatus \(self.newDownloadList[index].downloadStatus)")
							}
						} catch {
							print("newDownloadVideos, catch,\(error)")
						}
					}
				}
			}
		}
	}
	 */
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
