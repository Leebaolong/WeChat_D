//
//  WeChatViewController.m
//  WeChat_Djp
//
//  Created by tztddong on 16/7/8.
//  Copyright © 2016年 dongjiangpeng. All rights reserved.
//

#import "WeChatViewController.h"
#import "ChatDetailViewController.h"
#import "WeChatListModel.h"
#import "WeChatTableViewCell.h"

@interface WeChatViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
/**
 *  搜索栏
 */
@property(nonatomic,strong)UISearchBar *searchBar;
/**
 *  状态栏的底部
 */
@property(nonatomic,strong)UIView *topStatusView;
/**
 *  取消按钮
 */
@property(nonatomic,strong)UIButton *cancleBtn;
/**
 *  会话列表
 */
@property(nonatomic,strong)UITableView *weChatTableView;
/**
 *  搜索的view
 */
@property(nonatomic,strong)UIScrollView *searchView;
/**
 *  数据源
 */
@property(nonatomic,strong)NSMutableArray *dataArray;
/**
 *  未读消息的总数
 */
@property(nonatomic,assign)NSInteger unreadCount;
@end

@implementation WeChatViewController
{
    NSInteger searchBarTop;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [self getAllConversations];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
}

- (NSMutableArray *)dataArray{
    
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
       
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //登陆成功通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:LOGINCHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoLoginSuccess) name:AUTOLOGINSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkState:) name:NETWORKSTATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reciveMessage) name:RECEIVEMESSAGES object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addFriendNoti:) name:ADDFRIENDSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(delectFriendNoti) name:DELECTFRIENDSUEESS object:nil];
    
    searchBarTop = KNAVHEIGHT;
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.placeholder = @"搜索";
    searchBar.delegate = self;
    searchBar.layer.cornerRadius = 5;
    searchBar.layer.masksToBounds = YES;
    [self.view addSubview:searchBar];
    self.searchBar = searchBar;
    
    self.topStatusView = [[UIView alloc]init];
    self.topStatusView.backgroundColor = [UIColor colorWithRed:54/255.0 green:53/255.0 blue:58/255.0 alpha:1];
    [self.view addSubview:self.topStatusView];
    [self.topStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
        make.height.equalTo(@20);
    }];
    
    self.cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancleBtn.titleLabel setFont:FONTSIZE(15)];
    [self.cancleBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.cancleBtn addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancleBtn];
    [self.cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.right.equalTo(self.topStatusView.mas_right);
        make.height.equalTo(@44);
        make.width.equalTo(@44);
    }];
    
    self.weChatTableView = [[UITableView alloc]init];
    self.weChatTableView.delegate = self;
    self.weChatTableView.dataSource = self;
    [self.weChatTableView registerNib:[UINib nibWithNibName:@"WeChatTableViewCell" bundle:nil] forCellReuseIdentifier:@"weChatTableView"];
    self.weChatTableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.weChatTableView];
    
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.pagingEnabled = NO;
    [self.view addSubview:scrollView];
    self.searchView = scrollView;
    
    [self isHidden:YES];
    
    //告诉某个view需要更新约束
    [self.view setNeedsUpdateConstraints];
    //检测这个view是否有约束需要更新 如果有在调用下面的方法 更新约束
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];

}

- (void)updateViewConstraints{
    
    [self.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.top.offset(searchBarTop);
        make.height.equalTo(@44);
        if (searchBarTop == 20) {
            make.right.offset(-44);
        }else{
            make.right.offset(0);
        }
    }];
    
    [self.weChatTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.top.equalTo(self.searchBar.mas_bottom);
        make.bottom.offset(-KTABBARHEIGHT);
    }];
    
    [self.searchView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.weChatTableView);
        make.bottom.equalTo(self.weChatTableView.mas_bottom).with.offset(KMARGIN);
    }];
    
    [super updateViewConstraints];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (searchBarTop == 20) {
        return UIStatusBarStyleDefault;
    }
    return UIStatusBarStyleLightContent;
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    searchBarTop = 20;
    //告诉某个view需要更新约束
    [self.view setNeedsUpdateConstraints];
    //检测这个view是否有约束需要更新 如果有在调用下面的方法 更新约束
    [self.view updateConstraintsIfNeeded];
    [self isHidden:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
//        [self setNeedsStatusBarAppearanceUpdate];
    }];
    
    return YES;
}                     // return NO to not become first responder
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
}                     // called when text starts editing
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}                        // return NO to not resign first responder
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
}                       // called when text ends editing
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
}   // called when text changes (including clear)
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}// NS_AVAILABLE_IOS(3_0); // called before text changes

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
}                     // called when keyboard search button pressed


