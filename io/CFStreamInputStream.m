/*
 Copyright (c) 2009-2010, Stefan Reitshamer http://www.haystacksoftware.com
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the names of PhotoMinds LLC or Haystack Software, nor the names of 
 their contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */ 

#import "CFStreamInputStream.h"
#import "InputStreams.h"
#import "SetNSError.h"
#import "NSErrorCodes.h"
#import "CFStreamPair.h"

#define MY_BUF_SIZE (8192)
#define DEFAULT_READ_TIMEOUT_SECONDS (60)

@interface CFStreamInputStream (internal)
- (BOOL)open:(NSError **)error;
@end

@implementation CFStreamInputStream
- (id)initWithCFReadStream:(CFReadStreamRef)streamRef {
    if (self = [super init]) {
        readStream = streamRef;
        CFRetain(readStream);
    }
    return self;
}
- (void)dealloc {
    CFRelease(readStream);
    [super dealloc];
}

#pragma mark InputStream
- (NSInteger)read:(unsigned char *)buf bufferLength:(NSUInteger)bufferLength error:(NSError **)error {
    if (![self open:error]) {
        return -1;
    }
    CFIndex index = CFReadStreamRead(readStream, buf, bufferLength);
    if (index == -1) {
        if (error != NULL) {
            CFErrorRef err = CFReadStreamCopyError(readStream);
            if (err == NULL) {
                SETNSERROR(@"CFStreamPairErrorDomain", -1, @"unknown network error");
            } else {
                *error = [CFStreamPair NSErrorWithNetworkError:err];
                CFRelease(err);
            }
        }
        return -1;
    }
    return (NSInteger)index;
}
- (NSData *)slurp:(NSError **)error {
    return [InputStreams slurp:self error:error];
}
@end
@implementation CFStreamInputStream (internal)
- (BOOL)open:(NSError **)error {
    if (!isOpen) {
        if (!CFReadStreamOpen(readStream)) {
            if (error != NULL) {
                CFErrorRef err = CFReadStreamCopyError(readStream);
                if (err == NULL) {
                    SETNSERROR(@"CFStreamPairErrorDomain", -1, @"unknown network error");
                } else {
                    *error = [CFStreamPair NSErrorWithNetworkError:err];
                    CFRelease(err);
                }
            }
            return NO;
        }
        isOpen = YES;
    }
    return YES;
}
@end
