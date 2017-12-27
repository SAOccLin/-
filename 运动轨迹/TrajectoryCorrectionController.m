//
//  TrajectoryCorrectionController.m
//  运动轨迹
//
//  Created by apple on 2017/5/4.
//  Copyright © 2017年 hzq. All rights reserved.
//

#import "TrajectoryCorrectionController.h"
#import <MAMapKit/MAMapKit.h>
#import <MAMapKit/MATraceManager.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface TrajectoryCorrectionController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView2;
@property (nonatomic, strong) NSMutableArray *processedOverlays; //处理后的

@property (nonatomic, strong) NSOperation *queryOperation;

@end

@implementation TrajectoryCorrectionController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.mapView2 = nil;
    self.processedOverlays = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView2 = [[MAMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    _mapView2.delegate = self;
    [self.view addSubview:_mapView2];
}

#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers
{
    NSLog(@"renderers :%@", renderers);
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        polylineView.lineWidth   = 16.f;
        [polylineView loadStrokeTextureImage:[UIImage imageNamed:@"custtexture"]];
        return polylineView;
    }
    
    return nil;
}

- (void)queryAction {
    
    AMapCoordinateType type = -1;
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *mArr = [NSMutableArray array];
    for(NSDictionary *dict in arr) {
        MATraceLocation *loc = [[MATraceLocation alloc] init];
        loc.loc = CLLocationCoordinate2DMake([[dict objectForKey:@"lat"] doubleValue], [[dict objectForKey:@"lon"] doubleValue]);
        double speed = [[dict objectForKey:@"speed"] doubleValue];
        loc.speed = speed * 3.6; //m/s  转 km/h
        loc.time = [[dict objectForKey:@"loctime"] doubleValue];
        loc.angle = [[dict objectForKey:@"bearing"] doubleValue];;
        [mArr addObject:loc];
    }
    
    MATraceManager *temp = [[MATraceManager alloc] init];
    
    __weak typeof(self) weakSelf = self;
    NSOperation *op = [temp queryProcessedTraceWith:mArr type:type processingCallback:^(int index, NSArray<MATracePoint *> *points) {
        [weakSelf addSubTrace:points toMapView:weakSelf.mapView2];
    }  finishCallback:^(NSArray<MATracePoint *> *points, double distance) {
        weakSelf.queryOperation = nil;
        [weakSelf addFullTrace:points toMapView:weakSelf.mapView2];
    } failedCallback:^(int errorCode, NSString *errorDesc) {
        NSLog(@"Error: %@", errorDesc);
        weakSelf.queryOperation = nil;
    }];
    
    self.queryOperation = op;
}

- (void)cancelAction {
    if(self.queryOperation) {
        [self.queryOperation cancel];
        
        self.queryOperation = nil;
    }
}


- (MAMultiPolyline *)makePolyLineWith:(NSArray<MATracePoint*> *)tracePoints {
    if(tracePoints.count == 0) {
        return nil;
    }
    
    CLLocationCoordinate2D *pCoords = malloc(sizeof(CLLocationCoordinate2D) * tracePoints.count);
    if(!pCoords) {
        return nil;
    }
    
    for(int i = 0; i < tracePoints.count; ++i) {
        MATracePoint *p = [tracePoints objectAtIndex:i];
        CLLocationCoordinate2D *pCur = pCoords + i;
        pCur->latitude = p.latitude;
        pCur->longitude = p.longitude;
    }
    
    MAMultiPolyline *polyline = [MAMultiPolyline polylineWithCoordinates:pCoords count:tracePoints.count drawStyleIndexes:@[@10, @60]];
    
    if(pCoords) {
        free(pCoords);
    }
    return polyline;
}

- (void)addFullTrace:(NSArray<MATracePoint*> *)tracePoints toMapView:(MAMapView *)mapView{
    MAMultiPolyline *polyline = [self makePolyLineWith:tracePoints];
    if(!polyline) {
        return;
    }
    [mapView removeOverlays:self.processedOverlays];
    [self.processedOverlays removeAllObjects];
    
    [mapView setVisibleMapRect:MAMapRectInset(polyline.boundingMapRect, -1000, -1000)];
    
    [self.processedOverlays addObject:polyline];
    [mapView addOverlays:self.processedOverlays];
}

- (void)addSubTrace:(NSArray<MATracePoint*> *)tracePoints toMapView:(MAMapView *)mapView {
    MAMultiPolyline *polyline = [self makePolyLineWith:tracePoints];
    if(!polyline) {
        return;
    }
    
    MAMapRect visibleRect = [mapView visibleMapRect];
    if(!MAMapRectContainsRect(visibleRect, polyline.boundingMapRect)) {
        MAMapRect newRect = MAMapRectUnion(visibleRect, polyline.boundingMapRect);
        [mapView setVisibleMapRect:newRect];
    }
    
    [self.processedOverlays addObject:polyline];

    
    [mapView addOverlay:polyline];
}


-(NSMutableArray *)processedOverlays{
    if (!_processedOverlays) {
        _processedOverlays = [NSMutableArray array];
    }
    return _processedOverlays;
}

@end
