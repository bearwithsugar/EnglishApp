//
//  ModifyUserMsgViewController.m
//  EnglishDemo
//
//  Created by 马一轩 on 2018/11/25.
//  Copyright © 2018 马一轩. All rights reserved.
//

#import "ModifyUserMsgViewController.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/ConnectionFunction.h"
#import "../Functions/DataFilter.h"
#import "../Functions/LocalDataOperation.h"
#import "../Functions/BackgroundImageWithColor.h"
#import "../Functions/DocuOperate.h"
#import "../Functions/QQLogin.h"
#import "../Functions/MyThreadPool.h"
#import "../Functions/WechatLog.h"
#import "../DiyGroup/UnloginMsgView.h"
#import "SVProgressHUD.h"
#import "../Common/HeadView.h"
#import "../WeChatSDK/WeChatSDK1.8.3/WXApi.h"
#import "Masonry.h"
#import "../Functions/WarningWindow.h"

@interface ModifyUserMsgViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSDictionary* userInfo;
    UITextField* nicknameTextField;
    UITextField* phoneTextField;
    UIImageView* headPic;
    UIView* surfaceView;
    NSDictionary* binding;
    UIButton* wechatBinding;
    UIButton* QQBinding;
}

@end

@implementation ModifyUserMsgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self titleView];
}

-(void)viewWillAppear:(BOOL)animated{
    if ([DocuOperate fileExistInPath:@"userInfo.plist"]) {
        userInfo=[DocuOperate readFromPlist:@"userInfo.plist"];
        [surfaceView removeFromSuperview];
        surfaceView = [UIView new];
        [self.view addSubview:surfaceView];
        [surfaceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(75);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        [self headPicView];
        [self detailMsg];
        [self defineBtn];
        [self loadData];
    }else{
        UnloginMsgView* unloginView=[[UnloginMsgView alloc]init];
        [self.view addSubview:unloginView];
        [unloginView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.top.equalTo(self.view).with.offset(88.27);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
    
}
-(void)titleView{
    [HeadView titleShow:@"个人信息" Color:ssRGBHex(0xFF7474) UIView:self.view UINavigationController:self.navigationController];
}
-(void)headPicView{
    
    headPic=[[UIImageView alloc]init];
    headPic.image=[UIImage imageNamed:@"icon_head"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage* headpic=[LocalDataOperation getImage:[self->userInfo valueForKey:@"userKey"]
                                              httpUrl:[self->userInfo valueForKey:@"pictureUrl"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (headpic==nil) {
            }else{
                self->headPic.image=headpic;
            }
        });
    });
    headPic.layer.cornerRadius=55;
    //把多余部分去掉
    headPic.layer.masksToBounds = YES;
    [surfaceView addSubview:headPic];
    
    [headPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->surfaceView).with.offset(90);
        make.height.equalTo(@110);
        make.width.equalTo(@110);
        make.centerX.equalTo(self->surfaceView);
    }];
    
//    UIButton* pushHeadBtn=[[UIButton alloc]init];
//    pushHeadBtn.layer.cornerRadius=55;
//    //把多余部分去掉
//    pushHeadBtn.layer.masksToBounds = YES;
//    [pushHeadBtn setTitle:@"点击上传" forState:UIControlStateNormal];
//    UIImage* backImg=[BackgroundImageWithColor imageWithColor:[UIColor blackColor]];
//    [pushHeadBtn setBackgroundImage:[BackgroundImageWithColor imageByApplyingAlpha:0.5 image:backImg] forState:UIControlStateNormal];
//    [pushHeadBtn addTarget:self action:@selector(pushTheHeadPic) forControlEvents:UIControlEventTouchUpInside];
//    [surfaceView addSubview:pushHeadBtn];
//    
//    [pushHeadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self->surfaceView).with.offset(90);
//        make.height.equalTo(@110);
//        make.width.equalTo(@110);
//        make.centerX.equalTo(self->surfaceView.mas_centerX);
//    }];
}
//-(void)pushTheHeadPic{
//
//    [self warnMsg:@"此功能暂未开放"];
//    return;
//}
#pragma mark <2>相册协议中方法，选中某张图片后调用方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image= [info objectForKey:@"UIImagePickerControllerOriginalImage"];

    //让界面的imageview中图片换成得到选中的图片
    headPic.image = image;
    
    //保存图片到Document目录下
    
    [DocuOperate saveImage:[LocalDataOperation imageWithImageSimple:image scaledToSize:CGSizeMake(50.0f, 50.0f)] WithName:@"picNeedToPush.jpg"];
    [self pushPic:[userInfo valueForKey:@"userKey"] FileUrl:[[DocuOperate documentsDirectory]stringByAppendingString:@"/picNeedToPush.jpg"]];

    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)pushPic:(NSString*)headMsg FileUrl:(NSString*)fileUrl
{
    NSDictionary *headers = @{ @"content-type": @"multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW",
                               @"English-user": headMsg,
                               @"cache-control": @"no-cache",
                               @"Postman-Token": @"420f0a09-d82f-46fa-aa37-db36654d1286"
                               };
    NSArray *parameters = @[ @{ @"name": @"picture", @"fileName": fileUrl } ];
    NSString *boundary = @"----WebKitFormBoundary7MA4YWxkTrZu0gW";
    
    NSError *error;
    NSMutableString *body = [NSMutableString string];
    for (NSDictionary *param in parameters) {
        [body appendFormat:@"--%@\r\n", boundary];
        if (param[@"fileName"]) {
            [body appendFormat:@"Content-Disposition:form-data; name=\"%@\"; filename=\"%@\"\r\n", param[@"name"], param[@"fileName"]];
            [body appendFormat:@"%@",[NSString stringWithContentsOfFile:param[@"fileName"] encoding:NSUTF8StringEncoding error:&error]];
            if (error) {
                NSLog(@"body的内容是%@",body);
                NSLog(@"转换信息时报错%@", error);
            }
        } else {
            [body appendFormat:@"Content-Disposition:form-data; name=\"%@\"\r\n\r\n", param[@"name"]];
            [body appendFormat:@"%@", param[@"value"]];
        }
    }
    [body appendFormat:@"\r\n--%@--\r\n", boundary];
    NSData *postData = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.suuben.com/english/api/account/picture"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"PUT"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"上传图片的错误%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"图片上传响应%@", httpResponse);
                                                    }
                                                }];
    [dataTask resume];
}