//点击取消按钮
- (void)clickCancelBtn{
    searchBarTop = KNAVHEIGHT;
    [self.searchBar resignFirstResponder];
    //告诉某个view需要更新约束
    [self.view setNeedsUpdateConstraints];
    //检测这个view是否有约束需要更新 如果有在调用下面的方法 更新约束
    [self.view updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        [self isHidden:YES];
    }];

}

- (void)isHidden:(BOOL)hidden{
    
    self.cancleBtn.hidden = hidden;
    self.topStatusView.hidden = hidden;
    self.navigationController.navigationBar.hidden = !hidden;
    self.weChatTableView.hidden = !hidden;
    self.searchView.hidden = hidden;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WeChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"weChatTableView"];
    EMConversation *conversation = [self.dataArray objectAtIndex:indexPath.row];
    WeChatListModel *model = [[WeChatListModel alloc]init];
    model.conversation = conversation;
    cell.model = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatDetailViewController *chatVC = [[ChatDetailViewController alloc]init];
    EMConversation *conversation = [self.dataArray objectAtIndex:indexPath.row];
    chatVC.title = conversation.conversationId;
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [SVProgressHUD show];
    EMConversation *conversation = [self.dataArray objectAtIndex:indexPath.row];
    if ([[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId deleteMessages:NO]){
        [SVProgressHUD showSuccessWithStatus:@"删除成功"];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self.weChatTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else{
        [SVProgressHUD showSuccessWithStatus:@"删除失败"];
    };
    
}
#pragma mark titleForDeleteConfirmationButtonForRowAtIndexPath
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}


#pragma mark 登录成功通知
- (void)loginSuccess{
    
    [self getAllConversations];
}
#pragma mark 自动登录成功通知
- (void)autoLoginSuccess{
    
    [self getAllConversations];
}
#pragma mark 网络状态的变化
- (void)netWorkState:(NSNotification *)notification{
    
    NSDictionary *dict = notification.userInfo;
    if ([[dict objectForKey:@"isConnect"] intValue]) {
        self.navigationItem.title = @"微信";
    }else{
        self.navigationItem.title = @"微信(未连接)";
    }
}
#pragma mark  接收到新消息
- (void)reciveMessage{
    
    [self getAllConversations];
}

#pragma mark 添加好友成功 A加B A收到的代理发通知
- (void)addFriendNoti:(NSNotification *)notification{
    NSString *userName = [notification.userInfo objectForKey:@"name"];
    [[EMClient sharedClient].chatManager getConversation:userName type:EMConversationTypeChat createIfNotExist:YES];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"我们已经是好友了,一起来聊天吧"];
    NSString *currentName = [[EMClient sharedClient] currentUsername];
    //生成Message
    EMMessage *emmessage = [[EMMessage alloc]initWithConversationID:userName from:currentName to:userName body:body ext:nil];
    emmessage.chatType = EMChatTypeChat;
    [[EMClient sharedClient].chatManager asyncSendMessage:emmessage progress:^(int progress) {
        
    } completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            [self getAllConversations];
        }
    }];

}
#pragma mark 删除好友刷新页面
- (void)delectFriendNoti{
    
    [self getAllConversations];
}
#pragma mark 获取会话列表
- (void)getAllConversations{
    
    [self.dataArray removeAllObjects];
    NSArray *convers = [[EMClient sharedClient].chatManager getAllConversations];
    [self.dataArray addObjectsFromArray:convers];
    NSInteger unreadCount = 0;//取出各个会话的未读消息数
    NSInteger unreadAllCount = 0;//全部会话的未读消息数
    for (EMConversation *conversation in convers) {
        unreadCount = conversation.unreadMessagesCount;
        unreadAllCount += unreadCount;
    }
    if (unreadAllCount) {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd",unreadAllCount];
        if (unreadAllCount > 10) {
            self.tabBarItem.badgeValue = @"99+";
        }
    }else{
        self.tabBarItem.badgeValue = nil;
    }
    [self.weChatTableView reloadData];

}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGINCHANGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AUTOLOGINSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NETWORKSTATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVEMESSAGES object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ADDFRIENDSUCCESS object:nil];
}
@end
