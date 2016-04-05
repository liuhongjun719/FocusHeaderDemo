//
//  FocusCell.m
//  FocusHeaderDemo
//
//  Created by 123456 on 16/4/5.
//  Copyright © 2016年 123456. All rights reserved.
//

#import "FocusCell.h"

@implementation FocusCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)setImageViewWithImageName:(NSString *)imageName {
    self.focusImageView.image = [UIImage imageNamed:imageName];
}
@end
