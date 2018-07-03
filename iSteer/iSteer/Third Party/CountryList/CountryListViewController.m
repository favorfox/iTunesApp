//
//  CountryListViewController.m
//  Country List
//
//  Created by Pradyumna Doddala on 18/12/13.
//  Copyright (c) 2013 Pradyumna Doddala. All rights reserved.
//

#import "CountryListViewController.h"
#import "CountryListDataSource.h"
#import "CountryCell.h"

@interface CountryListViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) NSArray *dataRows;
@property (strong, nonatomic) NSMutableArray *filteredTableData;

@end

@implementation CountryListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil delegate:(id)delegate
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        // Custom initialization
        _delegate = delegate;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CountryPickerTableCell" bundle:nil] forCellReuseIdentifier:@"CountryPickerTableCell"];
    
    CountryListDataSource *dataSource = [[CountryListDataSource alloc] init];
    _dataRows = [dataSource countries];
    [_tableView reloadData];
    
    self.filteredTableData = [[NSMutableArray alloc] init];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = false;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.barStyle = UIBarStyleDefault;
//    self.searchController.searchBar.barTintColor = [UIColor ];
    self.definesPresentationContext = YES;
    _tableView.tableHeaderView = self.searchController.searchBar;

    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.searchController.active && ![self.searchController.searchBar.text  isEqual: @""]) {
        return self.filteredTableData.count;
    }
    
    return [self.dataRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    CountryPickerTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CountryPickerTableCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CountryPickerTableCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    if(self.searchController.active && ![self.searchController.searchBar.text  isEqual: @""]) {
        cell.lblCountryName.text = [[self.filteredTableData objectAtIndex:indexPath.row] valueForKey:kCountryName];
        cell.lblCountryCode.text = [[self.filteredTableData objectAtIndex:indexPath.row] valueForKey:kCountryCallingCode];
    }
    else {
        cell.lblCountryName.text = [[_dataRows objectAtIndex:indexPath.row] valueForKey:kCountryName];
        cell.lblCountryCode.text = [[_dataRows objectAtIndex:indexPath.row] valueForKey:kCountryCallingCode];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(didSelectCountry:)]) {
        
        if(self.searchController.active && ![self.searchController.searchBar.text  isEqual: @""]) {
            [self.delegate didSelectCountry:[self.filteredTableData objectAtIndex:[_tableView indexPathForSelectedRow].row]];
            self.searchController.active = false;
        }
        else {
            [self.delegate didSelectCountry:[_dataRows objectAtIndex:[_tableView indexPathForSelectedRow].row]];
        }
        [self dismissViewControllerAnimated:true completion:NULL];
    } else {
        NSLog(@"CountryListView Delegate : didSelectCountry not implemented");
    }
}


#pragma mark -

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.filteredTableData removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@",searchController.searchBar.text];
    NSArray *filter = [_dataRows filteredArrayUsingPredicate:predicate];
    
    self.filteredTableData = [NSMutableArray arrayWithArray:filter];
    
    [self.tableView reloadData];
}

#pragma mark Actions

- (IBAction)done:(id)sender
{
    if ([_delegate respondsToSelector:@selector(didSelectCountry:)]) {
        [self.delegate didSelectCountry:[_dataRows objectAtIndex:[_tableView indexPathForSelectedRow].row]];
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        NSLog(@"CountryListView Delegate : didSelectCountry not implemented");
    }
}

@end
