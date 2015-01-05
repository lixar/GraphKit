//
//  GKLineGraph.m
//  GraphKit
//
//  Copyright (c) 2014 Michal Konturek
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "GKLineGraph.h"

#import <FrameAccessor/FrameAccessor.h>
#import <MKFoundationKit/NSArray+MK.h>

NSString *const GKLAData = @"Data";
NSString *const GKLALineColor = @"LineColor";
NSString *const GKLAShowPoints = @"ShowPoints";
NSString *const GKLAShowLines = @"ShowLines";
NSString *const GKLAAnimationDuration = @"AnimationDuration";
NSString *const GKLAPointWidth = @"PointWidth";
NSString *const GKLAPattern = @"Pattern";

static CGFloat kDefaultLabelWidth = 40.0;
static CGFloat kDefaultLabelHeight = 25.0;
static NSInteger kDefaultValueLabelCount = 5;

static CGFloat kDefaultLineWidth = 3.0;
static CGFloat kDefaultPointWidth = 1.5;
static CGFloat kDefaultMargin = 10.0;

static CGFloat kXAxisMargin = 5.0;

@interface GKLineGraph ()

@property (nonatomic, strong) NSArray *titleLabels;
@property (nonatomic, strong) NSArray *valueLabels;

@end

@implementation GKLineGraph

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init {
    self.lineWidth = kDefaultLineWidth;
    self.pointWidth = kDefaultPointWidth;
    self.margin = kDefaultMargin;
    self.verticalLabelsCount = kDefaultValueLabelCount;
    self.gridLineWidth = kDefaultLineWidth;
    self.gridSections = kDefaultValueLabelCount;
    self.gridColor = [[UIColor alloc] initWithRed:0.8 green:0.8 blue:0.8 alpha:0.5];
    self.labelFont = [UIFont systemFontOfSize:13];
    self.labelColor = [UIColor blackColor];
    self.showGraphPoints = YES;
    self.showGraphLines = YES;
    self.showGridLines = YES;
    self.graphConstraints = GKConstraintMake(NAN, NAN, NAN, NAN);
    self.clipsToBounds = YES;
}

- (void)draw {
    NSAssert(self.dataSource, @"GKLineGraph : No data source is assgined.");
    
    if ([self _hasTitleLabels]) [self _removeTitleLabels];
    [self _constructTitleLabels];
    [self _positionTitleLabels];

    if ([self _hasValueLabels]) [self _removeValueLabels];
    [self _constructValueLabels];
  
    [self _drawGridLines];
    [self _drawData];
}

- (BOOL)_hasTitleLabels {
    return ![self.titleLabels mk_isEmpty];
}

- (BOOL)_hasValueLabels {
    return ![self.valueLabels mk_isEmpty];
}

- (void)_constructTitleLabels {
  
    NSInteger count = [self.dataSource labelsForData].count;
  
    id items = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger idx = 0; idx < count; idx++) {
      
        CGRect frame = CGRectMake(0, 0, [self _horizontalLabelWidth], kDefaultLabelHeight);
        UILabel *item = [[UILabel alloc] initWithFrame:frame];
        item.textAlignment = NSTextAlignmentCenter;
        item.font = self.labelFont;
        item.textColor = self.labelColor;
      
        item.text = [self.dataSource labelsForData][idx];

        [items addObject:item];
    }
    self.titleLabels = items;
}

- (void)_removeTitleLabels {
    [self.titleLabels mk_each:^(id item) {
        [item removeFromSuperview];
    }];
    self.titleLabels = nil;
}

- (void)_positionTitleLabels {
  
    NSInteger count = self.horizontalLabelsCount;
    for (NSInteger idx = 0; idx < count; idx++) {
      
        CGFloat labelHeight = kDefaultLabelHeight;
        CGFloat startX = [self _horizontalLabelStartXForIndex:idx];
        CGFloat startY = (self.height - labelHeight);
        
        UILabel *label = [self.titleLabels objectAtIndex:idx];
        label.x = startX;
        label.y = startY;
        
        [self addSubview:label];
    };
}

