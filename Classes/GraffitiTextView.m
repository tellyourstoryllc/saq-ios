//
//  GraffitiTextView.m
//
//
//  Created by Jim Young on 3/8/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "GraffitiTextView.h"

@interface GraffitiTextView()<UITextViewDelegate>

@property (nonatomic, strong) NSArray* fonts;

@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGRect panStartFrame;

@property (nonatomic, assign) CGFloat pinchStartSize;

@end

@implementation GraffitiTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.fonts = @[@"BebasNeueBold", @"Roboto-Light", @"LindenHill", @"Minecrafter-3", @"GrandHotel-Regular", @"OstrichSans-Bold", @"Blackout-Sunrise"];
        self.currentFont = [UIFont fontWithName:[self.fonts objectAtIndex:0] size:50];;

        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.scrollEnabled = NO;
        _textView.font = self.currentFont;
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.keyboardType = UIKeyboardTypeTwitter; // UIKeyboardTypeDefault;
        _textView.contentInset = UIEdgeInsetsMake(20, 0, 20, 0);
        _textView.spellCheckingType = UITextSpellCheckingTypeNo;

        _textView.layer.shadowRadius = 1;
        _textView.layer.shadowOffset = CGSizeMake(0.5,-1);
        _textView.layer.shadowOpacity = 0.8;

        [self addSubview:_textView];

        UIPanGestureRecognizer *gsr = [[UIPanGestureRecognizer alloc] init];
        [gsr addTarget:self action:@selector(panText:)];
        [_textView addGestureRecognizer:gsr];

        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] init];
        [pinch addTarget:self action:@selector(pinchText:)];
        [_textView addGestureRecognizer:pinch];

    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    if (CGRectIsEmpty(_textView.frame) && !CGRectIsEmpty(self.frame)) {
        CGRect initialFrame = CGRectInset(CGRectMake(0,
                                                     self.verticalOffset,
                                                     self.frame.size.width,
                                                     self.frame.size.height),0,4);
        _textView.frame = initialFrame;
    }
}

- (void)setActive:(BOOL)active {
    if (active && !self.textView.text.length) {
        [self.textView becomeFirstResponder];
    }
    else {
        [self.textView resignFirstResponder];
    }

    self.fontButton.hidden = active ? (self.textView.text.length == 0) : YES;
}

- (void)setColor:(UIColor*)color {
    _textView.textColor = color;
    _textView.layer.shadowColor = [[color complement] CGColor];
}

- (void)setFontSize:(CGFloat)fontSize {
    self.textView.font = [self.textView.font fontWithSize:fontSize];
    self.currentFont = self.textView.font;
}

- (void)cycleFont {
    int nextIndex = (self.currentFontIndex+1) % self.fonts.count;
    self.currentFontIndex = nextIndex;
    self.currentFont = [UIFont fontWithName:self.fonts[nextIndex] size:self.textView.font.pointSize];
    self.textView.font = self.currentFont;
}

- (void)clear {
    self.textView.text = nil;
}

- (void)panText:(UIPanGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(graffitiTextViewWillBeginMovingText)])
            [self.delegate graffitiTextViewWillBeginMovingText];

        self.panStartFrame = _textView.frame;
        self.panStartPoint = [gesture translationInView:self];
        [_textView resignFirstResponder];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(graffitiTextViewDidEndMovingText)])
            [self.delegate graffitiTextViewDidEndMovingText];
    }
    else {
        CGPoint xlation = [gesture translationInView:self];
        CGFloat dx = xlation.x - self.panStartPoint.x;
        CGFloat dy = xlation.y - self.panStartPoint.y;

        _textView.frame = CGRectSetOrigin(self.panStartFrame.origin.x+dx,
                                      self.panStartFrame.origin.y+dy,
                                      _textView.frame);
    }
}

- (void)pinchText:(UIPinchGestureRecognizer*)recognizer {

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(graffitiTextViewWillBeginMovingText)])
            [self.delegate graffitiTextViewWillBeginMovingText];

        self.pinchStartSize = _textView.font.pointSize;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat newSize = self.pinchStartSize*recognizer.scale;
        newSize = MIN(200, newSize);
        newSize = MAX(8, newSize);
        _textView.font = [_textView.font fontWithSize:newSize];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(graffitiTextViewDidEndMovingText)])
            [self.delegate graffitiTextViewDidEndMovingText];
    }

}

#pragma UITextViewDelegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if (!range.length && !range.location && !text.length) {
        [textView resignFirstResponder];
        return NO;
    }

    switch ([text characterAtIndex:(text.length-1) ]) {
        case '\n':
        case '\r':
            [textView resignFirstResponder];
            return NO;
    }

    NSString* newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    self.fontButton.hidden = newText.length == 0;
    return YES;
}

@end
