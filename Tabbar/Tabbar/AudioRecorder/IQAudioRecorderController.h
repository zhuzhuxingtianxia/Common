//
//  IQAudioRecorderController.h
// https://github.com/hackiftekhar/IQAudioRecorderController
// Copyright (c) 2013-14 Iftekhar Qurashi.
//


#import <UIKit/UIKit.h>

@class IQAudioRecorderController;

@protocol IQAudioRecorderControllerDelegate <UINavigationControllerDelegate>

-(void)audioRecorderController:(IQAudioRecorderController*)controller didFinishWithAudioAtPath:(NSString*)filePath;
-(void)audioRecorderControllerDidCancel:(IQAudioRecorderController*)controller;

@end


@interface IQAudioRecorderController : UINavigationController

@property(nonatomic, weak) id<IQAudioRecorderControllerDelegate,UINavigationControllerDelegate> delegate;

@end
