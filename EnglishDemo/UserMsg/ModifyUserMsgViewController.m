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
#import "../DiyGroup/UnloginMsgView.h"
#import "../Common/HeadView.h"
#import "../WeChatSDK/WeChatSDK1.8.3/WXApi.h"

@interface ModifyUserMsgViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSDictionary* userInfo;
    UITextField* nicknameTextField;
    UITextField* phoneTextField;
    UIImageView* headPic;
    NSDictionary* binding;
    
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
        [self headPicView];
        [self detailMsg];
        [self defineBtn];
    }else{
        UnloginMsgView* unloginView=[[UnloginMsgView alloc]initWithFrame:CGRectMake(0, 88.27, 414, 647)];
        [self.view addSubview:unloginView];
    }
    
}
-(void)titleView{
    [self.view addSubview:[HeadView titleShow:@"个人信息" Color:ssRGBHex(0xFF7474) Located:CGRectMake(0, 22.06, 414, 66.2) UINavigationController:self.navigationController]];
}
-(void)headPicView{
    headPic=[[UIImageView alloc]initWithFrame:CGRectMake(152, 140, 110, 110)];
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
    headPic.layer.cornerRadius=headPic.frame.size.width / 2;
    //把多余部分去掉
    headPic.layer.masksToBounds = YES;
    [self.view addSubview:headPic];
    
    UIButton* pushHeadBtn=[[UIButton alloc]initWithFrame:CGRectMake(152, 140, 110, 110)];
    pushHeadBtn.layer.cornerRadius=pushHeadBtn.frame.size.width / 2;
    //把多余部分去掉
    pushHeadBtn.layer.masksToBounds = YES;
    [pushHeadBtn setTitle:@"点击上传" forState:UIControlStateNormal];
    UIImage* backImg=[BackgroundImageWithColor imageWithColor:[UIColor blackColor]];
    [pushHeadBtn setBackgroundImage:[BackgroundImageWithColor imageByApplyingAlpha:0.5 image:backImg] forState:UIControlStateNormal];
    [pushHeadBtn addTarget:self action:@selector(pushTheHeadPic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushHeadBtn];
}
-(void)pushTheHeadPic{
    
    [self warnMsg:@"此功能暂未开放"];
    return;

//    NSLog(@"上传头像");
//    //创建图片选取器对象
//    UIImagePickerController * pickerViwController = [[UIImagePickerController alloc] init];
//    /*
//     图片来源
//     UIImagePickerControllerSourceTypePhotoLibrary：表示显示所有的照片
//     UIImagePickerControllerSourceTypeCamera：表示从摄像头选取照片
//     UIImagePickerControllerSourceTypeSavedPhotosAlbum：表示仅仅从相册中选取照片。
//     */
//    pickerViwController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//
//    //允许用户编辑图片 (YES可以编辑，NO只能选择照片)
//    pickerViwController.allowsEditing = YES;
//
//    //设置代理
//    pickerViwController.delegate = self;
//
//    [self presentViewController:pickerViwController animated:YES completion:nil];
}
#pragma mark <2>相册协议中方法，选中某张图片后调用方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image= [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    // 如果是相机拍照的，保存在本地
//    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
//    {
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//    }
    
    //让界面的imageview中图片换成得到选中的图片
    headPic.image = image;
    
    //保存图片到Document目录下
    
    [DocuOperate saveImage:[LocalDataOperation imageWithImageSimple:image scaledToSize:CGSizeMake(50.0f, 50.0f)] WithName:@"picNeedToPush.jpg"];
    [self pushPic:[userInfo valueForKey:@"userKey"] FileUrl:[[DocuOperate documentsDirectory]stringByAppendingString:@"/picNeedToPush.jpg"]];

    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)pushPic:(NSString*)headMsg FileUrl:(NSString*)fileUrl
