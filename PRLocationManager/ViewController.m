//
//  ViewController.m
//  PRLocationManager
//
//  Created by huashuda on 2018/9/3.
//  Copyright © 2018年 huashuda. All rights reserved.
//

#import "ViewController.h"
#import "PRLocationManager.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)startLocationBtn:(id)sender {
    self.resultLabel.text = @"定位中...";
    [[PRLocationManager shareManager] locationStartSuccess:^(CLLocation *location, CLPlacemark *placemark) {
        
        // 获取城市
        NSString *city = placemark.locality;
        if (!city) {
            // 四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
            city = placemark.administrativeArea;
        }
        NSLog(@"city:%@",city);
        self.resultLabel.text = [NSString stringWithFormat:@"定位成功:%@",city];
    } faile:^(NSError *error) {
        if (error) {
            if (error.code == 2) {
                self.resultLabel.text = @"网络状态不好，请重试";
                NSLog(@"网络状态不好，请重试");
            } else {
                self.resultLabel.text = [NSString stringWithFormat:@"查询错误 = %@", error];
            }
        } else {
            self.resultLabel.text = @"查询失败，没有结果";
        }
    }];
    [PRLocationManager shareManager].currentAuthStatus = ^(BOOL isEnableLocation) {
        if (isEnableLocation) {
            self.resultLabel.text = @"当前权限，可以定位";
        } else {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"定位失败" message:@"请前往设置，打开定位权限" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                //
            }];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [PRLocationManager openLocationService];
            }];
            [alertVC addAction:cancelAction];
            [alertVC addAction:sureAction];
            [self presentViewController:alertVC animated:YES completion:nil];
            
            self.resultLabel.text = @"当前权限，不能定位，请打开权限";
        }
    };
}
- (IBAction)endLocationBtn:(id)sender {
    self.resultLabel.text = @"定位Demo";
    [[PRLocationManager shareManager] stopLocation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