- (CGFloat)_horizontalLabelWidth {
    return [self _graphWidth] / self.horizontalLabelsCount;
}

- (CGFloat)_horizontalLabelStartXForIndex:(NSInteger)index {
    return [self _graphLeftMargin] + index * [self _horizontalLabelWidth];
}

- (CGFloat)_linePointXForIndex:(NSInteger)dataIndex lineIndex:(NSInteger)lineIndex totalDataPoints:(NSInteger)totalDataPoints {
    BOOL horizontalData = [self _hasHorizontalDataForIndex:lineIndex];
    CGFloat maxVal = horizontalData ? [self _maxHorizontalValue] : totalDataPoints;
    CGFloat minVal = horizontalData ? [self _minHorizontalValue] : 0;
    CGFloat value = horizontalData ? [[self.dataSource horizontalValuesForLineAtIndex:lineIndex][dataIndex] floatValue] : dataIndex;
    CGFloat scale = (value - minVal);
    scale /= horizontalData ? (maxVal - minVal) : totalDataPoints-1;
    CGFloat result = [self _graphWidth] * scale;
    result += [self _graphLeftMargin];
  
    return result;
}

- (void)_constructValueLabels {
    
    NSInteger count = self.verticalLabelsCount;
    id items = [NSMutableArray arrayWithCapacity:count];
    
    for (NSInteger idx = 0; idx < count; idx++) {
        
        CGRect frame = CGRectMake(0, 0, kDefaultLabelWidth, kDefaultLabelHeight);
        UILabel *item = [[UILabel alloc] initWithFrame:frame];
        item.textAlignment = NSTextAlignmentRight;
        item.font = self.labelFont;
        item.textColor = self.labelColor;
    
        CGFloat value = [self _minVerticalValue] + (idx * [self _stepValueLabelY]);
        item.centerY = [self _positionYForLineValue:value];

        item.text = [@(ceil(value)) stringValue];
//        item.text = [@(value) stringValue];
        
        [items addObject:item];
        [self addSubview:item];
    }
    self.valueLabels = items;
}

- (CGFloat)_stepValueLabelY {
    return (([self _maxVerticalValue] - [self _minVerticalValue]) / (self.verticalLabelsCount - 1));
}

- (CGFloat)_maxVerticalValue {
    CGFloat verticalMax = self.graphConstraints.vertical.max;
    if (!isnan(verticalMax)) return verticalMax;
    id values = [self _allVerticalValues];
    return [[values mk_max] floatValue];
}

- (CGFloat)_minVerticalValue {
    CGFloat verticalMin = self.graphConstraints.vertical.min;
    if (self.startFromZero) return 0;
    else if (!isnan(verticalMin)) return verticalMin;
    id values = [self _allVerticalValues];
    return [[values mk_min] floatValue];
}

- (NSArray *)_allVerticalValues {
    NSInteger count = [self.dataSource numberOfGraphLines];
    id values = [NSMutableArray array];
    for (NSInteger idx = 0; idx < count; idx++) {
        id item = [self.dataSource verticalValuesForLineAtIndex:idx];
        [values addObjectsFromArray:item];
    }
    return values;
}

- (CGFloat)_maxHorizontalValue {
    CGFloat horizontalMax = self.graphConstraints.horizontal.max;
    if (!isnan(horizontalMax)) return horizontalMax;
    id values = [self _allHorizontalValues];
    return [[values mk_max] floatValue];
}

- (CGFloat)_minHorizontalValue {
    CGFloat horizontalMin = self.graphConstraints.horizontal.min;
    if (!isnan(horizontalMin)) return horizontalMin;
    id values = [self _allHorizontalValues];
    return [[values mk_min] floatValue];
    return 0;
}

