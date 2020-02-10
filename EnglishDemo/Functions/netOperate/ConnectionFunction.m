//
//  ConnectionFunction.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/31.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "ConnectionFunction.h"
#import "FixValues.h"
#import <UIKit/UIKit.h>
#import "DocuOperate.h"
#import "DataFilter.h"
#import "WarningWindow.h"
#import "AgentFunction.h"
//#import "JumpToSomeView.h"

@interface ConnectionFunction(){

}
@end

@implementation ConnectionFunction

static ConnectionFunction* instance = nil;

+(ConnectionFunction *) getInstance{
    if (instance == nil) {
        instance = [[ConnectionFunction alloc] init];//调用自己改写的”私有构造函数“
    }
    return instance;
}


#pragma mark --用户管理接口
//获取修改密码的验证码
-(NSURL*)getYzmForPassword_Post:(long)phoneNumber{
    NSNumber* b=[NSNumber numberWithLong:phoneNumber];
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/user/password/code?phone="];
    str=[str2 stringByAppendingString:[b stringValue]];
    url=[NSURL URLWithString:str];
    return url;
}

//获取验证码用于登录
-(NSURL*)getYzmForReg_Post:(long)phoneNumber{
    NSNumber* b=[NSNumber numberWithLong:phoneNumber];
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/user/code?phone="];
    str=[str2 stringByAppendingString:[b stringValue]];
    url=[NSURL URLWithString:str];
    return url;
}

//验证验证码是否正确 接口通过
-(NSURL*)verifyYzm_Post:(long)phoneNumber yzm:(NSString*)yzm{
    NSNumber* a=[NSNumber numberWithLong:phoneNumber];
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/user/verify?phone="];
    str=[str2 stringByAppendingString:[a stringValue]];
    str2=[str stringByAppendingString:@"&messageCode="];
    str=[str2 stringByAppendingString:yzm];
    url=[NSURL URLWithString:str];
    return url;
}

//注册接口 接口通过
 -(NSURL*)toRegister_Post:(long)phone Pass:(NSString*)password Nick:(NSString*)nickname{
    NSNumber* a=[NSNumber numberWithLong:phone];
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/user/register?phone="];
    str=[str2 stringByAppendingString:[a stringValue]];
    str2=[str stringByAppendingString:@"&password="];
    str=[str2 stringByAppendingString:password];
    str2=[str stringByAppendingString:@"&nickname="];
    str=[str2 stringByAppendingString:nickname];
    url=[NSURL URLWithString:str];
    return url;
}

