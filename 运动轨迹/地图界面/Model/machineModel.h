//
//  machineModel.h
//  运动轨迹
//
//  Created by apple on 2017/4/7.
//  Copyright © 2017年 hzq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface machineModel : NSObject
@property (nonatomic,strong)NSString *m_id;//机器id
@property (nonatomic,strong)NSString *m_code;//机器识别码
@property (nonatomic,strong)NSString *m_time;//机器注册时间

-(void)savemachineModel:(NSDictionary *)dic;
@end
