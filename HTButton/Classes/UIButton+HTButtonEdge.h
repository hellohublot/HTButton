//
//  UIButton+HTButtonEdge.h
//  HTButton
//
//  Created by hublot on 2018/3/28.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HTButtonEdgeDirection) {
	HTButtonEdgeDirectionHorizontal,
	HTButtonEdgeDirectionVertical
};


@interface UIButton (HTButtonEdge)

- (void)ht_makeEdgeWithDirection:(HTButtonEdgeDirection)direction imageToTitleaOffset:(CGFloat)imageToTitleOffset;

@end
