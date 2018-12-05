//
//  Created by Sanjay Madan on 1/11/17.
//  Copyright © 2017 mowglii.com. All rights reserved.
//

#import "PrefsAppearanceVC.h"
#import "Itsycal.h"
#import "HighlightPicker.h"
#import "MoVFLHelper.h"
#import "Themer.h"
#import "Sizer.h"
#import "MoUtils.h"
#import "IconGenerator.h"

@implementation PrefsAppearanceVC
{
    NSSegmentedControl *_iconKind;
    NSButton *_showMonth;
    NSButton *_showDayOfWeek;
    NSTextField *_dateTimeFormat;
    HighlightPicker *_highlight;
    NSButton *_showEventDots;
    NSButton *_showMonthOutline;
    NSButton *_showWeeks;
    NSButton *_showLocation;
    NSPopUpButton *_themePopup;
    NSButton *_bigger;
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView
{
    // View controller content view
    NSView *v = [NSView new];

    // Convenience function for making checkboxes.
    NSButton* (^chkbx)(NSString *) = ^NSButton* (NSString *title) {
        NSButton *chkbx = [NSButton checkboxWithTitle:title target:self action:nil];
        chkbx.translatesAutoresizingMaskIntoConstraints = NO;
        [v addSubview:chkbx];
        return chkbx;
    };

    NSButtonCell *prototype = [NSButtonCell new];
    [prototype setTitle:@"Watermelons"];
    [prototype setButtonType:NSRadioButton];
    
    _iconKind = [NSSegmentedControl new];
    _iconKind.translatesAutoresizingMaskIntoConstraints = NO;
    _iconKind.target = self;
    _iconKind.action = @selector(didChangeIconKind:);
    _iconKind.segmentStyle = NSSegmentStyleTexturedSquare;
    _iconKind.segmentCount = IconKindCount;

    for (NSInteger index = IconKindNone; index < IconKindCount; ++index) {
        if (index == IconKindNone) {
            [_iconKind setLabel:@"None" forSegment:index];
        }
        else {
            NSImage* image = makeIcon(index, [@(index) stringValue]);
            [_iconKind setImage:image forSegment:index];
        }
    }

    [v addSubview:_iconKind];
    
    // Checkboxes
    _showMonth = chkbx(NSLocalizedString(@"Show month in icon", @""));
    _showDayOfWeek = chkbx(NSLocalizedString(@"Show day of week in icon", @""));
    _showEventDots = chkbx(NSLocalizedString(@"Show event dots", @""));
    _showMonthOutline = chkbx(NSLocalizedString(@"Show month outline", @""));
    _showWeeks = chkbx(NSLocalizedString(@"Show calendar weeks", @""));
    _showLocation = chkbx(NSLocalizedString(@"Show event location", @""));
    _bigger = chkbx(NSLocalizedString(@"Use larger text", @""));

    // Datetime format text field
    _dateTimeFormat = [NSTextField textFieldWithString:@""];
    _dateTimeFormat.translatesAutoresizingMaskIntoConstraints = NO;
    _dateTimeFormat.placeholderString = NSLocalizedString(@"Datetime pattern", @"");
    _dateTimeFormat.refusesFirstResponder = YES;
    _dateTimeFormat.bezelStyle = NSTextFieldRoundedBezel;
    _dateTimeFormat.usesSingleLineMode = YES;
    _dateTimeFormat.delegate = self;
    [v addSubview:_dateTimeFormat];

    // Datetime help button
    NSButton *helpButton = [NSButton new];
    helpButton.title = @"";
    helpButton.translatesAutoresizingMaskIntoConstraints = false;
    helpButton.bezelStyle = NSHelpButtonBezelStyle;
    helpButton.target = self;
    helpButton.action = @selector(openHelpPage:);
    [v addSubview:helpButton];

    // Highlight control
    _highlight = [HighlightPicker new];
    _highlight.translatesAutoresizingMaskIntoConstraints = NO;
    _highlight.target = self;
    _highlight.action = @selector(didChangeHighlight:);
    [v addSubview:_highlight];

    // Theme label
    NSTextField *themeLabel = [NSTextField labelWithString:NSLocalizedString(@"Theme:", @"")];
    themeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [v addSubview:themeLabel];

    // Theme popup
    _themePopup = [NSPopUpButton new];
    _themePopup.translatesAutoresizingMaskIntoConstraints = NO;
    // On macOS 10.14+, there is a System theme preference in
    // addition to Light and Dark.
    if (OSVersionIsAtLeast(10, 14, 0)) {
        [_themePopup addItemWithTitle:NSLocalizedString(@"System", @"System theme name")];
    }
    [_themePopup addItemWithTitle:NSLocalizedString(@"Light", @"Light theme name")];
    [_themePopup addItemWithTitle:NSLocalizedString(@"Dark", @"Dark theme name")];
    // The tags will be used to bind the selected theme
    // preference to NSUserDefaults.
    if (OSVersionIsAtLeast(10, 14, 0)) {
        [_themePopup itemAtIndex:0].tag = 0; // System
        [_themePopup itemAtIndex:1].tag = 1; // Light
        [_themePopup itemAtIndex:2].tag = 2; // Dark
    }
    else {
        [_themePopup itemAtIndex:0].tag = 1; // Light
        [_themePopup itemAtIndex:1].tag = 2; // Dark
    }
    [v addSubview:_themePopup];

    MoVFLHelper *vfl = [[MoVFLHelper alloc] initWithSuperview:v metrics:@{@"m": @20} views:NSDictionaryOfVariableBindings(_bigger, _iconKind, _showMonth, _showDayOfWeek, _showEventDots, _showMonthOutline, _showWeeks, _showLocation, _dateTimeFormat, helpButton, _highlight, themeLabel, _themePopup)];
    [vfl :@"V:|-m-[_iconKind]-[_showMonth]-[_showDayOfWeek]-m-[_dateTimeFormat]-[_themePopup]-m-[_highlight]-m-[_showEventDots]-[_showMonthOutline]-[_showLocation]-[_showWeeks]-m-[_bigger]-m-|"];
    [vfl :@"H:|-m-[_iconKind]-(>=m)-|"];
    [vfl :@"H:|-m-[_showMonth]-(>=m)-|"];
    [vfl :@"H:|-m-[_showDayOfWeek]-(>=m)-|"];
    [vfl :@"H:|-m-[_dateTimeFormat]-[helpButton]-m-|" :NSLayoutFormatAlignAllCenterY];
    [vfl :@"H:|-m-[_highlight]-(>=m)-|"];
    [vfl :@"H:|-m-[themeLabel]-[_themePopup]-(>=m)-|" :NSLayoutFormatAlignAllFirstBaseline];
    [vfl :@"H:|-m-[_showEventDots]-(>=m)-|"];
    [vfl :@"H:|-m-[_showMonthOutline]-(>=m)-|"];
    [vfl :@"H:|-m-[_showWeeks]-(>=m)-|"];
    [vfl :@"H:|-m-[_showLocation]-(>=m)-|"];
    [vfl :@"H:|-m-[_bigger]-(>=m)-|"];

    self.view = v;
}

- (void)viewWillAppear
{
    [super viewWillAppear];

    // Bindings for icon preferences
    [_iconKind bind:@"selectedSegment" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kIconKind] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    [_showMonth bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowMonthInIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    [_showDayOfWeek bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowDayOfWeekInIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];

    // Binding for datetime format
    [_dateTimeFormat bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kClockFormat] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES), NSMultipleValuesPlaceholderBindingOption: _dateTimeFormat.placeholderString, NSNoSelectionPlaceholderBindingOption: _dateTimeFormat.placeholderString, NSNotApplicablePlaceholderBindingOption: _dateTimeFormat.placeholderString, NSNullPlaceholderBindingOption: _dateTimeFormat.placeholderString}];

    // Bindings for showEventDots preference
    [_showEventDots bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowEventDots] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    
    // Bindings for showMonthOutline preference
    [_showMonthOutline bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowMonthOutline] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];

    // Bindings for showWeeks preference
    [_showWeeks bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowWeeks] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];

    // Bindings for showLocation preference
    [_showLocation bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowLocation] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    
    // Bindings for highlight picker
    [_highlight bind:@"weekStartDOW" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kWeekStartDOW] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    [_highlight bind:@"selectedDOWs" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kHighlightedDOWs] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];

    // Bindings for theme
    [_themePopup bind:@"selectedTag" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kThemePreference] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    
    // Bindings for size
    [_bigger bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kSizePreference] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    
    // We don't want _dateTimeFormat to be first responder.
    [self.view.window makeFirstResponder:nil];
}

- (void)openHelpPage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://mowglii.com/itsycal/datetime.html"]];
}

- (void)didChangeHighlight:(HighlightPicker *)picker
{
    [[NSUserDefaults standardUserDefaults] setInteger:picker.selectedDOWs forKey:kHighlightedDOWs];
}

- (void)didChangeIconKind:(NSSegmentedControl *)control
{
    IconKind iconKind = control.selectedSegment;
    [[NSUserDefaults standardUserDefaults] setInteger:iconKind forKey:kIconKind];
    [_showMonth setEnabled:iconKind != IconKindNone];
    [_showDayOfWeek setEnabled:iconKind != IconKindNone];
}

@end
