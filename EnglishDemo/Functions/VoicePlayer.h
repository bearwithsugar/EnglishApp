//
//  VoicePlayer.h
//  EnglishDemo
//
//  Created by 马一轩 on 2018/12/16.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../FreeStreamer/FSAudioStream.h"

NS_ASSUME_NONNULL_BEGIN

@interface VoicePlayer : NSObject
@property (nonatomic,strong) FSAudioStream *audioStream;
@property (nonatomic,strong) NSString* url;
@property (nonatomic,strong) NSString* netUrl;
@property (nonatomic,strong) NSString* sourceName;
@property (nonatomic,strong) NSArray* urlArray;
@property  NSInteger startIndex;

typedef void (^VoidBlock) (void);

@property VoidBlock myblock;

-(void)playAudio:(NSInteger)times;
-(void)interruptPlay;
-(void)stopPlay;
-(BOOL)isPlaying;

@end

NS_ASSUME_NONNULL_END
