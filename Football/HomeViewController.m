//
//  HomeViewController.m
//  Football
//
//  Created by Manoj Prasad on 06/11/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "HomeViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "CutomTableViewCell.h"

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableData *receivedData;
}
@property(nonatomic,strong)UITableView *listTableView;

@property(nonatomic,strong)NSMutableArray *footBallListArray;
@property(nonatomic,strong)NSMutableArray *arrayFromSQL;
@end

@implementation HomeViewController
@synthesize footBallListArray,arrayFromSQL;
@synthesize listTableView;

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createDataBase];
    
    footBallListArray = [[NSMutableArray alloc]initWithCapacity:0];
    arrayFromSQL = [[NSMutableArray alloc]initWithCapacity:0];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"loaded"])
    {
         [self GetFootballList];
    }
    else
    {
        [self FetchResultsFromServer];
    }
    
    UILabel *headingLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    headingLbl.text = @"Football";
    headingLbl.font = [UIFont fontWithName:@"Futura" size:25];
    headingLbl.backgroundColor = [UIColor clearColor];
    headingLbl.textColor = [UIColor blackColor];
    headingLbl.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:headingLbl];
    
    listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-44) style:UITableViewStylePlain];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    listTableView.separatorColor = [UIColor clearColor];
    listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    listTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:listTableView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}


-(void)createDataBase
{
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docpath = [path objectAtIndex:0];
        NSString *dirpath = [docpath stringByAppendingPathComponent:@"football.sqlite"];
        FMDatabase *database = [FMDatabase databaseWithPath:dirpath];
        [database open];
        [database executeUpdate:@"create table footballlist (hometeamname varchar, awayteamname varchar, hometeamgoals varchar, awayteamgoals varchar, status varchar, date varchar)"];
        [database close];
}

-(void)CreateValueInsertMethod
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docpath = [path objectAtIndex:0];
    NSString *dirpath = [docpath stringByAppendingPathComponent:@"football.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:dirpath];
    [database open];
    for (int i =0; i < [footBallListArray count]; i++)
    {
        NSDictionary *detailasDict = [footBallListArray objectAtIndex:i];
        [database executeUpdate:@"insert into footballlist (hometeamname,awayteamname, hometeamgoals, awayteamgoals,status,date) values (?,?,?,?,?,?)",[detailasDict objectForKey:@"homeTeamName"],[detailasDict objectForKey:@"awayTeamName"],[detailasDict objectForKey:@"goalsHomeTeam"],[detailasDict objectForKey:@"goalsAwayTeam"],[detailasDict objectForKey:@"status"],[detailasDict objectForKey:@"date"]];
    }
    [database close];
}

-(void)FetchResultsFromServer
{
    [footBallListArray removeAllObjects];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docpath = [path objectAtIndex:0];
    NSString *dirpath = [docpath stringByAppendingPathComponent:@"football.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:dirpath];
    [database open];
    database.logsErrors = YES;
    FMResultSet *resultSet1 = [database executeQuery:@"select * from footballlist"];
    while ([resultSet1 next])
    {
        NSMutableDictionary *receiveDictionary = [[NSMutableDictionary alloc]init];
        [receiveDictionary setObject:[resultSet1 stringForColumn:@"hometeamname"] forKey:@"homeTeamName"];
        [receiveDictionary setObject:[resultSet1 stringForColumn:@"awayteamname"] forKey:@"awayTeamName"];
        [receiveDictionary setObject:[resultSet1 stringForColumn:@"hometeamgoals"] forKey:@"goalsHomeTeam"];
        [receiveDictionary setObject:[resultSet1 stringForColumn:@"awayteamgoals"] forKey:@"goalsAwayTeam"];
        [receiveDictionary setObject:[resultSet1 stringForColumn:@"status"] forKey:@"status"];
        [receiveDictionary setObject:[resultSet1 stringForColumn:@"date"] forKey:@"date"];
        [footBallListArray addObject:receiveDictionary];
    }
    [listTableView reloadData];
    [database close];
}

-(void)GetFootballList
{
    NSURL *serverURL = [NSURL URLWithString:@"http://api.football-data.org/alpha/soccerseasons/398/fixtures"];
    NSURLRequest *request = [NSURLRequest requestWithURL:serverURL];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    receivedData = [[NSMutableData alloc]init];
    [conn start];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    receivedData = [[NSMutableData alloc] init];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    return nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(receivedData)
    {
        NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:receivedData options: NSJSONReadingMutableContainers error:&error];
        NSArray *fixtureArray = [dict objectForKey:@"fixtures"];
        
        for(NSDictionary *dics in fixtureArray)
        {
            NSMutableDictionary *mutDict = [[NSMutableDictionary alloc]init];
            [mutDict setObject:[dics objectForKey:@"homeTeamName"] forKey:@"homeTeamName"];
            [mutDict setObject:[dics objectForKey:@"awayTeamName"] forKey:@"awayTeamName"];
            [mutDict setObject:[[dics objectForKey:@"result"] objectForKey:@"goalsHomeTeam"] forKey:@"goalsHomeTeam"];
            [mutDict setObject:[[dics objectForKey:@"result"] objectForKey:@"goalsAwayTeam"] forKey:@"goalsAwayTeam"];
            [mutDict setObject:[dics objectForKey:@"status"] forKey:@"status"];
            [mutDict setObject:[dics objectForKey:@"date"] forKey:@"date"];
            [footBallListArray addObject:mutDict];
        }
        [listTableView reloadData];
        [self CreateValueInsertMethod];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"loaded"];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [footBallListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"football";
    
    CutomTableViewCell *cell = (CutomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    cell.containerView.center = cell.contentView.center;
    if(indexPath.row %2 == 0)
    {
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
    }
    else
    {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    NSDictionary *dict = [footBallListArray objectAtIndex:indexPath.row];
    
    cell.homeNameLbl.text = [dict objectForKey:@"homeTeamName"];
    cell.awayNameLbl.text = [dict objectForKey:@"awayTeamName"];
    cell.homeGoalLbl.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"goalsHomeTeam"]];
    cell.awayGoalLbl.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"goalsAwayTeam"]];
    cell.statusLbl.text = [dict objectForKey:@"status"];
    cell.dateLbl.text = [dict objectForKey:@"date"];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
