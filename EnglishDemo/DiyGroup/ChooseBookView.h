//
//  ChooseBookView.h
//  EnglishDemo
//
//  Created by 马一轩 on 2020/1/28.
//  Copyright © 2020 马一轩. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChooseBookView : UIView

typedef void (^NSIntegerBlock) (NSInteger,NSArray* gradesArr);

@property NSIntegerBlock jobBlock;
@property (nonatomic,copy) NSArray* publicationArray;
@property (nonatomic,copy) NSArray* gradesArray;
@property (nonatomic,copy) NSString* userKey;

-(id)initWithBlock:(NSIntegerBlock)block User:(NSString*)user PublicationArray:(NSArray*)array;

@end

NS_ASSUME_NONNULL_END