//账号密码登录接口 接口通过
 -(NSURL*)login_password_Post:(long)phone Pass:(NSString*)password Name:(NSString*)deviceName Id:(NSString*)deviceId{
    NSNumber* a=[NSNumber numberWithLong:phone];
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/user/login_password?phone="];
    str=[str2 stringByAppendingString:[a stringValue]];
    str2=[str stringByAppendingString:@"&password="];
    str=[str2 stringByAppendingString:password];
    str2=[str stringByAppendingString:@"&device_id="];
    str=[str2 stringByAppendingString:deviceId];
    str2=[str stringByAppendingString:@"&device_name="];
    str=[str2 stringByAppendingString:deviceName];
    str2=[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    url=[NSURL URLWithString:str2];
    return url;
}

//验证码登录接口
 -(NSURL*)login_yzm_Post:(long)phoneNumber Yzm:(NSString*)yzm Device:(NSString*)device_id Name:(NSString*)device_name {
    NSNumber* a=[NSNumber numberWithLong:phoneNumber];
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/user/login_code?phone="];
    str=[str2 stringByAppendingString:[a stringValue]];
    str2=[str stringByAppendingString:@"&messageCode="];
    str=[str2 stringByAppendingString:yzm];
    str2=[str stringByAppendingString:@"&device_id="];
    str=[str2 stringByAppendingString:device_id];
    str2=[str stringByAppendingString:@"&device_name="];
    str=[str2 stringByAppendingString:device_name];
    str2=[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    url=[NSURL URLWithString:str2];
    return url;
}

//用户在线状态，强制下线
 -(NSURL*)userOccupation_Post:(NSString*)openId Type:(NSString*)type Other_type:(NSString*)other_type{
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"/user/occupation?mark="];
    str=[str stringByAppendingString:openId];
    str=[str stringByAppendingString:@"&type="];
    str=[str stringByAppendingString:type];
    str=[str stringByAppendingString:@"&other_type="];
    str=[str stringByAppendingString:other_type];
    str=[str stringByAppendingString:@""];
    url=[NSURL URLWithString:str];
    return url;
}

//修改密码接口
 -(NSURL*)resetPass_Post:(long)phoneNumber Pass:(NSString*)password{
    NSURL* url=[FixValues getUrl];
    NSNumber* a=[NSNumber numberWithLong:phoneNumber];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/user/change_password?phone="];
    str=[str2 stringByAppendingString:[a stringValue]];
    str2=[str stringByAppendingString:@"&password="];
    str=[str2 stringByAppendingString:password];
    url=[NSURL URLWithString:str];
    return url;
}

#pragma mark --书架接口

//用户书架接口
 -(NSURL*)getBookShelf_Get_H{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_book/"];
    return url;
}

//添加书架接口
 -(NSURL*)addBook_Post_H:(NSString*)book_id BoughtState:(NSString*)state{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_book/"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"?book_id="];
    str=[str2 stringByAppendingString:book_id];
    str2=[str stringByAppendingString:@"&bought_state="];
    str=[str2 stringByAppendingString:state];
    url=[NSURL URLWithString:str];
    return url;
}

#pragma mark --书本信息接口
//获取选取书籍的出版社列表(根据书本分类type查询分类信息) 参数是分类的级别
 -(NSURL*)getLineByType_Get_H:(NSString*)menuType{
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/category/type/"];
    str=[str2 stringByAppendingString:menuType];
    str=[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    url=[NSURL URLWithString:str];
    return url;
}

//获取选择完年级、出版社后筛选出的书籍信息 参数是四级分类的id（年级id）
 -(NSURL*)getBookMsg_Get_H:(NSString*)publictionId UserId:(NSString*)userId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"books"];
    url=[url URLByAppendingPathComponent:publictionId];
     if (userId == nil) {
         url=[url URLByAppendingPathComponent:@"111"];
     }else{
         url=[url URLByAppendingPathComponent:userId];
     }
    return url;
}

//根据书本分类父Id查询分类信息(根据出版社获取年级列表) 参数是父级分类的id
 -(NSURL*)getLineByParent_Get_H:(NSString*)parent_id{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"category/parent"];
    url=[url URLByAppendingPathComponent:parent_id];
    return url;
}

//书本单元信息
 -(NSURL*)getUnitMsg_Get_H:(NSString*)bookId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"books/units"];
    url=[url URLByAppendingPathComponent:bookId];
    return url;
}

//书本单元下的课信息
 -(NSURL*)getClassMsg_Get_H:(NSString*)unitId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"books/articles"];
    url=[url URLByAppendingPathComponent:unitId];
    return url;
}

//每一课的教学信息
 -(NSURL*)getLessonMsg_Get_H:(NSString*)classId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"books/teach"];
    url=[url URLByAppendingPathComponent:classId];
    return url;
}

#pragma mark --学习进度信息接口
//增加句子学习信息记录
 -(NSURL*)addSentenceMsg_Post_H:(NSString*)sentenceId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_sentence"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?sentence_id="];
    str=[str stringByAppendingString:sentenceId];
    url=[NSURL URLWithString:str];
    return url;
}

//查询单元学习进度
 -(NSURL*)unitProcess_Get_H:(NSString*)bookId  {
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_unit"];
    url=[url URLByAppendingPathComponent:bookId];
    return url;
}

//增加用户课学习信息并扣除学分   这个接口路径不需要引号
 -(NSURL*)addUserArticleMsg_Post_H:(NSString*)articleId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_article"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?article_id="];
    str=[str stringByAppendingString:articleId];
    url=[NSURL URLWithString:str];
    return url;
}
// 添加用户图片学习进度信息   这个接口路径不需要引号
 -(NSURL*)addUserPictureMsg_Post_H:(NSString*)pictureId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_picture"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?picture_id="];
    str=[str stringByAppendingString:pictureId];
    url=[NSURL URLWithString:str];
    return url;
}

