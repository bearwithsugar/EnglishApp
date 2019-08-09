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



#pragma mark --用户管理接口
//获取验证码用于登录
+(NSDictionary*)getYzm:(long)phoneNumber{
    NSNumber* b=[NSNumber numberWithLong:phoneNumber];
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/user/password/code?phone="];
    str=[str2 stringByAppendingString:[b stringValue]];
    url=[NSURL URLWithString:str];
    return [self postRequest:url];
}
//获取修改密码的验证码
+(NSDictionary*)getYzmForPassword:(long)phoneNumber{
    NSNumber* b=[NSNumber numberWithLong:phoneNumber];
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/user/code?phone="];
    str=[str2 stringByAppendingString:[b stringValue]];
    url=[NSURL URLWithString:str];
    return [self postRequest:url];
}


//验证验证码是否正确 接口通过
+(NSDictionary*)verifyYzm:(long)phoneNumber yzm:(NSString*)yzm{
    NSNumber* a=[NSNumber numberWithLong:phoneNumber];
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/user/verify?phone="];
    str=[str2 stringByAppendingString:[a stringValue]];
    str2=[str stringByAppendingString:@"&messageCode="];
    str=[str2 stringByAppendingString:yzm];
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self postRequest:url];
    return dataDic;
}


//注册接口 接口通过
+(NSDictionary*)toRegister:(long)phone Pass:(NSString*)password Nick:(NSString*)nickname{
    NSNumber* a=[NSNumber numberWithLong:phone];
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/user/register?phone="];
    str=[str2 stringByAppendingString:[a stringValue]];
    str2=[str stringByAppendingString:@"&password='"];
    str=[str2 stringByAppendingString:password];
    str2=[str stringByAppendingString:@"'&nickname='"];
    str=[str2 stringByAppendingString:nickname];
    str2=[str stringByAppendingString:@"'"];
    url=[NSURL URLWithString:str2];
    NSDictionary* dataDic=[self postRequest:url];
    return dataDic;
}

//账号密码登录接口 接口通过
+(NSDictionary*)login_password:(long)phone Pass:(NSString*)password Name:(NSString*)deviceName Id:(NSString*)deviceId{
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
    NSDictionary* dataDic=[self postRequest:url];
    return dataDic;
}

//验证码登录接口  接口通过
+(NSDictionary*)login_yzm:(long)phoneNumber yzm:(NSString*)yzm{
    NSNumber* a=[NSNumber numberWithLong:phoneNumber];
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/user/login_code?phone="];
    str=[str2 stringByAppendingString:[a stringValue]];
    str2=[str stringByAppendingString:@"&messageCode="];
    str=[str2 stringByAppendingString:yzm];
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self postRequest:url];
    return dataDic;
}

//用户在线状态，强制下线
+(NSDictionary*)userOccupation:(NSString*)openId Type:(NSString*)type Other_type:(NSString*)other_type{
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
    NSDictionary* dataDic=[self postRequest:url];
    return dataDic;
}

//修改密码接口
+(NSDictionary*)resetPass:(long)phoneNumber Pass:(NSString*)password{
    NSURL* url=[FixValues getUrl];
    NSNumber* a=[NSNumber numberWithLong:phoneNumber];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/user/change_password?phone="];
    str=[str2 stringByAppendingString:[a stringValue]];
    str2=[str stringByAppendingString:@"&password="];
    str=[str2 stringByAppendingString:password];
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self postRequest:url];
    return dataDic;
}

#pragma mark --书架接口

//用户书架接口
+(NSDictionary*)getBookShelf:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_book/"];
    return [self threadTwoGetRequestWithHead:userkey Path:url];
}

//添加书架接口
+(NSDictionary*)addBook:(NSString*)book_id BoughtState:(NSString*)state UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_book/"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"?book_id="];
    str=[str2 stringByAppendingString:book_id];
    str2=[str stringByAppendingString:@"&bought_state="];
    str=[str2 stringByAppendingString:state];
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self postRequestWithHead:url Head:userkey];
    return dataDic;
}

#pragma mark --书本信息接口
//获取选取书籍的出版社列表(根据书本分类type查询分类信息) 参数是分类的级别
+(NSDictionary*)getLineByType:(NSString*)menuType UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    NSString* str2=[str stringByAppendingString:@"/category/type/"];
    str=[str2 stringByAppendingString:menuType];
    str=[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}

//获取选择完年级、出版社后筛选出的书籍信息 参数是四级分类的id（年级id）
+(NSDictionary*)getBookMsg:(NSString*)publictionId UserKey:(NSString*)userkey UserId:(NSString*)userId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"books"];
    url=[url URLByAppendingPathComponent:publictionId];
    url=[url URLByAppendingPathComponent:userId];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}

