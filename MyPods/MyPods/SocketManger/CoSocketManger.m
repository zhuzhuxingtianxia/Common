//
//  CoSocketManger.m
//  MyPods
//
//  Created by Jion on 2017/3/16.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "CoSocketManger.h"
#import <GCDAsyncSocket.h>

static  NSString * Khost = @"127.0.0.1";
static const uint16_t Kport = 6969;

@interface CoSocketManger()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *gcdSocket;
}
@end

@implementation CoSocketManger
+ (instancetype)share
{
    static dispatch_once_t onceToken;
    static CoSocketManger *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        [instance initSocket];
        [instance connect];
    });
    return instance;
}

- (void)initSocket
{
    gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    gcdSocket.userData = @"猪猪行天下";
}
#pragma mark - 对外的一些接口

//建立连接
- (BOOL)connect
{
    return  [gcdSocket connectToHost:Khost onPort:Kport error:nil];
}

//断开连接
- (void)disConnect
{
    [gcdSocket disconnect];
}


//发送消息
- (void)sendMsg:(NSString *)msg

{
    NSData *data  = [msg dataUsingEncoding:NSUTF8StringEncoding];
    /*
     这个方法的作用就是去读取当前消息队列中的未读消息。
     记住，这里不调用这个方法，消息回调的代理是永远不会被触发的
     而且必须是tag相同，如果tag不同，这个收到消息的代理也不会被触发
     */
    //第二个参数，请求超时时间
    [gcdSocket writeData:data withTimeout:-1 tag:110];
    
}

//监听最新的消息
- (void)pullTheMsg
{
    //监听读数据的代理  -1永远监听，不超时，但是只收一次消息，
    //所以每次接受到消息还得调用一次
    [gcdSocket readDataWithTimeout:-1 tag:110];
    
}
#pragma mark - GCDAsyncSocketDelegate
//连接成功调用
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接成功,host:%@,port:%d",host,port);
    
    [self pullTheMsg];
    
    //心跳写在这...
}

//断开连接的时候调用
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    NSLog(@"断开连接,host:%@,port:%d",sock.localHost,sock.localPort);
    //断线重连写在这...
    
}

//写成功的回调
- (void)socket:(GCDAsyncSocket*)sock didWriteDataWithTag:(long)tag
{
  
    NSLog(@"写的回调,tag:%ld ,userData:%@",tag,sock.userData);
}

//收到消息的回调
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到消息：%@",msg);
    
    [self pullTheMsg];
}
//分段去获取消息的回调,用于更新进度条
//- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
//{
//
//    NSLog(@"读的回调,length:%ld,tag:%ld",partialLength,tag);
//
//}

//为上一次设置的读取数据代理续时 (如果设置超时为-1，则永远不会调用到)
//-(NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
//{
//    NSLog(@"来延时，tag:%ld,elapsed:%f,length:%ld",tag,elapsed,length);
//    return 10;
//}

@end
