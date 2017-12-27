//
//  MapModel.m
//  运动轨迹
//
//  Created by apple on 2017/4/7.
//  Copyright © 2017年 hzq. All rights reserved.
//

#import "MapModel.h"

@implementation MapModel
-(void)saveMapModel:(NSDictionary *)dic{
    self.position_j=@"错误";
    NSString *time = [NSString stringWithFormat:@"%@",dic[@"p_time"]];
    if ([self validatePassword:time]&&time.length == 12&&[time integerValue] != 0) {
        NSMutableString* str1 = [NSMutableString stringWithFormat:@"20%@",dic[@"p_time"]];
        
        [str1 insertString:@"-"atIndex:4];
        [str1 insertString:@"-"atIndex:7];
        [str1 insertString:@" "atIndex:10];
        [str1 insertString:@":"atIndex:13];
        [str1 insertString:@":"atIndex:16];
        self.p_time = str1;
    }else{
        self.p_time = @"错误";
    }
    
    NSArray *array = [NSArray array];
    NSString *ss = dic[@"p_position"];
    if (ss.length==22)
    {
        array = [dic[@"p_position"] componentsSeparatedByString:@":"];
        self.position_j = array[0];
        self.position_w = array[1];
        if ([self.position_j integerValue] == 0|| [self.position_w integerValue] == 0) {
            self.position_j = @"错误";
        }
    }
}

//正则
- (BOOL) validatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^[0-9]*$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}
@end
