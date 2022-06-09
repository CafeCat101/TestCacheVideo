//
//  ContentView.swift
//  TestCacheVideo
//
//  Created by Leonore Yardimli on 2022/5/25.
//

import SwiftUI

struct ContentView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@State var selectedTab = "TVideos"
	@State var downloadID = 0
	
	var body: some View {
		TabView(selection: $selectedTab) {
			VStack{
				Text("Test cache lesson video")
					.font(.title2)
					.foregroundColor(.black)
				
				Spacer().frame(height:5)
				
				Button("Download all") {
					print("download all")
					if scorewindData.downloadList.isEmpty {
						for video in scorewindData.testVideos {
							scorewindData.downloadList.append(DownloadItem(lessonID: video.id, downloadStatus: 1))
						}
					}
					if !scorewindData.downloadList.isEmpty {
						scorewindData.downloadVideos()
					}
				}
				
				Spacer().frame(height:20)
				
				ForEach(scorewindData.testVideos, id: \.self) { testItem in
					VStack {
						HStack {
							Text("\(testItem.title)")
								.foregroundColor(Color.black)
							Spacer()
						}
						
						HStack {
							Button("Watch it") {
								print("watch it")
								scorewindData.currentTestVideo = testItem
								selectedTab = "TLesson"
							}
							Spacer().frame(width:10)
							Button("Download it") {
								print("download it")
								scorewindData.videoDownloadTask(URL(string: scorewindData.decodeVideoURL(videoURL: testItem.videoMP4))!, lessonID: testItem.id)
							}
							
							Spacer().frame(width:10)
							Text("status:")
							
							if checkDownloadStatus(lessonID: testItem.id) == 0 {
								Text("not in queue")
									.foregroundColor(Color.gray)
							} else if checkDownloadStatus(lessonID: testItem.id) == 1 {
								Text("in queue")
									.foregroundColor(Color.pink)
							} else if checkDownloadStatus(lessonID: testItem.id) == 2 {
								Text("downloading")
									.foregroundColor(Color.blue)
							} else if checkDownloadStatus(lessonID: testItem.id) == 3 {
								Text ("downloaded")
									.foregroundColor(Color.green)
							}
							
							Spacer()
						}
						
						Spacer().frame(height:15)
					}
					.padding(.horizontal)
					
				}
				
				Spacer()
			}
				.tabItem { Text("Videos") }
				.tag("TVideos")
			if !scorewindData.currentTestVideo.title.isEmpty {
				LessonView()
					.tabItem { Text("Lesson") }
					.tag("TLesson")
			}
		}
		/*.onAppear(perform: {
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				scorewindData.downloadList.append(DownloadItem(lessonID: 2, downloadStatus: 1))
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
				for i in scorewindData.downloadList.indices {
					if scorewindData.downloadList[i].lessonID == 2 {
						scorewindData.downloadList[i].downloadStatus = 2
					}
				}
				
			}
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
				if let findIndex = scorewindData.downloadList.firstIndex(where: {$0.lessonID == 2}) {
					scorewindData.downloadList[findIndex].downloadStatus = 3
				}
				
			}
		})*/
		
	}
	
	private func checkDownloadStatus(lessonID:Int) -> Int {
		//tested: view can be rerendered without placing ObservedObject in the parameter.
		var getDownloadStatus = 0 //0:not in queue, 1:waiting, 2:downloading, 3:downloaded
		if let findIndex = scorewindData.downloadList.firstIndex(where: {$0.lessonID == lessonID}) {
			getDownloadStatus = scorewindData.downloadList[findIndex].downloadStatus
		}
		return getDownloadStatus
	}
	
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView().environmentObject(ScorewindData())
	}
}