//根据书本分类父Id查询分类信息(根据出版社获取年级列表) 参数是父级分类的id
+(NSDictionary*)getLineByParent:(NSString*)parent_id UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"category/parent"];
    url=[url URLByAppendingPathComponent:parent_id];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}

//书本单元信息
+(NSDictionary*)getUnitMsg:(NSString*)bookId UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"books/units"];
    url=[url URLByAppendingPathComponent:bookId];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}

//书本单元下的课信息
+(NSDictionary*)getClassMsg:(NSString*)unitId UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"books/articles"];
    url=[url URLByAppendingPathComponent:unitId];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}

//每一课的教学信息
+(NSDictionary*)getLessonMsg:(NSString*)classId UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"books/teach"];
    url=[url URLByAppendingPathComponent:classId];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}



#pragma mark --学习进度信息接口
//增加句子学习信息记录
+(NSDictionary*)addSentenceMsg:(NSString*)sentenceId UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_sentence"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?sentence_id="];
    str=[str stringByAppendingString:sentenceId];
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self postRequestWithHead:url Head:userkey];
    return dataDic;
}

//查询单元学习进度
+(NSDictionary*)unitProcess:(NSString*)bookId UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_unit"];
    url=[url URLByAppendingPathComponent:bookId];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}
//增加用户课学习信息并扣除学分   这个接口路径不需要引号
+(NSDictionary*)addUserArticleMsg:(NSString*)articleId  UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_article"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?article_id="];
    str=[str stringByAppendingString:articleId];
    //str=[str stringByAppendingString:@"'"];
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self postRequestWithHead:url Head:userkey];
    return dataDic;
}
// 添加用户图片学习进度信息   这个接口路径不需要引号
+(NSDictionary*)addUserPictureMsg:(NSString*)pictureId  UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_picture"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?picture_id="];
    str=[str stringByAppendingString:pictureId];
    //str=[str stringByAppendingString:@"'"];
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self postRequestWithHead:url Head:userkey];
    return dataDic;
}
//获取用户课的购买状态
+(NSDictionary*)articleBuyState:(NSString*)bookId UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_article"];
    url=[url URLByAppendingPathComponent:bookId];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}

#pragma mark --用户信息模块
//修改用户信息
+(NSDictionary*)modifyUserMsg:(NSString*)nickname UserKey:(NSString*)userkey Phone:(NSString*)phone Password:(NSString*)password{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"account/info"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?nickname="];
    str=[str stringByAppendingString:nickname];
    str=[str stringByAppendingString:@"&phone="];
    str=[str stringByAppendingString:phone];
    str=[str stringByAppendingString:@"&password="];
    str=[str stringByAppendingString:password];
    url=[NSURL URLWithString:str];
    
    NSDictionary* dataDic=[self putRequestWithHead:url Head:userkey];
    return dataDic;
}
//获取学分
+(NSDictionary*)getScore:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"account/score"];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}


//获取用户第三方绑定信息

+(NSDictionary*)getBindingMsg:(NSString*)userkey{
    
    NSURL* url=[FixValues getUrl];
    
    url=[url URLByAppendingPathComponent:@"/account/binding"];
    
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    
    return dataDic;
    
}

#pragma mark --测试模块
//句子信息查询
+(NSDictionary*)getTestSentenceMsg:(NSString*)articleId UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"tests/sentences/"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    //str=[str stringByAppendingString:@"'"];
    str=[str stringByAppendingString:articleId];
    //str=[str stringByAppendingString:@"'"];
    
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}
// 添加错题信息
+(NSDictionary*)addWrongMsg:(NSString*)userkey Id:(NSString*)wrongId  Type:(NSString*)type{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"tests/wrongs"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?type="];
    str=[str stringByAppendingString:type];
    str=[str stringByAppendingString:@"&id="];
    str=[str stringByAppendingString:wrongId];
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self postRequestWithHead:url Head:userkey];
    return dataDic;
}

#pragma mark --版本信息

//版本信息
+(NSDictionary*)getVersionMsg :(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"version/"];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}

#pragma mark --最近学习信息
//直接获取最近学习信息
+(NSDictionary*)recentLearnMsg:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"recent"];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}


//下面的接口还没有验证👇

// 获取错题信息
+(NSDictionary*)getWrongMsg:(NSString*)userkey Id:(NSString*)articleId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"tests/wrongs"];
    url=[url URLByAppendingPathComponent:articleId];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}

