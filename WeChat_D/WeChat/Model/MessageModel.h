//
//  MessageModel.h
//  WeChat_D
//
//  Created by tztddong on 16/7/18.
//  Copyright © 2016年 dongjiangpeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ReturnBigImageBlock)(UIImage *bigImage);

typedef enum : NSUInteger {
    MessageType_Text,
    MessageType_Voice,
    MessageType_Picture,
    MessageType_Video,
} MessageType;

typedef enum : NSUInteger {
    MessageSendNone,
    MessageSendSuccess,
    MessageSendField,
} MessageSendStale;

@class EMMessage;
@interface MessageModel : NSObject
/**
 *  文字
 */
@property(nonatomic,copy)NSString *messagetext;
/**
 *  缩略图的服务器路径
 */
@property(nonatomic,copy)NSString *imageUrl;
/**
 *  缩略图的本地路径
 */
@property(nonatomic,copy)NSString *image_mark;
/**
 *  大图的路径
 */
@property(nonatomic,copy)NSString *bigImage_Url;
/** 缩略图的尺寸 */
@property(nonatomic,assign) CGSize thumbnailSize;
@property(nonatomic,strong) UIImage *friendImage;
/** 语音是否已读 */
@property(nonatomic,assign) BOOL voiceIsListen;
/**
 *  录音时间
 */
@property(nonatomic,assign)int voiceTime;
/**
 *  voice网络路径
 */
@property(nonatomic,copy)NSString *voicePath;
/**
 *  voice本地路径
 */
@property(nonatomic,copy)NSString *voiceLocaPath;
/**
 *  video时间
 */
@property(nonatomic,assign)int videoTime;
/**
 *  video网络路径
 */
@property(nonatomic,copy)NSString *videoPath;
/**
 *  video本地路径
 */
@property(nonatomic,copy)NSString *videoLocaPath;
/**
 *  是否本人发送
 */
@property(nonatomic,assign)BOOL isMineMessage;
/**
 *  消息体类型
 */
@property(nonatomic,assign)MessageType messageType;

/** Emmessage */
@property(nonatomic,strong)EMMessage *emmessage;
/** body */
@property(nonatomic,strong)EMMessageBody *messageBody;
/** 消息ID */
@property(nonatomic,copy)NSString *messageId;
/**
 *  发送状态
 */
@property(nonatomic,assign) EMMessageStatus sendSuccess;
/**
 *  消息类型
 */
@property(nonatomic,assign)EMChatType chatType;
/**
 *  消息发送者名字
 */
@property(nonatomic,copy)NSString *messageFromName;
/**
 *  头像URL
 */
@property(nonatomic,copy)NSString *headerImageUrl;
/**
 *  展位图(头像图片)
 */
- (UIImage *)placeholderHeaderImage;
/**
 *  展位图(消息图片)
 */
- (UIImage *)placeholderImage;
/**
 *  获取大图
 */
- (void)getBigImageWithBlock:(ReturnBigImageBlock)returnBigImageBlock;
@end
