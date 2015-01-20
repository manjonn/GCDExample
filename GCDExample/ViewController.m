//
//  ViewController.m
//  GCDExample
//
//  Created by Manjula Jonnalagadda on 1/19/15.
//  Copyright (c) 2015 Manjula Jonnalagadda. All rights reserved.
//

#import "ViewController.h"
#import "WeatheTableViewCell.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<UITableViewDataSource>{
    
    NSMutableArray *_weathers;
    dispatch_queue_t serialqueue;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    _weathers=[NSMutableArray array];
    [self weatherLocations];
    serialqueue=dispatch_queue_create("com.tpi.test", 0);
    dispatch_async(serialqueue, ^{
        int i=0;
        i++;
    });
    dispatch_async(serialqueue, ^{
        int j=0;
        j++;
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        int i=0;
        i++;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Do radom stuff");
    });
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)weatherLocations{
    
    CLGeocoder *geocoder=[CLGeocoder new];
    
    NSArray *cities=@[@"Mountain View, CA",@"Palo Alto, CA",@"Redwood City, CA"];
    NSMutableArray *citylatLong=[NSMutableArray array];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;   // make it a serial queue

    NSOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self weathersForCities:citylatLong];
    }];

        for (NSString *city in cities) {
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                
                [geocoder geocodeAddressString:city completionHandler:^(NSArray *placemarks, NSError *error) {
                    if (error) {
                        NSLog(@"%@", error);
                    } else if ([placemarks count] > 0) {
                        CLPlacemark *placeMark = placemarks.firstObject;
                        
                        [citylatLong addObject:placeMark];
                    }
                    dispatch_semaphore_signal(semaphore);
                }];
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }];
            
            [completionOperation addDependency:operation];
            [queue addOperation:operation];
        }
    [[NSOperationQueue mainQueue]addOperation:completionOperation];
    
}

-(void)weathersForCities:(NSArray *)cities{
    
    NSLog(@"Yay");
    __weak typeof(self) weakself=self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_t group = dispatch_group_create();
        for (CLPlacemark *placeMark in cities) {
            NSString *urlString=[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f",placeMark.location.coordinate.latitude,placeMark.location.coordinate.longitude];
            dispatch_group_enter(group);
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                typeof(self) strongself=weakself;
        
                NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                dispatch_sync(serialqueue, ^{
                    [strongself->_weathers addObject:dict];
                    
                });
                dispatch_group_leave(group);
                
            }]resume];
        
        }
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
        });
    
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _weathers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WeatheTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *weather=_weathers[indexPath.row];
    [cell setCity:weather[@"name"] minTemp:[weather[@"main"][@"temp_min"] stringValue] maxTemp:[weather[@"main"][@"temp_max"] stringValue]];
    return cell;
    
    
}

@end
