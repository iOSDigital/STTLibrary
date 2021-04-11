//
//  STTLibrary.swift
//  SpeechToText Library
//  A quick and easy way to leverage SFSpeech
//  Copyright © 2020 DERBS.CO. All rights reserved.
//

import AVFoundation
import Speech


open class STTLibrary {
	
	// MARK: - Global Settings
	
	static let shared = STTLibrary()
	
	private let audioEngine = AVAudioEngine()
	private var audioRecorder: AVAudioRecorder!
	#if os(iOS)
	private let audioSession = AVAudioSession.sharedInstance()
	#endif
	public var settings = [
		AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
		AVSampleRateKey: 22000,
		AVNumberOfChannelsKey: 1,
		AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
	]
	
	private let speechRecogniser = SFSpeechRecognizer()
	private var speechRequest = SFSpeechAudioBufferRecognitionRequest()
	
	public var amplitude: Float {
		audioRecorder.updateMeters()
		var power = audioRecorder.averagePower(forChannel: 0) + 60
		power = max(power, 10)
		return power
	}
	
	public typealias CompletionHandler = (_:String) -> Void
	public typealias ProgressHandler = (_:Float) -> Void
	
	
	
	// MARK: - Initialisation
	
	init() {
		SFSpeechRecognizer.requestAuthorization { (authStatus) in
			switch authStatus {
				case .authorized:
					print("Authorised!")
				case .denied, .notDetermined, .restricted:
					print("Not authorised!")
					return
				@unknown default:
					print("Error")
					return
			}
		}
		#if os(iOS)
		audioSession.requestRecordPermission { (allowed) in
			if allowed {
				try? self.audioSession.setCategory(.playAndRecord, mode: .default)
				try? self.audioSession.setActive(true)
			}else {
				print("STTLibrary: Record permission not set")
			}
		}
		#endif
		
		speechRequest.shouldReportPartialResults = false
		speechRequest.taskHint = .dictation
	}
	
	
	
	
	public func startRecognizing(completion: @escaping CompletionHandler) {
		
		speechRequest = SFSpeechAudioBufferRecognitionRequest()
		speechRequest.shouldReportPartialResults = false
		let speechNode = audioEngine.inputNode
		let speechFormat = speechNode.outputFormat(forBus: 0)
		speechNode.installTap(onBus: 0, bufferSize: 1024, format: speechFormat) { (buffer, time) in
			self.speechRequest.append(buffer)
		}
		
		audioEngine.prepare()
		do {
			try audioEngine.start()
			audioRecorder = try AVAudioRecorder(url: recordLocation, settings: settings)
			audioRecorder.isMeteringEnabled = true
			audioRecorder.record()
			
			speechRecogniser?.recognitionTask(with: speechRequest, resultHandler: { (result, error) in
				if error != nil {
					print("STTLibraryError:" + error!.localizedDescription)
					completion("")
				} else {
					if let transcription = result?.bestTranscription {
						print("STTLibraryResult : " + transcription.formattedString)
						completion(transcription.formattedString)
					}
					
				}
			})
			
		}catch{
			print("STTLibraryError: \(error.localizedDescription)")
		}
		
		
	}
	
	public func stopRecording() {
		print("STTLibrary: StopRecording")
		self.audioEngine.inputNode.removeTap(onBus: 0)
		self.audioEngine.stop()
		self.speechRequest.endAudio()
		audioRecorder.stop()
	}
	
	
	
	
	
	
}


extension STTLibrary {
	
	var recordLocation: URL {
		get { return FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("m4a") }
	}
	
}