-(void)detailMsg{
    UILabel* nicknameLabel=[[UILabel alloc]init];
    nicknameLabel.text=@"昵称：";
    nicknameLabel.font=[UIFont systemFontOfSize:14];
    nicknameLabel.textAlignment=NSTextAlignmentCenter;
    [surfaceView addSubview:nicknameLabel];
    
    [nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->surfaceView).with.offset(250);
        make.height.equalTo(@49);
        make.width.equalTo(@80);
        make.left.equalTo(self->surfaceView).offset(50);
    }];
    
    nicknameTextField=[[UITextField alloc]initWithFrame:CGRectMake(140, 250, 200, 49)];
    nicknameTextField.text=[userInfo valueForKey:@"nickname"];
    nicknameTextField.font=[UIFont systemFontOfSize:14];
    [surfaceView addSubview:nicknameTextField];
    
    //中部横线
    UIView* lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 299, 414, 1)];
    lineView.layer.borderColor=ssRGBHex(0x979797).CGColor;
    lineView.layer.borderWidth=1;
    [surfaceView addSubview:lineView];
    
    UILabel* phoneLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 300, 80, 49)];
    phoneLabel.text=@"电话号码：";
    phoneLabel.font=[UIFont systemFontOfSize:14];
    [surfaceView addSubview:phoneLabel];
    
    phoneTextField=[[UITextField alloc]initWithFrame:CGRectMake(140, 300, 200, 49)];
    phoneTextField.font=[UIFont systemFontOfSize:14];
    phoneTextField.text=[userInfo valueForKey:@"phone"];;
    [surfaceView addSubview:phoneTextField];
    
    //中部横线
    UIView* lineView2=[[UIView alloc]initWithFrame:CGRectMake(0, 349, 414, 1)];
    lineView2.layer.borderColor=ssRGBHex(0x979797).CGColor;
    lineView2.layer.borderWidth=1;
    [surfaceView addSubview:lineView2];
    
    UILabel* wechatLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 350, 80, 49)];
    wechatLabel.text=@"微信绑定：";
    wechatLabel.font=[UIFont systemFontOfSize:14];
    [surfaceView addSubview:wechatLabel];
    
    wechatBinding=[[UIButton alloc]initWithFrame:CGRectMake(140, 350, 100, 49)];
    [wechatBinding removeFromSuperview];
    wechatBinding.titleLabel.font=[UIFont systemFontOfSize:14];
    [wechatBinding setTitle:@"未绑定" forState:UIControlStateNormal];
    [wechatBinding setTitleColor:ssRGBHex(0x979797) forState:UIControlStateNormal];
    [wechatBinding addTarget:self action:@selector(WXBinding) forControlEvents:UIControlEventTouchUpInside];
    [surfaceView addSubview:wechatBinding];
    
    //中部横线
    UIView* lineView3=[[UIView alloc]initWithFrame:CGRectMake(0, 399, 414, 1)];
    lineView3.layer.borderColor=ssRGBHex(0x979797).CGColor;
    lineView3.layer.borderWidth=1;
    [surfaceView addSubview:lineView3];
    
    UILabel* qqLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 400, 80, 49)];
    qqLabel.text=@"QQ绑定：";
    qqLabel.font=[UIFont systemFontOfSize:14];
    [surfaceView addSubview:qqLabel];
    
    QQBinding=[[UIButton alloc]initWithFrame:CGRectMake(140, 400, 100, 49)];
    [QQBinding removeFromSuperview];
    [QQBinding setTitle:@"未绑定" forState:UIControlStateNormal];
    [QQBinding addTarget:self action:@selector(QQBinding) forControlEvents:UIControlEventTouchUpInside];
    QQBinding.titleLabel.font=[UIFont systemFontOfSize:14];
    [QQBinding setTitleColor:ssRGBHex(0x979797) forState:UIControlStateNormal];
    [surfaceView addSubview:QQBinding];
    
    //中部横线
    UIView* lineView4=[[UIView alloc]initWithFrame:CGRectMake(0, 449, 414, 1)];
    lineView4.layer.borderColor=ssRGBHex(0x979797).CGColor;
    lineView4.layer.borderWidth=1;
    [surfaceView addSubview:lineView4];
}
-(void)loadData{
    ConBlock jobBlock = ^(NSDictionary* resultDic){
        self->binding = [resultDic valueForKey:@"data"];
        if(self->binding != NULL){
            NSString* qq = [NSString stringWithFormat:@"%@",[self->binding valueForKey:@"qq"]];
            NSString* weixin = [NSString stringWithFormat:@"%@",[self->binding valueForKey:@"weixin"]];
            if (![qq isEqualToString:@"0"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->QQBinding setTitle:@"已绑定" forState:UIControlStateNormal];
                    [self->QQBinding setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
                });
            }
            if (![weixin isEqualToString:@"0"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->wechatBinding setTitle:@"已绑定" forState:UIControlStateNormal];
                    [self->wechatBinding setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
                });
            }
        }
    };
    [ConnectionFunction getBindingMsg:[self->userInfo valueForKey:@"userKey"] Block:jobBlock];
}
-(void)defineBtn{
    UIButton* toModify=[[UIButton alloc]init];
    [toModify setTitle:@"保存" forState:UIControlStateNormal];
    toModify.titleLabel.font=[UIFont systemFontOfSize:14];
    toModify.backgroundColor=ssRGBHex(0xFF7474);
    [toModify addTarget:self action:@selector(modifyUserMsg) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toModify];
    
    [toModify mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view).offset(-20);
        
    }];
}