//用户书本学习信息
+(NSDictionary*)getBookLearnMsg:(NSString*)userkey Id:(NSString*)bookId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_bookinfo"];
    url=[url URLByAppendingPathComponent:bookId];
    NSDictionary* dataDic=[self threadGetRequestWithHead:userkey Path:url];
    return dataDic;
}


//修改句子学习信息记录
+(NSDictionary*)fixSentenceMsg:(NSString*)sentenceId UserKey:(NSString*)userkey Grade:(NSString*)grade{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_sentence"];
    url=[url URLByAppendingPathComponent:sentenceId];
    url=[url URLByAppendingPathComponent:grade];
    NSDictionary* dataDic=[self putRequestWithHead:url Head:userkey];
    return dataDic;
}

//获取用户句子学习信息记录   显示用户句子以前读的分数的
+(NSDictionary*)getUserSentenceMsg:(NSString*)sentenceId UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_sentence"];
    url=[url URLByAppendingPathComponent:sentenceId];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}

//获取用户图片学习进度信息
+(NSDictionary*)getUserPictureMsg:(NSString*)pictureId UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_picture"];
    url=[url URLByAppendingPathComponent:pictureId];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}
//获取用户学习时长信息
+(NSDictionary*)getLearningTime:(NSString*)bookId UserKey:(NSString*)userkey Time:(NSString*)learningTime{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"user_learningtime"];
    url=[url URLByAppendingPathComponent:bookId];
    url=[url URLByAppendingPathComponent:learningTime];
    NSDictionary* dataDic=[self putRequestWithHead:url Head:userkey];
    return dataDic;
}



//单词信息查询
+(NSDictionary*)getTestWordMsg:(NSString*)articleId UserKey:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"tests/words"];
    url=[url URLByAppendingPathComponent:articleId];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}



#pragma mark --订单模块
//订单查询
+(NSDictionary*)searchOrders:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"orders"];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}


//根据书籍获取最近学习信息
+(NSDictionary*)recentLearnMsgByBook:(NSString*)userkey Id:(NSString*)bookId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"recent"];
    url=[url URLByAppendingPathComponent:bookId];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}
#pragma mark --用户意见
// 用户意见反馈
+(NSDictionary*)feedback:(NSString*)userkey Opinion:(NSString*)opinion {
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"feedback/"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?content='"];
    str=[str stringByAppendingString:opinion];
    str=[str stringByAppendingString:@"'"];
    str=[str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self postRequestWithHead:url Head:userkey];
    return dataDic;
}

#pragma mark --设备信息
//设备绑定信息
+(NSDictionary*)deviceBinding:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"device/release"];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}

//设备解除绑定
+(NSDictionary*)deleteBinding:(NSString*)userkey DeviceId:(NSString*)deviceId{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"device/release"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?device_id="];
    str=[str stringByAppendingString:deviceId];
    url=[NSURL URLWithString:str];
    
    NSDictionary* dataDic=[self deleteRequestWithHead:url Head:userkey];
    return dataDic;
}

#pragma mark --支付
//支付策略
+(NSDictionary*)getStrategies:(NSString*)userKey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"strategies/"];
    NSDictionary* dataDic=[self getRequestWithHead:userKey Path:url];
    return dataDic;
}

// 支付宝支付
+(NSDictionary*)Alipay:(NSString*)userkey Money:(NSString*)money  Strategy:(NSString*)strategy_id {
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"payments/ali"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?money="];
    str=[str stringByAppendingString:money];
    str=[str stringByAppendingString:@"&strategy_id="];
    str=[str stringByAppendingString:strategy_id];
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self postRequestWithHead:url Head:userkey];
    return dataDic;
}
//微信支付
+(NSDictionary*)WeChatpay:(NSString*)userkey Money:(NSString*)money  Strategy:(NSString*)strategy_id {
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"payments/weixin"];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?money="];
    str=[str stringByAppendingString:money];
    str=[str stringByAppendingString:@"&strategy_id="];
    str=[str stringByAppendingString:strategy_id];
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self postRequestWithHead:url Head:userkey];
    return dataDic;
}
//订单查询
+(NSDictionary*)orderMsg:(NSString*)userkey{
    NSURL* url=[FixValues getUrl];
    url=[url URLByAppendingPathComponent:@"orders/"];
    NSDictionary* dataDic=[self getRequestWithHead:userkey Path:url];
    return dataDic;
}
#pragma mark --微信第三方登录接口
//微信获取access_token
+(NSDictionary*)getWXaccess:(NSString*)code{
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
    NSDictionary* dataDic=[self getRequest:url];
    return dataDic;
}

