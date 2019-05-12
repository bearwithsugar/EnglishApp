//
//  VoicePlayer.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/12/16.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "VoicePlayer.h"

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
           // NSLog(@"错误播放的路径是%@",url);
        };
//        _audioStream.onCompletion = ^(){
//            NSLog(@"播放完成!");
//           // NSLog(@"正确播放的路径是%@",url);
//
//        };
        _audioStream.onCompletion = _myblock;
        [_audioStream setVolume:0.5];//设置声音
    }
    return _audioStream;
}

@end
