//
//  GKLineGraph.h
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

#import <UIKit/UIKit.h>

//Line Attributes
extern NSString *const GKLALineColor;
extern NSString *const GKLAShowPoints;
extern NSString *const GKLAShowLines;
extern NSString *const GKLAAnimationDuration;
extern NSString *const GKLALineWidth;
extern NSString *const GKLAPointWidth;
extern NSString *const GKLAPattern;

struct GKRange {
    CGFloat min;
    CGFloat max;
};
typedef struct GKRange GKRange;

struct GKConstraint {
    GKRange vertical;
    GKRange horizontal;
};
typedef struct GKConstraint GKConstraint;

CG_INLINE GKConstraint
GKConstraintMake(CGFloat verticalMin, CGFloat verticalMax, CGFloat horizontalMin, CGFloat horizontalMax)
{
  GKConstraint constraint;
  constraint.vertical.min = verticalMin;
  constraint.vertical.max = verticalMax;
  constraint.horizontal.min = horizontalMin;
  constraint.horizontal.max = horizontalMax;
  return constraint;
}

@protocol GKLineGraphDataSource;

@interface GKLineGraph : UIView

@property (nonatomic, weak) IBOutlet id<GKLineGraphDataSource> dataSource;
@property (nonatomic, assign) GKConstraint graphConstraints;

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat pointWidth;
@property (nonatomic, assign) CGFloat margin;

@property (nonatomic, assign) NSInteger verticalLabelsCount;
@property (nonatomic, assign) NSInteger horizontalLabelsCount;
@property (nonatomic, assign) NSInteger gridSections;

@property (nonatomic, strong) UIColor *gridColor;
@property (nonatomic, strong) UIColor *labelColor;

@property (nonatomic, strong) UIFont *labelFont;

@property (nonatomic, assign) BOOL startFromZero;
@property (nonatomic, assign) BOOL showGraphPoints;
@property (nonatomic, assign) BOOL showGraphLines;
@property (nonatomic, assign) BOOL showGridLines;

- (void)draw;
- (void)reset;

@end

@protocol GKLineGraphDataSource <NSObject>

- (NSArray*)verticalValuesForLineAtIndex:(NSInteger)index;
- (NSInteger)numberOfGraphLines;

@optional

- (NSArray*)horizontalValuesForLineAtIndex:(NSInteger)index;
- (NSArray*)labelsForData;
- (NSDictionary *)lineAttributesForLineAtIndex:(NSInteger)index;

@end
