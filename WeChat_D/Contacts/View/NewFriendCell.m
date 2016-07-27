//
//  NewFriendCell.m
//  WeChat_D
//
//  Created by tztddong on 16/7/22.
//  Copyright © 2016年 dongjiangpeng. All rights reserved.
//

#import "NewFriendCell.h"

@interface NewFriendCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headimage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *jujueBtn;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UILabel *haveAgreeLabel;

@end

@implementation NewFriendCell

- (void)setDict:(NSMutableDictionary *)dict{
    
    _dict = dict;
    self.headimage.backgroundColor = [UIColor purpleColor];
    self.nameLabel.text = [dict objectForKey:NewFriendName];
    self.messageLabel.text = [dict objectForKey:NewFriendMessage];
    if ([[dict objectForKey:NewFriendAgreeState]integerValue]) {
        self.haveAgreeLabel.hidden = NO;
        self.jujueBtn.hidden = YES;
        self.agreeBtn.hidden = YES;
    }
}
//点击拒绝
- (IBAction)jujueBtn:(id)sender {
    [SVProgressHUD show];
    [[EMClient sharedClient].contactManager asyncDeclineInvitationForUsername:self.nameLabel.text success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"已拒绝"];
            NSMutableArray *arr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:NewFriendLocationArray]];
            [arr removeObject:self.dict];
            self.haveAgreeLabel.hidden = NO;
            self.jujueBtn.hidden = YES;
            self.agreeBtn.hidden = YES;
            self.haveAgreeLabel.text = @"已拒绝";
            [self.dict setObject:@2 forKey:NewFriendAgreeState];
            [arr addObject:self.dict];
            [[NSUserDefaults standardUserDefaults]setObject:arr forKey:NewFriendLocationArray];
            [JP_NotificationCenter postNotificationName:NEWFRIENDREQUESTRESULT object:nil];
        });
        
    } failure:^(EMError *aError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"拒绝失败"];
        });
        
    }];

}
//点击接受
- (IBAction)agreeBtn:(id)sender {
    //添加好友
    [SVProgressHUD show];
    [[EMClient sharedClient].contactManager asyncAcceptInvitationForUsername:self.nameLabel.text success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"已添加"];
            NSMutableArray *arr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:NewFriendLocationArray]];
            //移除当前的已处理的数据
            [arr removeObject:self.dict];
            self.haveAgreeLabel.hidden = NO;
            self.jujueBtn.hidden = YES;
            self.agreeBtn.hidden = YES;
            self.haveAgreeLabel.text = @"已添加";
            //给当前的数据处理状态 根据自己的处理赋值 在重新加载到本地数据组中
            [self.dict setObject:@1 forKey:NewFriendAgreeState];
            [arr addObject:self.dict];
            [[NSUserDefaults standardUserDefaults]setObject:arr forKey:NewFriendLocationArray];
            [JP_NotificationCenter postNotificationName:NEWFRIENDREQUESTRESULT object:nil];
        });
        
    } failure:^(EMError *aError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"添加失败"];
        });
        
    }];

}

@end