- (NSArray *)_allHorizontalValues {
    NSInteger count = [self.dataSource numberOfGraphLines];
    id values = [NSMutableArray array];
    for (NSInteger idx = 0; idx < count; idx++) {
    id item = [self.dataSource horizontalValuesForLineAtIndex:idx];
    if(item != nil) [values addObjectsFromArray:item];
  }
  return values;
}

- (BOOL)_hasHorizontalDataForIndex:(NSInteger)index {
  return [self.dataSource horizontalValuesForLineAtIndex:index] != nil;
}

- (void)_removeValueLabels {
    [self.valueLabels mk_each:^(id item) {
        [item removeFromSuperview];
    }];
    self.valueLabels = nil;
}

- (CGFloat)_graphHeight {
    return (self.height - kDefaultLabelHeight - [self _graphTopMargin]);
}

- (CGFloat)_graphWidth {
    return self.frame.size.width - [self _graphLeftMargin]*1.5 - self.margin*2;
}

- (CGFloat)_graphTopMargin {
    return kDefaultLabelHeight/2;
}

- (CGFloat)_graphLeftMargin {
    return kXAxisMargin + kDefaultLabelWidth + self.margin;
}

- (void)_drawData {
    for (NSInteger idx = 0; idx < [self.dataSource numberOfGraphLines]; idx++) {
        [self _drawDataAtIndex:idx];
    }
}

- (void)_drawDataAtIndex:(NSInteger)lineIndex {
    
    // http://stackoverflow.com/questions/19599266/invalid-context-0x0-under-ios-7-0-and-system-degradation
    UIGraphicsBeginImageContext(self.frame.size);
  
    UIBezierPath *path;
    CAShapeLayer *layer;
  
    BOOL showGraphPoints = self.showGraphPoints;
    if ([self.dataSource respondsToSelector:@selector(lineAttributesForLineAtIndex:)]) {
        NSDictionary *options = [self.dataSource lineAttributesForLineAtIndex:lineIndex];
        if([options valueForKey:GKLAShowPoints])showGraphPoints = ((NSNumber *)[options valueForKey:GKLAShowPoints]).boolValue;
    }
  
    if(self.showGraphLines) {
        path = [self _bezierPath];
        layer = [self _lineLayer];
        layer.strokeColor = ((UIColor *)[[self.dataSource lineAttributesForLineAtIndex:lineIndex] objectForKey:GKLALineColor]).CGColor;
        if ([self.dataSource respondsToSelector:@selector(lineAttributesForLineAtIndex:)]) {
            NSDictionary *options = [self.dataSource lineAttributesForLineAtIndex:lineIndex];
            if([options valueForKey:GKLAPattern]) [layer setLineDashPattern:[options valueForKey:GKLAPattern]];
        }
        [self.layer addSublayer:layer];
    }
  
    NSInteger dataIndex = 0;
    NSArray *values = [self.dataSource verticalValuesForLineAtIndex:lineIndex];
    for (id item in values) {

        CGFloat x = [self _linePointXForIndex:dataIndex lineIndex:lineIndex totalDataPoints:values.count];
        CGFloat y = [self _positionYForLineValue:[item floatValue]];
        CGPoint point = CGPointMake(x, y);
      
        if(self.showGraphLines) {
            if (dataIndex != 0) [path addLineToPoint:point];
            [path moveToPoint:point];
        }
      
        BOOL atStartOfGraph = (x == [self _graphLeftMargin]);
        BOOL atEndOfGraph = (x == self.frame.size.width - [self _graphLeftMargin]/2);
        if(showGraphPoints && !atStartOfGraph && !atEndOfGraph) {
            [self _drawPointAtPosition:point
                         withLineIndex:lineIndex
                         withDataIndex:dataIndex];
        }
      
        dataIndex++;
    }
    
    layer.path = path.CGPath;
    
    if (self.showGraphLines) {
        CABasicAnimation *animation = [self _animationWithKeyPath:@"strokeEnd"];
        if ([self.dataSource respondsToSelector:@selector(lineAttributesForLineAtIndex:)]) {
            NSDictionary *options = [self.dataSource lineAttributesForLineAtIndex:lineIndex];
            if([options objectForKey:GKLAAnimationDuration])animation.duration = ((NSNumber*)[options objectForKey:GKLAAnimationDuration]).floatValue;
        }
        [layer addAnimation:animation forKey:@"strokeEndAnimation"];
    }
  
    UIGraphicsEndImageContext();
}

