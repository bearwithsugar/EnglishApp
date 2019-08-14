//
//  AudioRecorder.h
//  AudioRecorder
//
//  Created by builder on 2018/4/24.
//  Copyright © 2018年 builder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class AudioRecorder;
@protocol AudioRecorderDelegate <NSObject>

@optional

- (void)audioRecorderDidVoiceChanged:(AudioRecorder *)recorder value:(double)value;

- (void)audioRecorderDidFinished:(AudioRecorder *)recorder successfully:(BOOL)flag;

@end

@interface AudioRecorder : NSObject

#pragma mark - 录音

+ (AudioRecorder *)shareInstance;

- (void)setRecorderDelegate:(id<AudioRecorderDelegate>)recorderDelegate;

- (void)setRecorderSetting:(NSMutableDictionary *)settingDict;

- (NSError *)startRecordWithFilePath:(NSString *)filePath;

- (void)stopRecord;

- (NSString *)getRecordFilePath;

- (NSTimeInterval )getRecordDurationWithFilePath:(NSString *)filePath;

- (AVAudioRecorder *)getAVAudioRecorder;

@end
