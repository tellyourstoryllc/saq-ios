//
//  ContactsViewController.m
//  groups
//
//  Created by Jim Young on 1/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "ContactsViewController.h"
#import "RHPerson.h"
#import "PNTableCell.h"
#import "AlertView.h"

@interface ContactsTableViewCell : PNTableCell
@property (nonatomic, strong) RHPerson* person;
@property (nonatomic, strong) PNLabel* nameLabel;
@property (nonatomic, strong) PNButton* addButton;
@end

@implementation ContactsTableViewCell
- (void)commonInit {
    self.backgroundColor = COLOR(purpleColor);

    self.nameLabel = [[PNLabel alloc] init];
    self.nameLabel.font = FONT_B(14);
    self.nameLabel.textColor = COLOR(whiteColor);
    [self addChild:self.nameLabel];

    self.addButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,40,40)];
    self.addButton.buttonColor = [UIColor clearColor];
    [self.addButton setBorderWithColor:COLOR(whiteColor) width:2];
    self.addButton.cornerRadius = 20;
    [self.addButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [self addChild:self.addButton];

}

- (void)setPerson:(RHPerson *)person {
    self.nameLabel.text = person.compositeName;
    self.nameLabel.text = self.nameLabel.text ?: person.emails.values.firstObject;
    self.nameLabel.text = self.nameLabel.text ?: person.phoneNumbers.values.firstObject;
    self.nameLabel.frame = CGRectZero;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    self.addButton.frame = CGRectSetOrigin(10, 5, self.addButton.frame);
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectSetMiddleLeft(CGRectGetMaxX(self.addButton.frame)+10, CGRectGetMidY(self.addButton.frame), self.nameLabel.frame);
    [super layoutSubviews];
}

@end

//

@interface ContactsViewController()<UITextFieldDelegate>

@property (nonatomic, strong) PNLabel* titleLabel;
@property (nonatomic, strong) PNTextField* textField;
@property (nonatomic, strong) RHAddressBook* addressBook;
@property (nonatomic, strong) PNButton* doneButton;

@property (nonatomic, strong) NSArray* peopleArray;
@property (nonatomic, strong) NSArray* filteredPeopleArray;
@property (nonatomic, strong) NSMutableArray* selectedPeopleArray;

@end

@implementation ContactsViewController

- (id)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = COLOR(purpleColor);
        self.addressBook = [[RHAddressBook alloc] init];
        self.selectedPeopleArray = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleLabel = [[PNLabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = COLOR(whiteColor);
    self.titleLabel.font = FONT_B(18);
    [self.view addSubview:self.titleLabel];
    self.titleLabel.text = @"Add people to group";

    self.textField = [[PNTextField alloc] init];
    self.textField.backgroundColor = COLOR(grayColor);
    self.textField.placeholder = @"Name, phone #, or email";
    self.textField.horizontalInset = 5;
    self.textField.delegate = self;
    [self.view addSubview:self.textField];

    self.doneButton = [[PNButton alloc] init];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.view addSubview:self.doneButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGRect b = self.view.bounds;
    CGFloat m = 10;

    [self.titleLabel sizeToFitTextWidth:b.size.width-2*m];
    self.titleLabel.frame = CGRectSetTopCenter(b.size.width/2, 20, self.titleLabel.frame);
    self.textField.frame = CGRectInset(CGRectMake(0,CGRectGetMaxY(self.titleLabel.frame),b.size.width,40),0,0);
    self.table.frame = CGRectMake(0,CGRectGetMaxY(self.textField.frame),b.size.width, 400);
}

- (void)viewDidAppear:(BOOL)animated {

    switch ([RHAddressBook authorizationStatus]) {
        case RHAuthorizationStatusNotDetermined:
            [self doAuthorization];
            break;

        case RHAuthorizationStatusAuthorized:
            self.peopleArray = [self.addressBook peopleOrderedByUsersPreference];
            self.filteredPeopleArray = self.peopleArray;
            [self.table reloadData];

        default:
            break;
    }
}

- (void)doAuthorization {
    [AlertView showWithTitle:@"Choose contacts to add" andMessage:@"Please allow access to contacts"
              withCompletion:^(NSInteger buttonIndex) {
                  [self.addressBook requestAuthorizationWithCompletion:^(bool granted, NSError *error) {
                      if (granted) {
                          self.peopleArray = [self.addressBook peopleOrderedByUsersPreference];
                          self.filteredPeopleArray = self.peopleArray;
                          [self.table reloadData];
                      } else {
                          [AlertView showWithTitle:@"Unable to access contacts" andMessage:@"Please add people by entering phone numbers or email addresses"];
                      }
                  }];
              }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredPeopleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.peopleArray.count > indexPath.row) {
        RHPerson* person = [self.filteredPeopleArray objectAtIndex:indexPath.row];
        ContactsTableViewCell* cell;
        cell = [self.table dequeueReusableCellWithIdentifier:@"contactCell"];
        if (!cell) {
            cell = [[ContactsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contactCell"];
        }
        cell.person = person;
        return cell;
    }

    return nil;
}

- (void)toggleSelection:(RHPerson*)person {
    if ([self.selectedPeopleArray containsObject:person]) {
        [self.selectedPeopleArray removeObject:person];
        if ([self.delegate respondsToSelector:@selector(deselectPerson:)]) {
            [self.delegate deselectPerson:person];
        }
    }
    else {
        [self.selectedPeopleArray addObject:person];
        if ([self.delegate respondsToSelector:@selector(selectPerson:)]) {
            [self.delegate selectPerson:person];
        }
    }

    self.textField.text = nil;
    [self.view endEditing:YES];
    [self filterByText:@""];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id person = [self.filteredPeopleArray objectAtIndex:indexPath.row];
    [self toggleSelection:person];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length > 0) {
        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }
    [self filterByText:newString];
    return YES;
}

- (void)filterByText:(NSString*)text {
    self.filteredPeopleArray = [self.peopleArray filteredArrayUsingBlock:^BOOL(id obj, NSDictionary *bindings) {
        RHPerson* person = (RHPerson*) obj;
        if ([person.compositeName isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", text]]) return YES;

        for (id email in person.emails.values) {
            if ([email isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", text]]) return YES;
        }

        for (id phone in person.phoneNumbers.values) {
            if ([phone isMatchedByRegex:[NSString stringWithFormat:@"(?i)%@", text]]) return YES;
        }

        return NO;
    }];
    [self.table reloadData];
}

@end