- (void)_drawPointAtPosition:(CGPoint)point
               withLineIndex:(NSInteger)lineIndex
               withDataIndex:(NSInteger)dataIndex {
  
    UIColor *color = [[self.dataSource lineAttributesForLineAtIndex:lineIndex] objectForKey:GKLALineColor];
    CAShapeLayer *circle = [self _pointLayerWithColor:color];
    circle.position = CGPointMake(point.x - self.pointWidth, point.y - self.pointWidth);
  
    [self.layer addSublayer:circle];
    NSInteger totalDataPoints = [self.dataSource verticalValuesForLineAtIndex:lineIndex].count;
  
    CABasicAnimation *animation = [self _animationWithKeyPath:@"opacity"];
    if ([self.dataSource respondsToSelector:@selector(lineAttributesForLineAtIndex:)]) {
        NSDictionary *options = [self.dataSource lineAttributesForLineAtIndex:lineIndex];
        if([options objectForKey:GKLAAnimationDuration])animation.duration = ((NSNumber*)[options objectForKey:GKLAAnimationDuration]).floatValue;
    }

    animation.beginTime = CACurrentMediaTime() + (animation.duration / (totalDataPoints-1)) * dataIndex;

    animation.duration = 0.1;
    animation.fillMode = kCAFillModeBackwards;
    [circle addAnimation:animation forKey:@"opacityIN"];
}

- (CAShapeLayer *)_pointLayerWithColor:(UIColor *)color {
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.lineWidth = self.pointWidth;
    
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.pointWidth*2, self.pointWidth*2)
                                             cornerRadius:self.pointWidth].CGPath;
    circle.fillColor = color.CGColor;
    circle.strokeColor = color.CGColor;
    
    return circle;
}

- (CGFloat)_positionYForLineValue:(CGFloat)value {
    CGFloat scale = (value - [self _minVerticalValue]) / ([self _maxVerticalValue] - [self _minVerticalValue]);
    CGFloat result = [self _graphHeight] * scale;
    result = ([self _graphHeight] -  result);
    result += [self _graphTopMargin];
    return result;
}

- (UIBezierPath *)_bezierPath {
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineWidth = self.lineWidth;
    return path;
}

- (CAShapeLayer *)_lineLayer {
    CAShapeLayer *item = [CAShapeLayer layer];
    item.fillColor = [[UIColor blackColor] CGColor];
    item.lineCap = kCALineCapRound;
    item.lineJoin  = kCALineJoinRound;
    item.lineWidth = self.lineWidth;
//    item.strokeColor = [self.foregroundColor CGColor];
    item.strokeColor = [[UIColor redColor] CGColor];
    item.strokeEnd = 1;
    return item;
}

- (CABasicAnimation *)_animationWithKeyPath:(NSString *)keyPath {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = @(0);
    animation.toValue = @(1);
//    animation.delegate = self;
    return animation;
}

- (void)_drawGridLines {
    UIGraphicsBeginImageContext(self.frame.size);
    [self _drawSolidGridOutline];
    [self _drawHorizontalLabelMarkers];
    if(self.showGridLines) [self _drawHorizontalGridLines];
    UIGraphicsEndImageContext();
}

- (void)_drawSolidGridOutline {
    [self _drawVerticalGridOutline];
    [self _drawHorizontalGridOutline];
}

