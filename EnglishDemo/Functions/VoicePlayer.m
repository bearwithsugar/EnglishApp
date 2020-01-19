//
//  VoicePlayer.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/12/16.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "VoicePlayer.h"

#import <AVFoundation/AVFoundation.h>

#import "DownloadAudioService.h"

@interface VoicePlayer()<AVAudioPlayerDelegate>{}

@property(nonatomic,strong)AVAudioPlayer *movePlayer ;

@property NSInteger times ;

@end
@implementation VoicePlayer


-(NSURL *)getNetworkUrl
{
    NSString *urlStr =_url;
    NSURL *url = [NSURL URLWithString:urlStr];
    return url;
}


-(FSAudioStream *)audioStream
{
    if (!_audioStream)
    {
        NSURL *url = [self getNetworkUrl];
        //创建FSAudioStream对象
        _audioStream = [[FSAudioStream alloc]initWithUrl:url];
        
        _audioStream.onFailure = ^(FSAudioStreamError error,NSString *description){
            NSLog(@"播放过程中发生错误，错误信息：%@",description);
        };

        _audioStream.onCompletion = _myblock;
        [_audioStream setVolume:0.5];//设置声音
    }
    return _audioStream;
}

//根据l本地路径播放声音
-(void)playAudio:(NSInteger)times{
    _times = times;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    // 1.加载本地的音乐文件
    NSURL *url = [NSURL fileURLWithPath:_url];
    // 2. 创建音乐播放对象
    _movePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _movePlayer.delegate = self;
    
    NSString *msg = [NSString stringWithFormat:@"音频文件声道数:%ld\n 音频文件持续时间:%g",_movePlayer.numberOfChannels,_movePlayer.duration];
    NSLog(@"%@",msg);
    
    // 3.准备播放 (音乐播放的内存空间的开辟等功能)  不写这行代码直接播放也会默认调用prepareToPlay
    [_movePlayer prepareToPlay];
    
    _movePlayer.numberOfLoops = times;
    
    [_movePlayer play];
}

-(void)stopPlay{
    [_movePlayer stop];
}

-(BOOL)isPlaying{
    return [_movePlayer isPlaying];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    _myblock();
    [self continuePlay];
}

- (void) continuePlay{
    if(_startIndex == _urlArray.count || _urlArray == nil){
        return;
    }
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    // 1.加载本地的音乐文件
    NSURL *url = [NSURL fileURLWithPath:
                  [DownloadAudioService getAudioPath:
                                         [NSString stringWithFormat:@"%@",[[_urlArray objectAtIndex:_startIndex++]valueForKey:@"id"]]]];
    // 2. 创建音乐播放对象
    _movePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _movePlayer.delegate = self;
    
    NSString *msg = [NSString stringWithFormat:@"音频文件声道数:%ld\n 音频文件持续时间:%g",_movePlayer.numberOfChannels,_movePlayer.duration];
    NSLog(@"%@",msg);
    
    // 3.准备播放 (音乐播放的内存空间的开辟等功能)  不写这行代码直接播放也会默认调用prepareToPlay
    [_movePlayer prepareToPlay];
    
    _movePlayer.numberOfLoops = _times;
    
    [_movePlayer play];
}

/**
 播放过程被打断
 
 */
-(void)interruptPlay{
    _myblock();
    NSLog(@"播放过程被打断");
}


@end
