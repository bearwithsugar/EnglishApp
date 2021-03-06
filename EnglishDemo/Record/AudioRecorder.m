//
//  AudioRecorder.m
//  AudioRecorder
//
//  Created by builder on 2018/4/24.
//  Copyright © 2018年 builder. All rights reserved.
//

#import "AudioRecorder.h"

@interface AudioRecorder ()<AVAudioRecorderDelegate>

@property (nonatomic,assign) id<AudioRecorderDelegate> delegate;
@property (nonatomic,strong) AVAudioRecorder *avAudioRecorder;          //录音
@property (nonatomic,strong) NSMutableDictionary *audioRecorderSetting; //录音设置
@property (nonatomic,strong) NSTimer *recorderTimer;                    //录音音量计时器
@property (nonatomic,copy) NSString *recordFilePath;                    //录音文件路径
@property (nonatomic,assign) double audioRecorderTime;                  //录音时长


@end

@implementation AudioRecorder

#pragma mark - 初始化

- (instancetype)init{
    self = [super init];
    if (self) {
        
        [self initAudioRecorderSetting];
    }
    return self;
}

/// 参数设置 格式、采样率、录音通道、线性采样位数、录音质量
- (void)initAudioRecorderSetting{
    self.audioRecorderSetting = [NSMutableDictionary dictionary];
    
    [self.audioRecorderSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    
    [self.audioRecorderSetting setValue:[NSNumber numberWithInt:11025] forKey:AVSampleRateKey];
   
    [self.audioRecorderSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    
    [self.audioRecorderSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    [self.audioRecorderSetting setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    
    [self.audioRecorderSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
}

///单例
+ (AudioRecorder *)shareInstance{
    static AudioRecorder *staticAudioRecorder;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        staticAudioRecorder = [[self alloc] init];
    });
    return staticAudioRecorder;
}
///设置委托
- (void)setRecorderDelegate:(id<AudioRecorderDelegate>)recorderDelegate{
    self.delegate = recorderDelegate;
}
///设置录音配置
- (void)setRecorderSetting:(NSMutableDictionary *)settingDict{
    self.audioRecorderSetting = settingDict;
}
///开始录音
- (NSError *)startRecordWithFilePath:(NSString *)filePath{
    
    self.recordFilePath = filePath;
    
    //若有，先停止
    [self stopRecord];
    //生成录音文件
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSError *error = nil;
    self.avAudioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:self.audioRecorderSetting error:&error];
    
    // 开启音量检测
    self.avAudioRecorder.meteringEnabled = YES;
    self.avAudioRecorder.delegate = self;
    
    if (self.avAudioRecorder&&(error==nil)) {
        // 录音时设置audioSession属性，否则不兼容Ios7
        AVAudioSession *recoderSession = [AVAudioSession sharedInstance];//设置成能播放且能录音
        [recoderSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [recoderSession setActive:YES error:nil];
        
        if ([self.avAudioRecorder prepareToRecord]) {
            self.audioRecorderTime = 0;//时长
            [self.avAudioRecorder record];
            
            //开启定时器，刷新音量
            [self startTimer];
        }
    }
    return error;
}
///停止录音
- (void)stopRecord{
    if (self.avAudioRecorder) {
        if ([self.avAudioRecorder isRecording]) {
            //设置录音时长
            self.audioRecorderTime = [self.avAudioRecorder currentTime];
            
            [self.avAudioRecorder stop];
        }
        self.avAudioRecorder = nil;
    }
    //停掉计时器
    [self stopTimer];
}
///获取录音路径
- (NSString *)getRecordFilePath{
    return self.recordFilePath;
}
///获取录音时长
- (NSTimeInterval )getRecordDurationWithFilePath:(NSString *)filePath{
    
    if (filePath==nil)
        return self.audioRecorderTime;
    
    //耗时操作
    NSURL *urlFile = [NSURL fileURLWithPath:filePath];
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlFile error:nil];
    NSTimeInterval time = audioPlayer.duration;
    audioPlayer = nil;
    return time;
}

///获得录音实例
- (AVAudioRecorder *)getAVAudioRecorder{
    return self.avAudioRecorder;
}

#pragma mark - timer

- (void)startTimer{
    [self stopTimer];
    self.recorderTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(recorderVoiceChange) userInfo:nil repeats:YES];
}

- (void)stopTimer{
    if (self.recorderTimer)
        [self.recorderTimer invalidate];
    self.recorderTimer = nil;
}

/// 录音音量显示
- (void)recorderVoiceChange{
    if (self.avAudioRecorder) {
        // 刷新音量数据
        [self.avAudioRecorder updateMeters];
      
        //获取第一个通道的音频，注音音频的强度方位-160到0
        float power = [self.avAudioRecorder averagePowerForChannel:0];
        double lowPassResults = pow(10, (0.05 * power));//0~1
        
        //委托传值
        if (self.delegate&&([self.delegate respondsToSelector:@selector(audioRecorderDidVoiceChanged: value:)])) {
            [self.delegate audioRecorderDidVoiceChanged:self value:lowPassResults];
        }
    }
}



#pragma mark - delegate

/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    //委托传值
    if (self.delegate&&([self.delegate respondsToSelector:@selector(audioRecorderDidFinished: successfully:)])) {
        [self.delegate audioRecorderDidFinished:self successfully:flag];
    }
}


#pragma mark - dealloc
/// 内存释放
- (void)dealloc{
    // 内存释放前先停止录音
    if (self.avAudioRecorder){
        if ([self.avAudioRecorder isRecording])
            [self.avAudioRecorder stop];
        self.avAudioRecorder = nil;
    }
    //停掉计时器
    [self stopTimer];
    
    if (self.audioRecorderSetting)
        self.audioRecorderSetting = nil;
    
}

@end
