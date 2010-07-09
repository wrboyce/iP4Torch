//
//  iP4TorchAppDelegate.m
//  iP4Torch
//
//  Created by Will Boyce on 08/07/2010.
//  Copyright Will Boyce 2010. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are
//  met:
//
//  * Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials provided
//    with the distribution.
//  * Neither the name iP4Torch nor the names of it's contributors
//    may be used to endorse or promote products derived from
//    this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
//  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
//  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "iP4TorchAppDelegate.h"


@implementation iP4TorchAppDelegate

@synthesize window;
@synthesize captureDevice, captureVideoDataOutput, captureSession;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Find the first Flash capable Capture Device
	self.captureDevice = nil;
	NSArray *captureDevices = [AVCaptureDevice devices];
	for (int i = 0; i < [captureDevices count]; i++) {
		if ([[captureDevices objectAtIndex:i] hasTorch]) {
			self.captureDevice = [captureDevices objectAtIndex:i];
			break;
		}
	}
	
	// Setup the AVCaptureSession
	captureSession = [[AVCaptureSession alloc] init];
	[captureSession beginConfiguration];
	AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
	[captureSession addInput:videoInput];
	captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
	[captureVideoDataOutput setSampleBufferDelegate:self queue:dispatch_get_current_queue()];
	[captureSession addOutput:captureVideoDataOutput];
	[captureDevice lockForConfiguration:nil];
	[captureDevice setTorchMode:AVCaptureTorchModeOn];
	[captureSession commitConfiguration];
	[captureSession startRunning];
	
	// There much be a nicer way to set the StatusBarStyle
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    [window makeKeyAndVisible];
	return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[captureSession stopRunning];
	[captureDevice unlockForConfiguration];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	[captureDevice lockForConfiguration:nil];
	[captureDevice setTorchMode:AVCaptureTorchModeOn];
	[captureSession startRunning];
}


#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[captureSession release];
	[captureVideoDataOutput release];
	[captureDevice release];
    [window release];
    [super dealloc];
}

@end