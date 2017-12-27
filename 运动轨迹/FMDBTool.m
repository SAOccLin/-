//
//  FMDBTool.m
//  运动轨迹
//
//  Created by apple on 2017/5/4.
//  Copyright © 2017年 hzq. All rights reserved.
//

#import "FMDBTool.h"
#import "FMDatabase.h"

@interface FMDBTool ()

@property(nonatomic,strong)FMDatabase *db;

@end

@implementation FMDBTool
//单例
+ (instancetype)shareDataBase{
    static FMDBTool *tool = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        tool = [[FMDBTool alloc]init];
    });
    return tool;
}
//初始化创建数据库
- (instancetype)init{
    self = [super init];
    if (self) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        NSString *docuPath = [path stringByAppendingPathComponent:@"TrackGuiJi.sqlite"];
        NSLog(@"%@",docuPath);
        _db = [[FMDatabase alloc]initWithPath:docuPath];
        [_db open];
        BOOL success1 = [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS M_CODE (m_code text)"];
        
        if (success1) {
            NSLog(@"创建m_code列表成功");
        } else {
            NSLog(@"创建m_code列表失败");
        }
        [_db close];
    }
    return self;
}

//添加机器码
- (void)insertM_Code:(NSString *)m_code{
    [self.db open];
    BOOL resut =[self.db executeStatements:[NSString stringWithFormat:@"insert into M_CODE values('%@');",m_code]];
    if (resut==YES) {
        NSLog(@"写入M_CODE列表成功");
    }else{
        NSLog(@"写入M_CODE列表失败");
    }
    [self.db close];
}

//搜索机器码
-(NSArray *)selectM_Code{
    [_db open];
    FMResultSet *set = [self.db executeQuery:@"SELECT *FROM M_CODE;"];
    NSArray *arr = [NSArray array];
    while ([set next]) {
        NSString *m_code =  [set objectForColumnName:@"m_code"];
        arr = [arr arrayByAddingObject:m_code];
    }
    [self.db close];
    return arr;

}

//删除机器码
- (void)deleteM_Code:(NSString *)m_code{
    [self.db open];
    BOOL resut = [self.db executeStatements:[NSString stringWithFormat:@"DELETE FROM M_CODE where m_code = '%@';",m_code]];
    if (resut==YES) {
        NSLog(@"删除M_CODE成功");
    }else{
        NSLog(@"删除M_CODE失败");
    }
    [self.db close];
}
@end
