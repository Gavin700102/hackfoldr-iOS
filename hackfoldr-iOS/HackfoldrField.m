//
//  HackfoldrField.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2014/6/22.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "HackfoldrField.h"

typedef NS_ENUM(NSUInteger, FieldType) {
    FieldType_URL = 0,
    FieldType_Title,
    FieldType_Foldrexpand,
    FieldType_Label
};

@interface HackfoldrField () {
    NSString *_urlString;
    NSString *_labelString;
}
@end

@implementation HackfoldrField

- (instancetype)init {
    if (self = [super init]) {
        _subFields = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithFieldArray:(NSArray *)fields
{
    self = [self init];
    if (!self) {
        return nil;
    }

    if (!fields) {
        return self;
    }

    [fields enumerateObjectsUsingBlock:^(NSString *field, NSUInteger idx, BOOL *stop) {
        switch (idx) {
            case FieldType_URL:
                self.urlString = field;
                break;
            case FieldType_Title:
                self.name = field;
                break;
            case FieldType_Foldrexpand:
                self.actions = field;
                break;
            case FieldType_Label:
                self.labelString = field;
                break;
            default:
                break;
        }
    }];
    // hackfoldr 2.0 rule
    self.isCommentLine = [self isCommentLineWithFieldArray:fields];

    return self;
}

- (BOOL)isCommentLineWithFieldArray:(NSArray *)fields
{
    __block BOOL isComment = NO;
    [fields enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *field = obj;
            [field enumerateSubstringsInRange:NSMakeRange(0, field.length)
                                      options:NSStringEnumerationByComposedCharacterSequences
                                   usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
            {
                // only read first one
                *stop = YES;

                if ([substring isEqualToString:@"#"]) {
                    isComment = YES;
                }
            }];
        }
    }];
    return isComment;
}

#pragma mark - Setter and Getter

- (BOOL)isEmpty
{
    if (!self.urlString && !self.name && !self.actions) {
        return YES;
    }

    if (self.urlString.length == 0 && self.name.length == 0 && self.actions.length == 0) {
        return YES;
    }

    return NO;
}

- (void)setUrlString:(NSString *)aURLString
{
    NSString *cleanString = [aURLString stringByReplacingOccurrencesOfString:@" " withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    _urlString = cleanString;

    [self setIsSubItemWithURLString:aURLString];
}

- (NSString *)urlString
{
    return _urlString;
}

- (void)setIsSubItemWithURLString:(NSString *)aURLString
{
    if (!aURLString || aURLString.length == 0) {
        return;
    }

    // hackfoldr 2.0 rule, default is subItem
    self.isSubItem = YES;
    // While first string is space, this HackfoldrField is subItem
    [aURLString enumerateSubstringsInRange:NSMakeRange(0, aURLString.length)
                                   options:NSStringEnumerationByComposedCharacterSequences
                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
    {
        if ([substring isEqualToString:@" "]) {
            self.isSubItem = YES;
            *stop = YES;
        }
        // hackfoldr 2.0 rule
        if ([substring isEqualToString:@"<"]) {
            self.isSubItem = NO;
            *stop = YES;
        }
    }];
}

- (void)setLabelString:(NSString *)labelString
{
    if (labelString.length == 0) {
        _labelString = labelString;
        return;
    }

    __block NSString *labelColorString = nil;
    __block NSMutableString *realLabelString = [NSMutableString string];
    // Separate by space
    // ex: red LabelString
    [[[labelString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
      filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]] enumerateObjectsUsingBlock:^(NSString *subString, NSUInteger idx, BOOL *stop)
    {
        if (idx == 0) {
            labelColorString = subString;
        } else {
            [realLabelString appendString:subString];
        }
    }];

    if ([self updateLabelColorByString:labelColorString]) {
        _labelString = realLabelString;
        return;
    }

    // Separate by :
    // ex: LabelString:important
    [[[labelString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]]
      filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]] enumerateObjectsUsingBlock:^(NSString *subString, NSUInteger idx, BOOL *stop)
     {
         if (idx == 0) {
             [realLabelString appendString:subString];
         } else {
             labelColorString = subString;
         }
     }];

    if ([self updateLabelColorByString:labelColorString]) {
        _labelString = realLabelString;
        return;
    }
    _labelString = labelString;
}

- (NSString *)labelString
{
    return _labelString;
}

- (BOOL)updateLabelColorByString:(NSString *)colorString
{
    NSLog(@"colorString:%@", colorString);
    NSDictionary *colorTable = @{ @"blue" : [UIColor blueColor],
                                 };
    self.labelColor = colorTable[colorString];
    return (self.labelColor != nil);
}

#pragma mark - DEBUG

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];

    [description appendFormat:@"index:%ld ", (long)self.index];
    if (self.name) {
        [description appendFormat:@"name: %@ ", self.name];
    }
    if (self.urlString) {
        [description appendFormat:@"urlString: %@ ", self.urlString];
    }
    if (self.actions) {
        [description appendFormat:@"actions: %@ ", self.actions];
    }

    [description appendFormat:@"isSubItem: %@ ", self.isSubItem ? @"YES" : @"NO"];
    [description appendFormat:@"isCommentLine: %@", self.isCommentLine ? @"YES" : @"NO"];

    if (self.subFields.count > 0) {
        [description appendFormat:@"subFields: %@ ", self.subFields];
    }

    if (self.labelString) {
        [description appendFormat:@"labelString: %@ ", self.labelString];
    }

    if (self.labelColor) {
        [description appendFormat:@"labelColor: %@ ", self.labelColor];
    }

    return description;
}

@end