-(void)modifyUserMsg{
    NSString* nickname=nicknameTextField.text;
    NSString* phone=phoneTextField.text;
    NSLog(@"userInfo%@",userInfo);
    if([[userInfo valueForKey:@"password"]isEqualToString:@""]){
        [self presentViewController:[WarningWindow MsgWithoutTrans:@"第三方账号无法修改个人信息！"]
                           animated:YES
                         completion:nil];
        return;
    }
    NSDictionary* dataDic=[ConnectionFunction modifyUserMsg:nickname UserKey:[userInfo valueForKey:@"userKey"] Phone:phone Password:[userInfo valueForKey:@"password"]];
    NSLog(@"修改用户信息返回的数据%@",dataDic);
    //删除用户信息文件
    if ([DocuOperate deletePlist:@"userInfo.plist"]&&
        [DocuOperate writeIntoPlist:@"userInfo.plist" dictionary:[DataFilter DictionaryFilter:[dataDic valueForKey:@"data"]]]) {
        [self popBack];
    }else{
        [self warnMsg:@"修改失败，请稍后再试。"];
    }
    
}
-(void)warnMsg:(NSString*)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示信息" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)popBack{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)WXBinding{
    VoidBlock myBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
            [self->wechatBinding setTitle:@"已绑定" forState:UIControlStateNormal];
            [self->wechatBinding setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
        });
    };
    if ([WXApi isWXAppInstalled]) {
        WechatLog* wechat = [WechatLog getInstance];
        wechat.myBlock = myBlock;
        wechat.type = @"FORBINDING";
        wechat.userKey = [userInfo valueForKey:@"userKey"];
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"App";
        [WXApi sendReq:req];
    }else {
        NSLog(@"请安装微信");
    }
}

-(void)QQBinding{
    VoidBlock myBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
            [self->QQBinding setTitle:@"已绑定" forState:UIControlStateNormal];
            [self->QQBinding setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
        });
    };
    if ([WXApi isWXAppInstalled]) {
        QQLogin* qqlog = [QQLogin getInstance];
        qqlog.myBlock = myBlock;
        qqlog.type = @"FORBINDING";
        qqlog.userKey = [userInfo valueForKey:@"userKey"];
        [qqlog toQQlogin];
    }else {
        NSLog(@"请安装微信");
    }
}
//点击背景收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES]; //实现该方法是需要注意view需要是继承UIControl而来的
}


@end
