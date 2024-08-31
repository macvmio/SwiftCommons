//
// Copyright 2024 Marcin Iwanicki and contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "ContainerException.h"

NSString* const CSContainerExceptionTypeKey = @"SCContainerExceptionTypeKey";
NSString* const CSContainerExceptionNameKey = @"SCContainerExceptionNameKey";

@implementation ContainerException

+ (void)raiseWithReason:(NSString *)reason type:(NSString *)type name:(nullable NSString *)name {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        CSContainerExceptionTypeKey: type
    }];
    if (name) {
        userInfo[CSContainerExceptionNameKey] = name;
    }
    @throw [NSException exceptionWithName:@"SCBasicObjc.Exception"
                                   reason:reason
                                 userInfo:userInfo];
}

+ (void)catchException:(__attribute__((noescape)) void (^)(void))operation 
             withError:(NSError **)error {
    @try {
        operation();
    }
    @catch (NSException *exception) {
        if (error) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
                NSLocalizedDescriptionKey: exception.reason,
                NSLocalizedFailureReasonErrorKey: exception.name,
                CSContainerExceptionTypeKey: exception.userInfo[CSContainerExceptionTypeKey]
            }];
            NSString *name = exception.userInfo[CSContainerExceptionNameKey];
            if (name) {
                userInfo[CSContainerExceptionNameKey] = name;
            }
            *error = [NSError errorWithDomain:@"SCBasicObjc.Exception"
                                         code:1
                                     userInfo:userInfo];
        }
    }
}

@end