//微信获取个人信息
+(NSDictionary*)getWXuserMsg:(NSString*)access_token Openid:(NSString*)openid{
    NSURL* url=[FixValues getWXuserMsgUrl];
    NSString* str=[NSString stringWithFormat:@"%@",url];
    str=[str stringByAppendingString:@"?access_token="];
    str=[str stringByAppendingString:access_token];
    str=[str stringByAppendingString:@"&openid="];
    str=[str stringByAppendingString:openid];
    url=[NSURL URLWithString:str];
    NSDictionary* dataDic=[self getRequest:url];
    return dataDic;
}

//===============下面的三个方法必须分为三个方法且在一个类中，
//微信登录代理方法
+(void)WXLoginAgent:(NSString*)code{
    NSLog(@"接受的授权的信息%@",code);
    NSDictionary* accessDic=[self getWXaccess:code];
    NSString* access_token=[accessDic valueForKey:@"access_token"];
    NSString* openid=[accessDic valueForKey:@"openid"];
    NSDictionary* userMsg=[self getWXuserMsg:access_token Openid:openid];
    NSLog(@"userMsg=%@",userMsg);
    [self WXtoLogin:userMsg];
}
//微信登录
+(void)WXtoLogin:(NSDictionary*)userMsg{
    NSDictionary* wxLogDic=[self OtherLogin:[userMsg valueForKey:@"openid"]
                                   Nickname:[userMsg valueForKey:@"nickname"]
                                   DeviceId:[FixValues getUniqueId]
                                 DeviceName:[[UIDevice currentDevice] name]
                                       Type:@"WEIXIN"
                                        Pic:[userMsg valueForKey:@"headimgurl"]];
    NSLog(@"微信登录结果%@",wxLogDic);
    if ([[wxLogDic valueForKey:@"message"]isEqualToString:@"success"]) {
        //dictionary：过滤字典中空值
        if ([DocuOperate writeIntoPlist:@"userInfo.plist" dictionary:[DataFilter DictionaryFilter:[wxLogDic valueForKey:@"data"]]]) {
            [[FixValues navigationViewController] popViewControllerAnimated:true];
        }else{
            [[AgentFunction theTopviewControler] presentViewController:[WarningWindow MsgWithoutTrans:@"登录信息保存失败"] animated:YES completion:nil];
            
        }
    }else if([[wxLogDic valueForKey:@"message"]isEqualToString:@"该账号绑定设备已达上限，请先用已绑定设备登录，解绑后再重新尝试。"]){
        [[AgentFunction theTopviewControler] presentViewController:[WarningWindow  MsgWithoutTrans:[wxLogDic valueForKey:@"message"]] animated:YES completion:nil];
    }else{
        [[AgentFunction theTopviewControler]
         presentViewController:[self forceLogin:[wxLogDic valueForKey:@"message"]
                                         Openid:[userMsg valueForKey:@"openid"]
                                           Type:@"other"
                                        UserMsg:userMsg] animated:YES completion:nil];
    }
}

//强制登录专用提示框
+(UIAlertController*)forceLogin:(NSString*)message Openid:(NSString*)openid Type:(NSString*)type UserMsg:(NSDictionary*)usermsg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"强制登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self userOccupation:openid Type:type Other_type:@"WEIXIN"];
        [self WXtoLogin:usermsg];
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [action2 setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alert addAction:action1];
    [alert addAction:action2];
    
    return alert;
}
//==================================

//第三方登录
+(NSDictionary*)OtherLogin:(NSString*)openid Nickname:(NSString*)nickname DeviceId:(NSString*)device_id DeviceName:(NSString*)device_name Type:(NSString*)type Pic:(NSString*)picurl{
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
    //NSLog(@"测试路径%@",url);
    NSDictionary* dataDic=[self postRequest:url];
    return dataDic;
}


#pragma mark --get\post\put方法
+(NSDictionary*)postRequest:(NSURL*)url{
    NSURLSession *session=[NSURLSession sharedSession];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    NSLog(@"post方法中url是：%@",url);
    request.HTTPMethod=@"POST";
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    static NSDictionary *dataDic;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        dataDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"数据是：%@",html);
        NSLog(@"错误是：%@",error);
        //NSLog(@"响应是：%@",response);
        [AgentFunction isTokenExpired:dataDic];
        
    }];
    
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
    return dataDic;
}

