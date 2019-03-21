//
//  ConnectionFunction.h
//  EnglishDemo
//
//  Created by 马一轩 on 2018/10/31.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConnectionFunction : NSObject

//登录
+(NSDictionary*)getYzm:(long)phoneNumber;
+(NSDictionary*)verifyYzm:(long)phoneNumber yzm:(NSString*)yzm;
+(NSDictionary*)toRegister:(long)phone Pass:(NSString*)password Nick:(NSString*)nickname;
+(NSDictionary*)login_password:(long)phone Pass:(NSString*)password Name:(NSString*)deviceName Id:(NSString*)deviceId;
+(NSDictionary*)login_yzm:(long)phoneNumber yzm:(NSString*)yzm;

//第三方登录
+(NSDictionary*)OtherLogin:(NSString*)openid Nickname:(NSString*)nickname DeviceId:(NSString*)device_id DeviceName:(NSString*)device_name Type:(NSString*)type Pic:(NSString*)picurl;
//微信登录代理方法
+(void)WXLoginAgent:(NSString*)code;

+(NSDictionary*)resetPass:(long)phoneNumber Pass:(NSString*)password;
//用户书架接口
+(NSDictionary*)getBookShelf:(NSString*)userkey;
+(NSDictionary*)addBook:(NSString*)book_id BoughtState:(NSString*)state UserKey:(NSString*)userkey;
+(NSDictionary*)getLineByType:(NSString*)menuType UserKey:(NSString*)userkey;
//根据书本分类父Id查询分类信息(根据出版社查询年级)
+(NSDictionary*)getLineByParent:(NSString*)parent_id UserKey:(NSString*)userkey;
//获取选择完年级、出版社后筛选出的书籍信息 参数是四级分类的id（年级id）
+(NSDictionary*)getBookMsg:(NSString*)publictionId UserKey:(NSString*)userkey UserId:(NSString*)userId;
//书本单元信息
+(NSDictionary*)getUnitMsg:(NSString*)bookId UserKey:(NSString*)userkey;
//书本单元下的课信息
+(NSDictionary*)getClassMsg:(NSString*)unitId UserKey:(NSString*)userkey;
//每一课的教学信息
+(NSDictionary*)getLessonMsg:(NSString*)classId UserKey:(NSString*)userkey;

//学习进度信息
//获取用户课的购买状态
+(NSDictionary*)articleBuyState:(NSString*)bookId UserKey:(NSString*)userkey;

//增加句子学习信息记录
+(NSDictionary*)addSentenceMsg:(NSString*)sentenceId UserKey:(NSString*)userkey;
//查询单元学习进度
+(NSDictionary*)unitProcess:(NSString*)bookId UserKey:(NSString*)userkey;

// 添加用户图片学习进度信息
+(NSDictionary*)addUserPictureMsg:(NSString*)pictureId  UserKey:(NSString*)userkey;

//增加用户课学习信息并扣除学分
+(NSDictionary*)addUserArticleMsg:(NSString*)articleId  UserKey:(NSString*)userkey;

//修改用户信息
+(NSDictionary*)modifyUserMsg:(NSString*)nickname UserKey:(NSString*)userkey Phone:(NSString*)phone Password:(NSString*)password;

//直接获取最近学习信息
+(NSDictionary*)recentLearnMsg:(NSString*)userkey;
//根据书籍获取最近学习信息
+(NSDictionary*)recentLearnMsgByBook:(NSString*)userkey Id:(NSString*)bookId;

//用户书本学习信息
+(NSDictionary*)getBookLearnMsg:(NSString*)userkey Id:(NSString*)bookId;

// 添加错题信息
+(NSDictionary*)addWrongMsg:(NSString*)userkey Id:(NSString*)wrongId  Type:(NSString*)type;

// 获取错题信息
+(NSDictionary*)getWrongMsg:(NSString*)userkey Id:(NSString*)articleId;

//待测试

//获取用户句子学习信息记录
+(NSDictionary*)getUserSentenceMsg:(NSString*)sentenceId UserKey:(NSString*)userkey;

//获取用户图片学习进度信息
+(NSDictionary*)getUserPictureMsg:(NSString*)pictureId UserKey:(NSString*)userkey;

//单词信息查询
+(NSDictionary*)getTestWordMsg:(NSString*)articleId UserKey:(NSString*)userkey;

//句子信息查询
+(NSDictionary*)getTestSentenceMsg:(NSString*)articleId UserKey:(NSString*)userkey;


//用户在线状态，强制下线
+(NSDictionary*)userOccupation:(NSString*)openId Type:(NSString*)type Other_type:(NSString*)other_type;

//设备绑定信息
+(NSDictionary*)deviceBinding:(NSString*)userkey;

//设备解除绑定
+(NSDictionary*)deleteBinding:(NSString*)userkey DeviceId:(NSString*)deviceId;

//支付策略
+(NSDictionary*)getStrategies:(NSString*)userKey;

// 支付宝支付
+(NSDictionary*)Alipay:(NSString*)userkey Money:(NSString*)money  Strategy:(NSString*)strategy_id ;

//微信支付
+(NSDictionary*)WeChatpay:(NSString*)userkey Money:(NSString*)money  Strategy:(NSString*)strategy_id ;

//获取学分
+(NSDictionary*)getScore:(NSString*)userkey;

//订单查询
+(NSDictionary*)orderMsg:(NSString*)userkey;

#pragma mark --微信第三方登录接口
//微信获取access_token
+(NSDictionary*)getWXaccess:(NSString*)code;

//微信获取个人信息
+(NSDictionary*)getWXuserMsg:(NSString*)access_token Openid:(NSString*)openid;

// 用户意见反馈
+(NSDictionary*)feedback:(NSString*)userkey Opinion:(NSString*)opinion;


@end

NS_ASSUME_NONNULL_END
