//
//  MapModel.h
//  运动轨迹
//
//  Created by apple on 2017/4/7.
//  Copyright © 2017年 hzq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapModel : NSObject
@property (nonatomic,strong)NSString *p_time;//位置更新时间
@property (nonatomic,strong)NSString *position_w;//纬度
@property (nonatomic,strong)NSString *position_j;//经度

-(void)saveMapModel:(NSDictionary *)dic;
@end
