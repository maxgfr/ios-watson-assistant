//
//  ViewController.swift
//  IBMConv
//
//  Created by GOLFIER on 21/12/2017.
//  Copyright © 2017 GOLFIER. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ConversationV1
import SpeechToTextV1
import Speech

class HomeViewController: JSQMessagesViewController, SFSpeechRecognizerDelegate {
    
    //defaults param
    private let defaults = UserDefaults.standard
    
    //Users
    private var currentUser: User!
    private var watsonUser: User!
    
    // All messages of user1, user2
    private var messages = [JSQMessage]()
    
    //Conversation
    private var conversation: Conversation!
    private var context: Context? // save context to continue conversation
    //SpeechToText
    private var speechToText: SpeechToText!
    
    //Speech on iOS
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "fr-FR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    //Button
    private let microphoneButton = UIButton(type: .custom)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // microphone button
        microphoneButton.setImage(#imageLiteral(resourceName: "microphone-hollow"), for: .normal)
        microphoneButton.setImage(#imageLiteral(resourceName: "microphone"), for: .highlighted)
        microphoneButton.addTarget(self, action: #selector(startTranscribing), for: .touchDown)
        microphoneButton.addTarget(self, action: #selector(stopTranscribing), for: .touchUpInside)
        microphoneButton.addTarget(self, action: #selector(stopTranscribing), for: .touchUpOutside)
        inputToolbar.contentView.leftBarButtonItem = microphoneButton
        
        
        /* Speech on iOS*/
        microphoneButton.isEnabled = false  //2
        speechRecognizer?.delegate = self  //3
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            var isButtonEnabled = false
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
           OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
        /* Speech on iOS*/
        
        let username = defaults.string(forKey: "Identifiant")
        //If the user is connected
        if (username != nil) {
            currentUser = User(id: "1", name: username!)
        } else {
            currentUser = User(id: "1", name: "Not identified")
        }
        //Initialize Watson user
        watsonUser = User(id: "2", name: "Watson")
        
        // Tell to JSQMessagesViewController who is the current user
        self.senderId = currentUser.id
        self.senderDisplayName = currentUser.name
        
        
        //Initialize Watson Services
        conversation = Conversation(username: Credentials.ConversationUsername, password: Credentials.ConversationPassword, version: Credentials.ConversationVersion)
        speechToText = SpeechToText(username: Credentials.Speech2TextUsername,password: Credentials.Speech2TextPassword)
        
        //Receive the first message
        let failure = { (error: Error) in print(error) }
        conversation.message(workspaceID: Credentials.ConversationWorkspace, failure: failure) {
            response in
            //print(response.output.text)
            for word in response.output.text {
                //let msg = JSQMessage(senderId: "2", displayName: "Watson", text: word)
                //self.messages.append(msg!)
                print(word)
            }
            self.context = response.context
        }
        self.messages.append(JSQMessage(senderId: "2", displayName: "Watson", text: "Bonjour, comment puis-je vous aider ?"))
    }
    
    override func viewDidAppear(_ animated: Bool){
        let defaults = UserDefaults.standard
        let username = defaults.string(forKey: "Identifiant")
        if (username == nil) {
            self.performSegue(withIdentifier: "loginView", sender: self);
        } else {
            //Change the current name
            currentUser.name = username!
            self.senderDisplayName = currentUser.name
            print(username!)
        }
    }
    
    
    // Start transcribing microphone audio
    @objc func startTranscribing() {
        /*SpeechToText */
        /*var settings = RecognitionSettings(contentType: .opus)
        settings.interimResults = true
        speechToText.recognizeMicrophone(settings: settings) { results in
            print(results.bestTranscript)
            self.inputToolbar.contentView.textView.text = results.bestTranscript
            self.inputToolbar.toggleSendButtonEnabled()
        }*/
        
        /* Speech on iOS*/
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
        } else {
            startRecording()
        }
        /* Speech on iOS*/
    }
    
    // Stop transcribing microphone audio
    @objc func stopTranscribing() {
        //speechToText.stopRecognizeMicrophone()
        self.inputToolbar.toggleSendButtonEnabled() //Send Button
    }
    
    @IBAction func onClickDeco(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "Identifiant")
        print("Deconnexion")
        self.performSegue(withIdentifier: "loginView", sender: self);
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        self.messages.append(message!)
        
        //Synchronisation
        let myGroup = DispatchGroup()
        //Let's wait
        myGroup.enter()
        // Send text to conversation service
        let input = InputData(text: text)
        let request = MessageRequest(input: input, context: context)
        let failure = { (error: Error) in print(error) }
        conversation.message( workspaceID: Credentials.ConversationWorkspace, request: request, failure: failure) {
            response in
            print(response.output.text)
            for word in response.output.text {
                let msg = JSQMessage(senderId: "2", displayName: "Watson", text: word)
                self.messages.append(msg!)
            }
            myGroup.leave()
        }
        
        // We received the message
        myGroup.notify(queue: .main) {
            print("message received")
            self.finishSendingMessage()
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUsername = message.senderDisplayName
        return NSAttributedString(string: messageUsername!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        //Disable attachment button
        //self.inputToolbar.contentView.leftBarButtonItem = nil
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let message = messages[indexPath.row]
        
        if currentUser.id == message.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .green)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .blue)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        // required by super class
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    //Speech on iOS
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    //Speech on iOS
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                self.inputToolbar.contentView.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
    }
    
}
