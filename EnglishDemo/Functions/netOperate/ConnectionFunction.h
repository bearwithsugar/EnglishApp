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

typedef void (^VoidBlock) (void);

typedef void (^ConBlock) (NSDictionary*);

+(ConnectionFunction *) getInstance;

#pragma mark --用户管理接口
//获取修改密码的验证码
-(NSURL*)getYzmForPassword_Post:(long)phoneNumber;

//获取验证码用于登录
-(NSURL*)getYzmForReg_Post:(long)phoneNumber;

//验证验证码是否正确 接口通过
-(NSURL*)verifyYzm_Post:(long)phoneNumber yzm:(NSString*)yzm;

//注册接口 接口通过
-(NSURL*)toRegister_Post:(long)phone Pass:(NSString*)password Nick:(NSString*)nickname;

//账号密码登录接口 接口通过
-(NSURL*)login_password_Post:(long)phone Pass:(NSString*)password Name:(NSString*)deviceName Id:(NSString*)deviceId;

//验证码登录接口
-(NSURL*)login_yzm_Post:(long)phoneNumber Yzm:(NSString*)yzm Device:(NSString*)device_id Name:(NSString*)device_name ;

//用户在线状态，强制下线
-(NSURL*)userOccupation_Post:(NSString*)openId Type:(NSString*)type Other_type:(NSString*)other_type;
//修改密码接口
-(NSURL*)resetPass_Post:(long)phoneNumber Pass:(NSString*)password;

#pragma mark --书架接口
//用户书架接口
-(NSURL*)getBookShelf_Get_H;

//添加书架接口
-(NSURL*)addBook_Post_H:(NSString*)book_id BoughtState:(NSString*)state;

#pragma mark --书本信息接口
//获取选取书籍的出版社列表(根据书本分类type查询分类信息) 参数是分类的级别
-(NSURL*)getLineByType_Get_H:(NSString*)menuType;

//获取选择完年级、出版社后筛选出的书籍信息 参数是四级分类的id（年级id）
-(NSURL*)getBookMsg_Get_H:(NSString*)publictionId UserId:(NSString*)userId;

//根据书本分类父Id查询分类信息(根据出版社获取年级列表) 参数是父级分类的id
-(NSURL*)getLineByParent_Get_H:(NSString*)parent_id;

//书本单元信息
-(NSURL*)getUnitMsg_Get_H:(NSString*)bookId;

//书本单元下的课信息
-(NSURL*)getClassMsg_Get_H:(NSString*)unitId;

//每一课的教学信息
-(NSURL*)getLessonMsg_Get_H:(NSString*)classId;

#pragma mark --学习进度信息接口
//增加句子学习信息记录
-(NSURL*)addSentenceMsg_Post_H:(NSString*)sentenceId;

//查询单元学习进度
-(NSURL*)unitProcess_Get_H:(NSString*)bookId;

//增加用户课学习信息并扣除学分   这个接口路径不需要引号
-(NSURL*)addUserArticleMsg_Post_H:(NSString*)articleId;

// 添加用户图片学习进度信息   这个接口路径不需要引号
-(NSURL*)addUserPictureMsg_Post_H:(NSString*)pictureId;

//获取用户课的购买状态
-(NSURL*)articleBuyState_Get_H:(NSString*)bookId ;

#pragma mark --用户信息模块
//修改用户信息
-(NSURL*)modifyUserMsg_Put_H:(NSString*)nickname Phone:(NSString*)phone Password:(NSString*)password;

//获取学分
-(NSURL*)getScore_Get_H;

//充值学分
-(NSURL*)increaseScore_Post_H:(NSString*)money StrategyId:(NSString*)strategyId;

//获取用户第三方绑定信息
-(NSURL*)getBindingMsg_Get_H;

#pragma mark --测试模块
//句子信息查询
-(NSURL*)getTestSentenceMsg_Get_H:(NSString*)articleId;

// 添加错题信息
-(NSURL*)addWrongMsg_Post_H:(NSString*)wrongId  Type:(NSString*)type;

// 删除错题
-(NSURL*)deleteWrongMsg_Delete_H:(NSString*)content_id;

// 获取错题信息
-(NSURL*)getWrongMsg_Get_H:(NSString*)articleId;

// 使用block获取错题信息
-(NSURL*)getWrongMsgWithBlock_Get_H:(NSString*)articleId;

#pragma mark --版本信息
//版本信息
-(NSURL*)getVersionMsg_Get_H;

#pragma mark --最近学习信息
//直接获取最近学习信息
-(NSURL*)recentLearnMsg_Get_H;

//用户书本学习信息
-(NSURL*)getBookLearnMsg_Get_H:(NSString*)bookId;

//修改句子学习信息记录
-(NSURL*)fixSentenceMsg_Get_H:(NSString*)sentenceId Grade:(NSString*)grade;

//获取用户句子学习信息记录   但是传参传课本id
-(NSURL*)getUserSentenceMsg_Get_H:(NSString*)articleId;

//获取用户图片学习进度信息
-(NSURL*)getUserPictureMsg_Get_H:(NSString*)pictureId;

//获取用户学习时长信息
-(NSURL*)getLearningTime_Put_H:(NSString*)bookId Time:(NSString*)learningTime;

//单词信息查询
-(NSURL*)getTestWordMsg_Get_H:(NSString*)articleId;

#pragma mark --订单模块
//订单查询
-(NSURL*)searchOrders_Get_H;

//根据书籍获取最近学习信息
-(NSURL*)recentLearnMsgByBook_Get_H:(NSString*)bookId;

#pragma mark --用户意见
// 用户意见反馈
-(NSURL*)feedback_Post_H:(NSString*)opinion;

#pragma mark --设备信息
//设备绑定信息
-(NSURL*)deviceBinding_Get_H;

//设备解除绑定
-(NSURL*)deleteBinding_Delete_H:(NSString*)deviceId;

#pragma mark --支付
//支付策略
-(NSURL*)getStrategies_Get_H;

//订单查询
-(NSURL*)orderMsg_Get_H;

#pragma mark --微信第三方登录接口
//微信获取access_token
-(NSURL*)getWXaccess_Get:(NSString*)code;

//微信获取个人信息
-(NSURL*)getWXuserMsg_Get:(NSString*)access_token Openid:(NSString*)openid;

//第三方登录
-(NSURL*)OtherLogin_Post:(NSString*)openid Nickname:(NSString*)nickname DeviceId:(NSString*)device_id DeviceName:(NSString*)device_name Type:(NSString*)type Pic:(NSString*)picurl;

//绑定
-(NSURL*)toBinding_Post_H:(NSString*)openId Type:(NSString*)type Picurl:(NSString*)picurl;

@end

NS_ASSUME_NONNULL_END