//获取用户课的购买状态
 -(NSURL*)articleBuyState_Get_H:(NSString*)bookId  {
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_article"];
    url=[url URLByAppendingPathComponent:bookId];
    return url;
}

#pragma mark --用户信息模块
//修改用户信息
 -(NSURL*)modifyUserMsg_Put_H:(NSString*)nickname Phone:(NSString*)phone Password:(NSString*)password{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"account/info"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?nickname="];
    str=[str stringByAppendingString:nickname];
    str=[str stringByAppendingString:@"&phone="];
    str=[str stringByAppendingString:phone];
    str=[str stringByAppendingString:@"&password="];
    str=[str stringByAppendingString:password];
    str=[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    url=[NSURL URLWithString:str];
    return url;
}

//获取学分
 -(NSURL*)getScore_Get_H{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"account/score"];
    return url;
}

//充值学分
-(NSURL*)increaseScore_Post_H:(NSString*)money StrategyId:(NSString*)strategyId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"payments/apple"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?money="];
    str=[str stringByAppendingString:money];
    str=[str stringByAppendingString:@"&strategy_id="];
    str=[str stringByAppendingString:strategyId];
    url=[NSURL URLWithString:str];
    return url;
}

//获取用户第三方绑定信息

-(NSURL*)getBindingMsg_Get_H{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"/account/binding"];
    return url;
}

#pragma mark --测试模块
//句子信息查询
 -(NSURL*)getTestSentenceMsg_Get_H:(NSString*)articleId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"tests/sentences/"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:articleId];
    url=[NSURL URLWithString:str];
    return url;
}

// 添加错题信息
 -(NSURL*)addWrongMsg_Post_H:(NSString*)wrongId  Type:(NSString*)type{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"tests/wrongs"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?type="];
    str=[str stringByAppendingString:type];
    str=[str stringByAppendingString:@"&id="];
    str=[str stringByAppendingString:wrongId];
    url=[NSURL URLWithString:str];
    return url;
}

// 删除错题
 -(NSURL*)deleteWrongMsg_Delete_H:(NSString*)content_id{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"tests/wrongs"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?content_id="];
    str=[str stringByAppendingString:content_id];
    url=[NSURL URLWithString:str];
    return url;
}

// 获取错题信息
 -(NSURL*)getWrongMsg_Get_H:(NSString*)articleId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"tests/wrongs"];
    url=[url URLByAppendingPathComponent:articleId];
    return url;
}

// 使用block获取错题信息
-(NSURL*)getWrongMsgWithBlock_Get_H:(NSString*)articleId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"tests/wrongs"];
    url=[url URLByAppendingPathComponent:articleId];
    return url;
}

#pragma mark --版本信息

//版本信息
 -(NSURL*)getVersionMsg_Get_H{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"version/"];
    return url;
}

#pragma mark --最近学习信息
//直接获取最近学习信息
 -(NSURL*)recentLearnMsg_Get_H{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"recent"];
    return url;
}


//用户书本学习信息
-(NSURL*)getBookLearnMsg_Get_H:(NSString*)bookId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_bookinfo"];
    url=[url URLByAppendingPathComponent:bookId];
    return url;
}


//修改句子学习信息记录
 -(NSURL*)fixSentenceMsg_Get_H:(NSString*)sentenceId Grade:(NSString*)grade{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_sentence"];
    url=[url URLByAppendingPathComponent:sentenceId];
    url=[url URLByAppendingPathComponent:grade];
    return url;
}

//获取用户句子学习信息记录   但是传参传课本id
-(NSURL*)getUserSentenceMsg_Get_H:(NSString*)articleId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_sentence"];
    url=[url URLByAppendingPathComponent:articleId];
    return url;
}

//获取用户图片学习进度信息
 -(NSURL*)getUserPictureMsg_Get_H:(NSString*)pictureId  {
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_picture"];
    url=[url URLByAppendingPathComponent:pictureId];
     
    return url;
}
//获取用户学习时长信息
 -(NSURL*)getLearningTime_Put_H:(NSString*)bookId Time:(NSString*)learningTime{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_learningtime"];
    url=[url URLByAppendingPathComponent:bookId];
    url=[url URLByAppendingPathComponent:learningTime];
    return url;
}