+(NSDictionary*)postRequestWithHead:(NSURL*)url Head:(NSString*)headMsg{
    NSURLSession *session=[NSURLSession sharedSession];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    NSLog(@"post方法的url是：%@",url);
    
    //添加请求头
    NSDictionary *headers = @{ @"English-user": headMsg};
    [request setAllHTTPHeaderFields:headers];
    
    request.HTTPMethod=@"POST";
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    static NSDictionary *dataDic;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        dataDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"数据是：%@",html);
        NSLog(@"错误是：%@",error);
        //NSLog(@"响应是：%@",response);
        [AgentFunction isTokenExpired:dataDic];
        
    }];
    
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
    return dataDic;
}

+(NSDictionary*)getRequest:(NSURL*)url{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session=[NSURLSession sharedSession];
    NSLog(@"request请求%@",request);
    static NSDictionary* dictionary;
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        //NSLog(@"网络响应：response：%@",response);
        // NSLog(@"返回数据：response：%@",data);
        NSLog(@"错误：response：%@",error);
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"数据为：%@",html);
        [AgentFunction isTokenExpired:dictionary];
    }];
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
    return dictionary;
}

+(NSDictionary*)getRequestWithHead:(NSString*)userkey Path:(NSURL*)url{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session=[NSURLSession sharedSession];
    NSLog(@"get方法中url是：%@",url);
    //添加请求头
    NSDictionary *headers = @{@"English-user": userkey};
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
                               
    static NSDictionary* dictionary;
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        //NSLog(@"网络响应：response：%@",response);
       // NSLog(@"返回数据：response：%@",data);
        NSLog(@"错误：%@",error);
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"数据为：%@",html);
        [AgentFunction isTokenExpired:dictionary];
//        if ([AgentFunction isTokenExpired:dictionary]) {
//            
//            dictionary=@{@"1":@"code"};
//        }
    }];
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
    return dictionary;
}

//避免线程冲突所设立的请求方式，专为多线程冲突时调用
+(NSDictionary*)threadGetRequestWithHead:(NSString*)userkey Path:(NSURL*)url{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session=[NSURLSession sharedSession];
    NSLog(@"get方法中url是：%@",url);
    //添加请求头
    NSDictionary *headers = @{@"English-user": userkey};
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    static NSDictionary* dictionary;
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        //NSLog(@"网络响应：response：%@",response);
        // NSLog(@"返回数据：response：%@",data);
        NSLog(@"错误：%@",error);
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"数据为：%@",html);
        [AgentFunction isTokenExpired:dictionary];
    }];
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
    return dictionary;
}
+(NSDictionary*)threadTwoGetRequestWithHead:(NSString*)userkey Path:(NSURL*)url{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session=[NSURLSession sharedSession];
    NSLog(@"get方法中url是：%@",url);
    //添加请求头
    NSDictionary *headers = @{@"English-user": userkey};
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    static NSDictionary* dictionary;
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        //NSLog(@"网络响应：response：%@",response);
        // NSLog(@"返回数据：response：%@",data);
        NSLog(@"错误：%@",error);
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"数据为：%@",html);
       [AgentFunction isTokenExpired:dictionary];
    }];
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
    return dictionary;
}


+(NSDictionary*)putRequestWithHead:(NSURL*)url Head:(NSString*)headMsg{
    NSURLSession *session=[NSURLSession sharedSession];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    NSLog(@"url是：%@",url);
    
    //添加请求头
    NSDictionary *headers = @{ @"English-user": headMsg};
    [request setHTTPMethod:@"PUT"];
    [request setAllHTTPHeaderFields:headers];
    
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    static NSDictionary *dataDic;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        dataDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"数据是：%@",html);
        NSLog(@"错误是：%@",error);
        //NSLog(@"响应是：%@",response);
        [AgentFunction isTokenExpired:dataDic];
    }];
    
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
    return dataDic;
}

+(NSDictionary*)deleteRequestWithHead:(NSURL*)url Head:(NSString*)headMsg{
    NSURLSession *session=[NSURLSession sharedSession];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    NSLog(@"url是：%@",url);
    
    //添加请求头
    NSDictionary *headers = @{ @"English-user": headMsg};
    [request setHTTPMethod:@"DELETE"];
    [request setAllHTTPHeaderFields:headers];
    
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    static NSDictionary *dataDic;
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        dataDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //这里改变RunLoop模式
        CFRunLoopStop(CFRunLoopGetMain());
        NSString *html = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"数据是：%@",html);
        NSLog(@"错误是：%@",error);
        //NSLog(@"响应是：%@",response);
        [AgentFunction isTokenExpired:dataDic];
    }];
    
    [dataTask resume];
    //这里恢复RunLoop
    CFRunLoopRun();
    return dataDic;
}


@end
