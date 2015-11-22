//: Playground - noun: a place where people can play

import UIKit
import AVFoundation
import Giphy
import XCPlayground
import MediaPlayer

class Restarter: NSObject {
    let player : AVPlayer
    init(player: AVPlayer) {
        self.player = player
    }
    func loopIt() {
        player.seekToTime(CMTimeMake(0, 1))
        player.play()
    }
}
func loopIt(player : AVPlayer) -> Restarter {
    player.actionAtItemEnd = .None
    let restarter = Restarter(player: player)
    NSNotificationCenter.defaultCenter().addObserver(restarter, selector: "loopIt", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
    return restarter
}

// let uptownFunk = NSURL(string: "http://a905.phobos.apple.com/us/r1000/173/Music5/v4/e2/e2/60/e2e260ca-b3d8-f8a4-1b7c-ffd95eea52c1/mzaf_6400110211813760072.plus.aac.p.m4a")
 let song = NSURL(string: "http://a1188.phobos.apple.com/us/r1000/165/Music6/v4/50/37/e9/5037e943-30b9-ed7e-24a5-08733daab18b/mzaf_4607255974230314462.plus.aac.p.m4a")
//let song = NSURL(string: "http://a462.phobos.apple.com/us/r1000/134/Music69/v4/bb/93/43/bb934369-4066-12e1-df27-525a5f7be1fc/mzaf_3032917019037990706.plus.aac.p.m4a")

let giphy = Giphy(apiKey: "dc6zaTOxFJmzC")

let sem = dispatch_semaphore_create(0)

var gifs : [Giphy.Gif]?

giphy.search("funk", limit: 10, offset: nil, rating: nil) { (theGifs, _, err) -> Void in
    
    gifs = theGifs
    
    dispatch_semaphore_signal(sem)
}

dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)

assert(gifs!.count > 0)
let gif = gifs![1]
let md = gif.gifMetadataForType(Giphy.Gif.ImageVersion.Original, still: false)

var f = CGRectMake(0, 0, 500, 300)

let player = AVPlayer(URL: md.mp4URL!)
let playerLayer = AVPlayerLayer(player: player)
player.actionAtItemEnd = .None

var v = UIView(frame: f)
v.backgroundColor = UIColor.blackColor()
playerLayer.frame = f
v.layer.addSublayer(playerLayer)
let r = loopIt(player)
player.play()

let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
musicPlayer.setQueueWithQuery(MPMediaQuery.songsQuery())
musicPlayer.shuffleMode = .Songs
musicPlayer.play()

XCPlaygroundPage.currentPage.liveView = v
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
    sleep(10)
    XCPlaygroundPage.currentPage.finishExecution()
}
