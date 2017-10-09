//
//  UserModel.h
//  MyPods
//
//  Created by Jion on 2017/6/23.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import <Realm/Realm.h>

@interface Dog : RLMObject
@property NSString *name;
@property NSInteger age;
@property (readonly) RLMLinkingObjects *owners;

@end
RLM_ARRAY_TYPE(Dog)

////////////////////////////

@interface UserModel : RLMObject
//id 主键
@property NSString *Id;
//忽略键
@property NSInteger tmpID;

@property NSString  *name;
@property NSString  *password;

@property RLMArray<Dog> *dogs;

@end

///////

