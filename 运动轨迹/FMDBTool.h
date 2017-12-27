//
//  FMDBTool.h
//  运动轨迹
//
//  Created by apple on 2017/5/4.
//  Copyright © 2017年 hzq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMDBTool : NSObject
/**单例 */
+ (instancetype)shareDataBase;

//添加机器码
- (void)insertM_Code:(NSString *)m_code;
//搜索机器码
-(NSArray *)selectM_Code;
//删除机器码
- (void)deleteM_Code:(NSString *)m_code;
@end
