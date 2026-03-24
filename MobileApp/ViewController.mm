//
//  ViewController.m
//  MobileApp
//
//  Created by kmgao on 2026/1/8.
//

#include <iostream>
#import "ViewController.h"
#import "objc/runtime.h"
#import "objc/objc.h"
#import "objc/message.h"
#import <UIKit/UIKit.h>
#import <CoreFoundation/CFRunLoop.h>
#import "MobileApp-Swift.h"
#include "MathLib.hpp"



@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    
}
-(void)doAction:(NSString*)name andID:(int)index;
@property(nonatomic,strong) UIView *alphaImageView;
@property(strong,atomic) UITableView  *tableView;
@property(strong,atomic) NSThread  *thread;
@property(strong,atomic) NetRunner *runner ;

@end

@implementation ViewController


-(void)timerRun{
    NSLog(@"timer 1 running.....");
}
-(void)timerRun2{
    NSLog(@"timer 2 running.....##");
}

-(void)excuteUpdate:(NSInteger)index{
    NSLog(@"function excute in new thread");
}



-(void)threadRun{
    NSLog(@"run loop 1.......");
    
//    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    
//    NSTimer *timer = [NSTimer timerWithTimeInterval:0 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
//    [[NSRunLoop currentRunLoop] addTimer: [NSTimer timerWithTimeInterval:2 target:self selector:@selector(timerRun2) userInfo:nil repeats:YES] forMode:NSDefaultRunLoopMode];
    
    
    
//    [[NSRunLoop currentRunLoop] performSelector:@selector(excuteUpdate:) target:self argument:nil order:1 modes:@[NSDefaultRunLoopMode]];
    
//    [[NSRunLoop currentRunLoop] performBlock:^{
//        NSLog(@"runloop perforBlock 1");
//    }];
//    [[NSRunLoop currentRunLoop] performBlock:^{
//        NSLog(@"runloop perforBlock 2");
//    }];
//    [[NSRunLoop currentRunLoop] performBlock:^{
//        NSLog(@"runloop perforBlock 3");
//    }];
//    
    
    
//    [[NSRunLoop currentRunLoop] run];
    
    
    CFRunLoopRef loopRef = CFRunLoopGetCurrent();
    CFRunLoopSourceContext sourceContext = {0};
    CFRunLoopSourceRef sourceRef = CFRunLoopSourceCreate(kCFAllocatorDefault,0,&sourceContext);
    CFRunLoopAddSource(loopRef, sourceRef, kCFRunLoopDefaultMode);
    
    CFRelease(sourceRef);
    
//    CFRunLoopObserverRef obserRef = CFRunLoopObserverCreate(NULL, kCFRunLoopEntry, YES, 0, NULL, NULL);
    CFRunLoopObserverRef obserRef = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopEntry, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"the runloopActivity state: %d",(int)activity);
    });
    
    CFRunLoopAddObserver(loopRef, obserRef, kCFRunLoopDefaultMode);
    
    CFRelease(obserRef);
    
    CFRunLoopRun();
    
    
    
    NSLog(@"### run loop 2.......");
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //oc call swift
//    self.runner = [[NetRunner alloc] init];
//    [self.runner startRun];
    
    NSError *error = NULL; 
    NetRunner *runer = [[NetRunner alloc] init];
    [runer power:12.1 error:&error];
    
    
    //oc Mixin Cpp
//    MathCalculator *m_calculator = new MathCalculator(12.1);
//    m_calculator->userSmartPointer();
//    delete m_calculator;
//    m_calculator = nullptr;
     
    
    
//    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadRun:) object:@[@12,@2,@23]];
    self.thread = [[NSThread alloc] initWithBlock:^{
        [self threadRun];
    }];
    
    [self.thread start];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:UIScreen.mainScreen.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    
//    NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode ];//UITrackingRunLoopMode //NSDefaultRunLoopMode
    
//    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
     
    
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    
    
    @autoreleasepool {
        UIButton *button;
        @autoreleasepool {
            objc_msgSend(self,sel_registerName("doAction:andID:"),@"objc",100);
            
            
            self.alphaImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
            self.alphaImageView.backgroundColor = [UIColor redColor];
            
    //        [self.view addSubview:self.alphaImageView];
            
            
            objc_msgSend(self, @selector(getViewID:widthType:),1,@"viewType");
            
            button = [[UIButton alloc] init];
            [self.view addSubview:button];
            [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake(100, 200, 60, 40);
            [button setTitle:@"OK" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }
        
 
        [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(100, 200, 60, 40);
        [button setTitle:@"OK" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    }
    
}

-(void)dealloc{

}

-(void)clickButton{
    [self  performSelector:@selector(runLoopAction) onThread:self.thread withObject:nil waitUntilDone:NO];
    
    [self.runner doAction];
    
    
}

-(void)runLoopAction{
    NSLog(@"runLoopAction run#################");
   
}


-(BOOL)getViewID:(int)id widthType:(NSString*)type{
    
    NSLog(@"the oc langure call by send message finish");
    
    return YES;
}




-(void)doAction:(NSString*)name andID:(int)index{
    NSLog(@"objc_msgSend sucessfull call %d",index);
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  150;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *itemTitle = @"";
    if(indexPath.row == 0){
        itemTitle = @"firstItem";
    }
    else{
        itemTitle = [NSString stringWithFormat:@"listItem-%d",indexPath.row];
    }
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"item-cell"];
    cell.frame = CGRectMake(0, 0, 640, 50);
    UILabel *label = [[UILabel alloc] init];
    label.frame = cell.frame;
    label.adjustsFontSizeToFitWidth = YES;
    label.center = cell.center;
    label.text = itemTitle;
    label.textColor = UIColor.redColor;
    [cell addSubview:label];
    
    
    return  cell;
    
}


@end
