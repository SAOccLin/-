//
//  MapViewController.m
//  运动轨迹
//
//  Created by apple on 2017/4/7.
//  Copyright © 2017年 hzq. All rights reserved.
//

#import "MapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "AFNetworking.h"
#import "MapModel.h"
#import "LocationChange.h"
#import "MyAFnetWork.h"

enum{
    OverlayViewControllerOverlayTypeCommonPolyline = 0,
    OverlayViewControllerOverlayTypeTexturePolyline,
    OverlayViewControllerOverlayTypeArrowPolyline,
    OverlayViewControllerOverlayTypeMultiTexPolyline,
};
@interface MapViewController ()<MAMapViewDelegate>
@property (nonatomic, strong) NSMutableArray *overlaysAboveLabels;
@property (nonatomic, strong) MAMapView *mapView;


@property (nonatomic,strong)NSMutableArray *locationArray;
@property (nonatomic,strong)NSMutableArray *markArray;
@property (nonatomic,strong)AFHTTPSessionManager *manage;
@property (nonatomic,strong)UIButton *leftButton;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.m_code;
    [self setMap];
    [self getLocation];
    [self setLeftButton];
}

-(void)setLeftButton{
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftButton.frame = CGRectMake(0.0, 0.0, 20, 20);
    self.leftButton.layer.contents = (id)[UIImage imageNamed:@"返回.png"].CGImage;
    [self.leftButton addTarget:self action:@selector(gohome) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    self.navigationItem.leftBarButtonItem=leftButtonItem;
}

-(void)gohome{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)setMap{
    ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
    [AMapServices sharedServices].enableHTTPS = YES;
    
    ///初始化地图
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    
    _mapView.delegate = self;
    ///把地图添加至view
    [self.view addSubview:_mapView];
    
    //如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    //自动跟踪用户位置
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    
    //    //自定义蓝点
    MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
    //精度圈是否显示
    r.showsAccuracyRing = NO;///精度圈是否显示，默认YES
    //是否显示方向指示(MAUserTrackingModeFollowWithHeading模式开启)。默认为YES
    r.showsHeadingIndicator = NO;
    //精度圈 填充颜色, 默认 kAccuracyCircleDefaultColor
    r.fillColor = [UIColor redColor];
    //精度圈 边线颜色, 默认 kAccuracyCircleDefaultColor
    r.strokeColor = [UIColor blueColor];
    
    //精度圈 边线宽度，默认0
    r.lineWidth = 2;
    //内部蓝色圆点是否使用律动效果, 默认YES
    r.enablePulseAnnimation = NO;
    //定位点背景色，不设置默认白色
    r.locationDotBgColor = [UIColor greenColor];
    //定位点蓝色圆点颜色，不设置默认蓝色
    r.locationDotFillColor = [UIColor grayColor];
    //定位图标, 与蓝色原点互斥
    //    r.image = [UIImage imageNamed:@"你的图片"];
    //    添加自定义蓝点到地图上
    [_mapView updateUserLocationRepresentation:r];
}

-(void)getLocation{
//    NSString *approveUrl = [NSString stringWithFormat:@"http://api.sunsyi.com:8081/Trajectory/gettrack/m_id/%@/limit/200",self.m_code];
    NSString *approveUrl = [NSString stringWithFormat:@"http://lock.sunsyi.com/trajectory/public/index.php/index/index/getdata"];
    NSLog(@"获取轨迹接口:%@",approveUrl);
    approveUrl= [approveUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
   
    NSDictionary *dic = @{@"num":self.m_code,
                          @"limit":@200};
    [MyAFnetWork POST:approveUrl parameters:dic constructingBodyWithBlock:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
        NSLog(@"获取轨迹返回：%@",dict);
        if ([dict[@"msg"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObjectsFromArray:dict[@"msg"]];
            [self.locationArray removeAllObjects];
            for (NSDictionary *data in arr) {
                MapModel *model = [[MapModel alloc]init];
                [model saveMapModel:data];
                if (![model.position_j isEqualToString:@"错误"]&&![model.p_time isEqualToString:@"错误"]) {
                    [self.locationArray insertObject:model atIndex:0];
                }
            }
            if (self.locationArray.count != 0) {
                
                //画线 Polyline.
                CLLocationCoordinate2D commonPolylineCoords[self.locationArray.count];
                if (self.locationArray.count !=0) {
                    for (int i=0; i<self.locationArray.count; i++) {
                        MapModel *model = self.locationArray[i];
                        CLLocationCoordinate2D coor2D = CLLocationCoordinate2DMake(([model.position_w floatValue]), ([model.position_j floatValue]));
                        coor2D = [LocationChange wgs84ToGcj02:coor2D];
                        NSLog(@"转换后的经纬度：%f,%f",coor2D.longitude,coor2D.latitude);
                        commonPolylineCoords[i].latitude = coor2D.latitude;
                        commonPolylineCoords[i].longitude = coor2D.longitude;
                        
                        MAPointAnnotation *a1 = [[MAPointAnnotation alloc] init];
                        a1.coordinate = commonPolylineCoords[i];
                        if (i == 0) {
                            a1.title = [NSString stringWithFormat:@"起点"];
                        }else if(i == self.locationArray.count-1){
                            a1.title = [NSString stringWithFormat:@"终点"];
                        }else{
                            a1.title = [NSString stringWithFormat:@"途中%d",i];
                        }
                        a1.subtitle = model.p_time;
                        [self.markArray addObject:a1];
                    }
                }
                
                
                MAPolyline *commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:self.locationArray.count];
                [self.overlaysAboveLabels insertObject:commonPolyline atIndex:OverlayViewControllerOverlayTypeCommonPolyline];
                [_mapView addOverlays:self.overlaysAboveLabels];
                
                [self.mapView addAnnotations:self.markArray];
                [self.mapView showAnnotations:self.markArray edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取轨迹错误:%@",error);
    }];
    
    
    
   /* [self.manage POST:approveUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.manage = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject  options:(NSJSONReadingMutableLeaves) error:nil];
        NSLog(@"获取轨迹返回：%@",dict);
        if ([dict[@"msg"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObjectsFromArray:dict[@"msg"]];
            if (arr.count != 0) {
                for (int i = 0;i<arr.count;i++) {
                    MapModel *model = [[MapModel alloc]init];
                    [model saveMapModel:arr[i]];
                    if (![model.position_j isEqualToString:@"错误"]&&![model.p_time isEqualToString:@"错误"]) {
                        [self.locationArray addObject:model];
                    }
                }
                
                
                //Polyline.
                CLLocationCoordinate2D commonPolylineCoords[self.locationArray.count];
                if (self.locationArray.count !=0) {
                    for (int i=0; i<self.locationArray.count; i++) {
                        MapModel *model = self.locationArray[i];
                        CLLocationCoordinate2D coor2D = CLLocationCoordinate2DMake(([model.position_w floatValue]), ([model.position_j floatValue]));
                        coor2D = [LocationChange wgs84ToGcj02:coor2D];
                        NSLog(@"转换后的经纬度：%f,%f",coor2D.longitude,coor2D.latitude);
                        commonPolylineCoords[i].latitude = coor2D.latitude;
                        commonPolylineCoords[i].longitude = coor2D.longitude;
                        
                        MAPointAnnotation *a1 = [[MAPointAnnotation alloc] init];
                        a1.coordinate = commonPolylineCoords[i];
                        if (i == 0) {
                            a1.title = [NSString stringWithFormat:@"起点"];
                        }else if(i == self.locationArray.count-1){
                            a1.title = [NSString stringWithFormat:@"终点"];
                        }else{
                            a1.title = [NSString stringWithFormat:@"途中%d",i];
                        }
                        a1.subtitle = model.p_time;
                        [self.markArray addObject:a1];
                    }
                }
                
                
                MAPolyline *commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:self.locationArray.count];
                [self.overlaysAboveLabels insertObject:commonPolyline atIndex:OverlayViewControllerOverlayTypeCommonPolyline];
                [_mapView addOverlays:self.overlaysAboveLabels];
                
                [self.mapView addAnnotations:self.markArray];
                [self.mapView showAnnotations:self.markArray edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
            }
        }
    } failure:nil];*/
}

//点击地图触发
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate{
//    NSLog(@"用户经纬度:%f,%f",coordinate.longitude,coordinate.latitude);
}

//缩放地图后触发
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction{
    NSLog(@"当前地图缩放级别%f",_mapView.zoomLevel);
}

//画线
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 1.f;
        polylineRenderer.strokeColors = @[[UIColor redColor], [UIColor greenColor], [UIColor yellowColor]];
        
        return polylineRenderer;
    }
    else if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineRenderer.lineWidth    = 6.f;
        [polylineRenderer loadStrokeTextureImage:[UIImage imageNamed:@"arrowTexture"]];
        return polylineRenderer;
    }
    
    return nil;
}

#pragma mark - Helpers
/*!
 @brief  生成多角星坐标
 @param coordinates 输出的多角星坐标数组指针。内存需在外申请，方法内不释放，多角星坐标结果输出。
 @param pointsCount 输出的多角星坐标数组元素个数。
 @param starCenter  多角星的中心点位置。
 */
- (void)generateStarPoints:(CLLocationCoordinate2D *)coordinates pointsCount:(NSUInteger)pointsCount atCenter:(CLLocationCoordinate2D)starCenter
{
#define STAR_RADIUS 0.05
#define PI 3.1415926
    NSUInteger starRaysCount = pointsCount / 2;
    for (int i =0; i<starRaysCount; i++)
    {
        float angle = 2.f*i/starRaysCount*PI;
        int index = 2 * i;
        coordinates[index].latitude = STAR_RADIUS* sin(angle) + starCenter.latitude;
        coordinates[index].longitude = STAR_RADIUS* cos(angle) + starCenter.longitude;
        
        index++;
        angle = angle + (float)1.f/starRaysCount*PI;
        coordinates[index].latitude = STAR_RADIUS/2.f* sin(angle) + starCenter.latitude;
        coordinates[index].longitude = STAR_RADIUS/2.f* cos(angle) + starCenter.longitude;
    }
    
}

//画大头针
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        
        if ([annotation.title isEqualToString:@"起点"]) {
//            annotationView.centerOffset = CGPointMake(0, -18);
            NSLog(@"图片宽高:%f,%f",annotationView.imageView.frame.size.width,annotationView.imageView.frame.size.height);
            annotationView.pinColor = MAPinAnnotationColorGreen;
        }else if([annotation.title isEqualToString:@"终点"]){
            annotationView.pinColor = MAPinAnnotationColorRed;
        }else{
            annotationView.pinColor = MAPinAnnotationColorPurple;
            
//            annotationView.image = [UIImage imageNamed:@"大头钉.png"];
            
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = NO;        //设置标注可以拖动，默认为NO
        return annotationView;
    }
    return nil;
}


-(AFHTTPSessionManager *)manage{
    if (!_manage) {
        _manage = [AFHTTPSessionManager manager];
        _manage.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manage.responseSerializer = [AFHTTPResponseSerializer serializer];
        //因AFNetworking 2.0开始格式有误，下面这句代码必须添加，否则有些格式无法识别
        _manage.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        [_manage.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    }
    return _manage;
}

-(NSMutableArray *)overlaysAboveLabels{
    if (!_overlaysAboveLabels) {
        _overlaysAboveLabels = [NSMutableArray array];
    }
    return _overlaysAboveLabels;
}

-(NSMutableArray *)locationArray{
    if (!_locationArray) {
        _locationArray = [NSMutableArray array];
    }
    return _locationArray;
}

-(NSMutableArray *)markArray{
    if (!_markArray) {
        _markArray = [NSMutableArray array];
    }
    return _markArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
