//
//  machineModel.m
//  运动轨迹
//
//  Created by apple on 2017/4/7.
//  Copyright © 2017年 hzq. All rights reserved.
//

#import "machineModel.h"

@implementation machineModel
-(void)savemachineModel:(NSDictionary *)dic{
    self.m_id = [NSString stringWithFormat:@"%@",dic[@"m_id"]];
    self.m_code = [NSString stringWithFormat:@"%@",dic[@"m_code"]];
    self.m_time = [NSString stringWithFormat:@"%@",dic[@"m_tiem"]];
}

//空实现
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
