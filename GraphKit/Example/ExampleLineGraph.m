//
//  ExampleLineGraph.m
//  GraphKit
//
//  Created by Michal Konturek on 21/04/2014.
//  Copyright (c) 2014 Michal Konturek. All rights reserved.
//

#import "ExampleLineGraph.h"

#import "UIViewController+BButton.h"

@interface ExampleLineGraph ()

@end

@implementation ExampleLineGraph

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setupButtons];
    
    self.view.backgroundColor = [UIColor gk_cloudsColor];

    [self _setupExampleGraph];
}

- (void)_setupExampleGraph {

    self.data = @[
                  @[@40,@20,@60,@40,@140],
                  @[@40, @20, @60, @100, @60, @20, @60],
                  @[@80, @60, @40, @120, @100, @40, @110],
                  @[@120, @150, @80, @120, @140, @100, @0]
//                  @[@620, @650, @580, @620, @540, @400, @0]
                  ];
  
    self.horizontalData = @[
                            @[ @2002, @2003, @2004, @2005, @2006]
                            ];
    
    self.labels = @[@"2001", @"2002", @"2003", @"2004", @"2005", @"2006"];

    self.options = @[@{
                     GKLALineColor : [UIColor gk_turquoiseColor],
                     GKLAAnimationDuration : @1
                     },
                   @{
                     GKLALineColor : [UIColor gk_peterRiverColor],
                     GKLAAnimationDuration : @1.6
                     },
                   @{
                     GKLALineColor : [UIColor gk_alizarinColor],
                     GKLAAnimationDuration : @2.2
                     },
                   @{
                     GKLALineColor : [UIColor gk_sunflowerColor],
                     GKLAAnimationDuration : @1.4
                     }];
  
    self.graph.dataSource = self;
    self.graph.lineWidth = 3.0;
    
    self.graph.graphConstraints = GKConstraintMake(0, 150, 2001, 2007);

    self.graph.margin = 0;
    self.graph.lineWidth = 1.5;
    self.graph.pointWidth = 1.5;
    self.graph.gridSections = 10;
  
    self.graph.verticalLabelsCount = 3;
    self.graph.horizontalLabelsCount = self.labels.count;
    self.graph.showGraphLines = YES;
    self.graph.showGraphPoints = YES;
    self.graph.showGridLines = YES;
    [self.graph draw];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Event Handlers

- (IBAction)onButtonDraw:(id)sender {
    [self.graph reset];
    [self.graph draw];
}

- (IBAction)onButtonReset:(id)sender {
    [self.graph reset];    
}


#pragma mark - GKLineGraphDataSource

- (NSArray *)verticalValuesForLineAtIndex:(NSInteger)index{
    return self.data[index];
}

- (NSInteger)numberOfGraphLines {
    return self.data.count;
}

- (NSArray *)horizontalValuesForLineAtIndex:(NSInteger)index {
  if(index < self.horizontalData.count) return self.horizontalData[index];
  else return nil;
}

- (NSArray*)labelsForData {
    return self.labels;
}

- (NSDictionary *)lineAttributesForLineAtIndex:(NSInteger)index {
    return self.options[index];
}

@end