- (void)_drawVerticalGridOutline {
    UIBezierPath *path;
    CAShapeLayer *layer;
    for (NSInteger idx = 0; idx < 2; idx++) {
        path = [self _bezierPath];
        layer = [self _lineLayer];
        layer.lineWidth = self.gridLineWidth;
        layer.strokeColor = self.gridColor.CGColor;
        
        [self.layer addSublayer:layer];
        
        CGFloat x = [self _graphLeftMargin] + ([self _graphWidth] *idx);
        CGFloat y = [self _graphTopMargin];
        CGPoint point = CGPointMake(x, y);
        
        [path addLineToPoint:point];
        [path moveToPoint:point];
        
        y += [self _graphHeight];
        point = CGPointMake(x, y);
        
        [path addLineToPoint:point];
        [path moveToPoint:point];
        layer.path = path.CGPath;
    }
}

- (void)_drawHorizontalGridOutline {
    UIBezierPath *path;
    CAShapeLayer *layer;
    for (NSInteger idx = 0; idx < 2; idx++) {
        path = [self _bezierPath];
        layer = [self _lineLayer];
        layer.lineWidth = self.gridLineWidth;
        layer.strokeColor = self.gridColor.CGColor;
        
        [self.layer addSublayer:layer];
        
        CGFloat x = [self _graphLeftMargin];
        CGFloat y = [self _graphTopMargin] + ([self _graphHeight] *idx);
        CGPoint point = CGPointMake(x, y);
        
        [path addLineToPoint:point];
        [path moveToPoint:point];
        
        x = [self _graphWidth] + [self _graphLeftMargin];
        point = CGPointMake(x, y);
        
        [path addLineToPoint:point];
        [path moveToPoint:point];
        layer.path = path.CGPath;
    }
}

- (void)_drawHorizontalGridLines {
    UIBezierPath *path;
    CAShapeLayer *layer;
    
    NSInteger numberOfBars = self.gridSections;
    for (NSInteger idx = 1; idx < numberOfBars; idx++) {
        path = [self _bezierPath];
        layer = [self _lineLayer];
        layer.lineWidth = self.gridLineWidth;
        layer.strokeColor = self.gridColor.CGColor;
        [self.layer addSublayer:layer];
        
        [layer setLineDashPattern:@[@12,@3]];
        
        CGFloat x = [self _graphLeftMargin];
        CGFloat y = [self _graphHeight];
        y -= (([self _graphHeight] / numberOfBars) * idx) - [self _graphTopMargin];
        CGPoint point = CGPointMake(x, y);
        
        [path addLineToPoint:point];
        [path moveToPoint:point];
        
        x = [self _graphWidth] + [self _graphLeftMargin];
        point = CGPointMake(x, y);
        
        [path addLineToPoint:point];
        [path moveToPoint:point];
        
        layer.path = path.CGPath;
    }
}

- (void)_drawHorizontalLabelMarkers {
    UIBezierPath *path;
    CAShapeLayer *layer;
  
    for (NSInteger idx = 1; idx < self.horizontalLabelsCount; idx++) {
        path = [self _bezierPath];
        layer = [self _lineLayer];
        layer.lineWidth = self.gridLineWidth;
        layer.strokeColor = self.gridColor.CGColor;
        [self.layer addSublayer:layer];
        
        CGFloat x = [self _graphLeftMargin] + [self _horizontalLabelWidth] *idx;
        CGFloat y = [self _graphHeight] + kDefaultLabelHeight - [self _graphTopMargin];
        CGPoint point = CGPointMake(x, y);
        
        [path addLineToPoint:point];
        [path moveToPoint:point];
        
        y =  [self _graphHeight] + kDefaultLabelHeight;
        point = CGPointMake(x, y);
        
        [path addLineToPoint:point];
        [path moveToPoint:point];
        
        layer.path = path.CGPath;
    }
}

- (void)reset {
    self.layer.sublayers = nil;
    [self _removeTitleLabels];
    [self _removeValueLabels];
}

@end
