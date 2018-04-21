//
//  UIButton+HTButtonEdge.m
//  HTButton
//
//  Created by hublot on 2018/3/28.
//

#import "UIButton+HTButtonEdge.h"
#import <objc/runtime.h>

@implementation NSObject (HTRuntime)

- (void)ht_setValue:(id)value forSelector:(SEL)selector {
	objc_setAssociatedObject(self, selector, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)ht_valueForSelector:(SEL)selector {
	return objc_getAssociatedObject(self, selector);
}


+ (void)ht_swizzInstanceNativeSelector:(SEL)nativeSelector customSelector:(SEL)customSelector {
	Method nativeMethod = class_getInstanceMethod(self, nativeSelector);
	Method customMethod = class_getInstanceMethod(self, customSelector);
	if (!(nativeMethod || customMethod)) {
		return;
	}
	class_addMethod(self, nativeSelector, class_getMethodImplementation(self, nativeSelector), method_getTypeEncoding(nativeMethod));
	class_addMethod(self, customSelector, class_getMethodImplementation(self, customSelector), method_getTypeEncoding(customMethod));
	method_exchangeImplementations(class_getInstanceMethod(self, nativeSelector),
								   class_getInstanceMethod(self, customSelector));
}

+ (void)ht_swizzleClassNativeSelector:(SEL)nativeSelector customSelector:(SEL)customSelector {
	Method nativeMethod = class_getClassMethod(self, nativeSelector);
	Method customMethod = class_getClassMethod(self, customSelector);
	method_exchangeImplementations(nativeMethod, customMethod);
}

@end




@implementation UIButton (HTButtonEdge)

+ (void)load {
	[self ht_swizzInstanceNativeSelector:@selector(sizeThatFits:) customSelector:@selector(ht_sizeThatFits:)];
	[self ht_swizzInstanceNativeSelector:@selector(intrinsicContentSize) customSelector:@selector(ht_intrinsicContentSize)];
}

- (void)ht_makeEdgeWithDirection:(HTButtonEdgeDirection)direction imageToTitleaOffset:(CGFloat)imageToTitleOffset {
	CGSize imageViewSize = self.imageView.intrinsicContentSize;
	CGSize titleLabelSize = self.titleLabel.intrinsicContentSize;
	CGSize offsetContentSize = CGSizeZero;
	if (CGSizeEqualToSize(imageViewSize, CGSizeZero)
		|| CGSizeEqualToSize(titleLabelSize, CGSizeZero)
		|| CGSizeEqualToSize(imageViewSize, CGSizeMake(- 1, - 1))
		|| CGSizeEqualToSize(titleLabelSize, CGSizeMake(- 1, - 1))
		|| CGSizeEqualToSize(titleLabelSize, CGSizeMake(0, 22))
		|| CGSizeEqualToSize(self.intrinsicContentSize, CGSizeMake(30, 34))) {
		return;
	}
	UIEdgeInsets imageViewInsets = UIEdgeInsetsMake(0, titleLabelSize.width / 2, 0, - titleLabelSize.width / 2);
	UIEdgeInsets titleLabelInsets = UIEdgeInsetsMake(0, - imageViewSize.width / 2, 0, imageViewSize.width / 2);
	switch (direction) {
		case HTButtonEdgeDirectionHorizontal: {
			CGFloat imageViewDistance = (titleLabelSize.width / 2 + fabs(imageToTitleOffset / 2)) * (imageToTitleOffset > 0 ? 1 : - 1);
			CGFloat titleLabelDistance = (imageViewSize.width / 2 + fabs(imageToTitleOffset / 2)) * (imageToTitleOffset > 0 ? 1 : - 1);
			imageViewInsets.right += imageViewDistance;
			imageViewInsets.left -= imageViewDistance;
			titleLabelInsets.right -= titleLabelDistance;
			titleLabelInsets.left += titleLabelDistance;
			offsetContentSize.width += fabs(imageToTitleOffset);
		}
			break;
		case HTButtonEdgeDirectionVertical: {
			imageViewInsets.left = 0;
			imageViewInsets.right = - titleLabelSize.width;
			titleLabelInsets.left = - imageViewSize.width;
			titleLabelInsets.right = 0;
			
			CGFloat imageViewDistance = (titleLabelSize.height / 2 + fabs(imageToTitleOffset / 2)) * (imageToTitleOffset > 0 ? 1 : - 1);
			CGFloat titleLabelDistance = (imageViewSize.height / 2 + fabs(imageToTitleOffset / 2)) * (imageToTitleOffset > 0 ? 1 : - 1);
			imageViewInsets.bottom += imageViewDistance;
			imageViewInsets.top -= imageViewDistance;
			titleLabelInsets.bottom -= titleLabelDistance;
			titleLabelInsets.top += titleLabelDistance;
			offsetContentSize.height += fabs(imageToTitleOffset);
		}
			break;
	}
	self.imageEdgeInsets = imageViewInsets;
	self.titleEdgeInsets = titleLabelInsets;
	
	[self ht_setValue:[NSValue valueWithCGSize:offsetContentSize] forSelector:@selector(intrinsicContentSize)];
	[self invalidateIntrinsicContentSize];
}

- (CGSize)ht_sizeThatFits:(CGSize)size {
	return [self intrinsicContentSize];
}

- (CGSize)ht_intrinsicContentSize {
	CGSize originContentSize = [self ht_intrinsicContentSize];
	CGSize offsetContentSize = [[self ht_valueForSelector:@selector(intrinsicContentSize)] CGSizeValue];
	originContentSize.width += offsetContentSize.width;
	originContentSize.height += offsetContentSize.height;
	if (offsetContentSize.width <= 0 && offsetContentSize.height > 0) {
		CGSize imageViewSize = self.imageView.intrinsicContentSize;
		CGSize titleLabelSize = self.titleLabel.intrinsicContentSize;
		originContentSize.width = MAX(imageViewSize.width, titleLabelSize.width) + self.contentEdgeInsets.left + self.contentEdgeInsets.right;
		originContentSize.height = imageViewSize.height + titleLabelSize.height + offsetContentSize.height + self.contentEdgeInsets.top + self.contentEdgeInsets.bottom;
	}
	return originContentSize;
}

@end