//单词信息查询
 -(NSURL*)getTestWordMsg_Get_H:(NSString*)articleId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"tests/words"];
    url=[url URLByAppendingPathComponent:articleId];
    return url;
}

#pragma mark --订单模块
//订单查询
 -(NSURL*)searchOrders_Get_H{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"orders"];
    return url;
}


//根据书籍获取最近学习信息
 -(NSURL*)recentLearnMsgByBook_Get_H:(NSString*)bookId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"recent"];
    url=[url URLByAppendingPathComponent:bookId];
    return url;
}
#pragma mark --用户意见
// 用户意见反馈
 -(NSURL*)feedback_Post_H:(NSString*)opinion {
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"feedback/"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?content='"];
    str=[str stringByAppendingString:opinion];
    str=[str stringByAppendingString:@"'"];
    str=[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    url=[NSURL URLWithString:str];
    return url;
}

#pragma mark --设备信息
//设备绑定信息
 -(NSURL*)deviceBinding_Get_H{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"device/release"];
    return url;
}

//设备解除绑定
 -(NSURL*)deleteBinding_Delete_H:(NSString*)deviceId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"device/release"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?device_id="];
    str=[str stringByAppendingString:deviceId];
    url=[NSURL URLWithString:str];
    return url;
}

#pragma mark --支付
//支付策略
 -(NSURL*)getStrategies_Get_H{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"strategies/"];
    return url;
}

//订单查询
 -(NSURL*)orderMsg_Get_H{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"orders/"];
    return url;
}

#pragma mark --微信第三方登录接口
//微信获取access_token
 -(NSURL*)getWXaccess_Get:(NSString*)code{
    NSURL* url=[FixValues getWXaccessUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?appid="];
    str=[str stringByAppendingString: [FixValues getAppId]];
    str=[str stringByAppendingString: @"&secret="];
    str=[str stringByAppendingString: [FixValues getAppSecret]];
    str=[str stringByAppendingString: @"&code="];
    str=[str stringByAppendingString:code];
    str=[str stringByAppendingString:@"&grant_type=authorization_code"];
    url=[NSURL URLWithString:str];
    return url;
}

//微信获取个人信息
 -(NSURL*)getWXuserMsg_Get:(NSString*)access_token Openid:(NSString*)openid{
    NSURL* url=[FixValues getWXuserMsgUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?access_token="];
    str=[str stringByAppendingString:access_token];
    str=[str stringByAppendingString:@"&openid="];
    str=[str stringByAppendingString:openid];
    url=[NSURL URLWithString:str];
    return url;
}

//第三方登录
 -(NSURL*)OtherLogin_Post:(NSString*)openid Nickname:(NSString*)nickname DeviceId:(NSString*)device_id DeviceName:(NSString*)device_name Type:(NSString*)type Pic:(NSString*)picurl{
     if (nickname == nil) {
         nickname = @"";
     }
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user/login_other"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?openId="];
    str=[str stringByAppendingString:openid];
    str=[str stringByAppendingString:@"&nickname="];
    str=[str stringByAppendingString:nickname];
    str=[str stringByAppendingString:@"&device_id="];
    str=[str stringByAppendingString:device_id];
    str=[str stringByAppendingString:@"&device_name="];
    str=[str stringByAppendingString:device_name];
    str=[str stringByAppendingString:@"&type="];
    str=[str stringByAppendingString:type];
    str=[str stringByAppendingString:@"&pictureUrl="];
    str=[str stringByAppendingString:picurl];
    str=[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    url=[NSURL URLWithString:str];
    return url;
}

//绑定
-(NSURL*)toBinding_Post_H:(NSString*)openId Type:(NSString*)type Picurl:(NSString*)picurl{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"account/binding"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?openId="];
    str=[str stringByAppendingString:openId];
    str=[str stringByAppendingString:@"&type="];
    str=[str stringByAppendingString:type];
    str=[str stringByAppendingString:@"&pictureUrl="];
    str=[str stringByAppendingString:picurl];
    str=[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    url=[NSURL URLWithString:str];
    return url;
}


@end