//PathUrl:(NSString*)pathurl
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
    UILabel* nicknameLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 300, 80, 49)];
    nicknameLabel.text=@"昵称：";
    nicknameLabel.font=[UIFont systemFontOfSize:14];
    nicknameLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:nicknameLabel];
    
    nicknameTextField=[[UITextField alloc]initWithFrame:CGRectMake(140, 300, 200, 49)];
    nicknameTextField.text=[userInfo valueForKey:@"nickname"];
    nicknameTextField.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:nicknameTextField];
    
    //中部横线
    UIView* lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 349, 414, 1)];
    lineView.layer.borderColor=ssRGBHex(0x979797).CGColor;
    lineView.layer.borderWidth=1;
    [self.view addSubview:lineView];
    
    UILabel* phoneLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 350, 80, 49)];
    phoneLabel.text=@"电话号码：";
    phoneLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:phoneLabel];
    
    phoneTextField=[[UITextField alloc]initWithFrame:CGRectMake(140, 350, 200, 49)];
    phoneTextField.font=[UIFont systemFontOfSize:14];
    phoneTextField.text=[userInfo valueForKey:@"phone"];;
    [self.view addSubview:phoneTextField];
    
    //中部横线
    UIView* lineView2=[[UIView alloc]initWithFrame:CGRectMake(0, 399, 414, 1)];
    lineView2.layer.borderColor=ssRGBHex(0x979797).CGColor;
    lineView2.layer.borderWidth=1;
    [self.view addSubview:lineView2];
    
    UILabel* wechatLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 400, 80, 49)];
    wechatLabel.text=@"微信绑定：";
    wechatLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:wechatLabel];
    
    UIButton* wechatBond=[[UIButton alloc]initWithFrame:CGRectMake(140, 400, 100, 49)];
    wechatBond.titleLabel.font=[UIFont systemFontOfSize:14];
    [wechatBond setTitle:@"未绑定" forState:UIControlStateNormal];
    [wechatBond setTitleColor:ssRGBHex(0x979797) forState:UIControlStateNormal];
    [self.view addSubview:wechatBond];
    
    //中部横线
    UIView* lineView3=[[UIView alloc]initWithFrame:CGRectMake(0, 449, 414, 1)];
    lineView3.layer.borderColor=ssRGBHex(0x979797).CGColor;
    lineView3.layer.borderWidth=1;
    [self.view addSubview:lineView3];
    
    UILabel* qqLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 450, 80, 49)];
    qqLabel.text=@"QQ绑定：";
    qqLabel.font=[UIFont systemFontOfSize:14];
    [self.view addSubview:qqLabel];
    
    UIButton* QQBond=[[UIButton alloc]initWithFrame:CGRectMake(140, 450, 100, 49)];
    [QQBond setTitle:@"未绑定" forState:UIControlStateNormal];
    QQBond.titleLabel.font=[UIFont systemFontOfSize:14];
    [QQBond setTitleColor:ssRGBHex(0x979797) forState:UIControlStateNormal];
    [self.view addSubview:QQBond];
    
    //中部横线
    UIView* lineView4=[[UIView alloc]initWithFrame:CGRectMake(0, 499, 414, 1)];
    lineView4.layer.borderColor=ssRGBHex(0x979797).CGColor;
    lineView4.layer.borderWidth=1;
    [self.view addSubview:lineView4];
    
    binding = [[ConnectionFunction getBindingMsg:[self->userInfo valueForKey:@"userKey"]]valueForKey:@"data"];
    if(binding != NULL){
        NSString* qq = [NSString stringWithFormat:@"%@",[binding valueForKey:@"qq"]];
        NSString* weixin = [NSString stringWithFormat:@"%@",[binding valueForKey:@"weixin"]];
        if (![qq isEqualToString:@"0"]) {
            [QQBond setTitle:@"已绑定" forState:UIControlStateNormal];
            [QQBond setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
        }
        if (![weixin isEqualToString:@"0"]) {
            [wechatBond setTitle:@"已绑定" forState:UIControlStateNormal];
            [wechatBond setTitleColor:ssRGBHex(0xFF7474) forState:UIControlStateNormal];
        }
    }

}
-(void)defineBtn{
    UIButton* toModify=[[UIButton alloc]initWithFrame:CGRectMake(20, 530, 374, 40)];
    [toModify setTitle:@"保存" forState:UIControlStateNormal];
    toModify.titleLabel.font=[UIFont systemFontOfSize:14];
    toModify.backgroundColor=ssRGBHex(0xFF7474);
    [toModify addTarget:self action:@selector(modifyUserMsg) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toModify];
}

-(void)modifyUserMsg{
    NSString* nickname=nicknameTextField.text;
    NSString* phone=phoneTextField.text;
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

-(void)WXlogin{
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"App";
        [WXApi sendReq:req];
        
    }else {
        NSLog(@"请安装微信");
        
    }
}

//点击背景收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES]; //实现该方法是需要注意view需要是继承UIControl而来的
}


@end
