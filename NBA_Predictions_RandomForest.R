
library(dplyr)


#The primary goal of this project is to design models for prediction of three variables – Spread, Total, and OREB. Below you can find clear definitions of these three outcome variables.
#The variables, Spread, Total, and OREB will all be evaluated by root mean squared error (RMSE).
#MSE is highly biased for higher values. RMSE is better in terms of reflecting performance when dealing with large error values. RMSE is more useful when lower residual values are preferred.
#It is imperative that you follow these specifications. Your group will be making predictions of the three variables for all NBA games between April 10 and April 30, inclusively.

#Total=Home Points+Away Points



#### * I 


# All NBA games (matches) since 2004.
GAMES=read.csv(url("https://raw.githubusercontent.com/mattymo18/STOR-538-Project2-2021/master/Source-Data/games.csv"))

# All collected player details from the games mentioned in dataset GAMES. 
# Expect more rows becauseeach game id will have the opponent team id also listed with it (apart from each player's details).
GAMES_DETAILS=read.csv(url("http://raw.githubusercontent.com/mattymo18/STOR-538-Project2-2021/master/Source-Data/games_details.csv"))

TEAMS=read.csv(url("https://raw.githubusercontent.com/mattymo18/STOR-538-Project2-2021/master/Source-Data/teams.csv"))


#Preview Datasets
head(filter(GAMES,GAME_ID==12000047)) %>% View
head(filter(GAMES_DETAILS,GAME_ID==12000047)) %>% View


### Mutating data into a way that is usable.

#Simplify our Games Data (it has a lot -- almost too many-- variables)
SIMPLE_GAMES <- GAMES %>% #can filter out games by year (new data may be more relevant)
  select(GAME_DATE_EST,GAME_ID,HOME_TEAM_ID,VISITOR_TEAM_ID,PTS_home,PTS_away) %>% #can add additional variables we deem necessary for predictions from the original GAMES dataset 
  mutate(Spread=PTS_home-PTS_away,Total=PTS_home+PTS_away)


#Obtain Aggregated OREB from Player Level Statistics
OREB <- GAMES_DETAILS %>%
  select(TEAM_ABBREVIATION,GAME_ID,TEAM_ID,OREB) %>%
  group_by(TEAM_ABBREVIATION,GAME_ID,TEAM_ID) %>%
  summarize(OREB=sum(OREB,na.rm=T),.groups="drop")

# left_join(SG, select(OREB, columns you want), by = "join on these columns inside both but you want to drop inside the second df")

#Merging Offensive Rebounds Into Game Data
SIMPLE_GAMES_OREB <- left_join(SIMPLE_GAMES,select(OREB,-TEAM_ABBREVIATION),by=c("GAME_ID","HOME_TEAM_ID"="TEAM_ID")) %>%
  rename(OREB_home=OREB) %>%
  left_join(select(OREB,-TEAM_ABBREVIATION),by=c("GAME_ID","VISITOR_TEAM_ID"="TEAM_ID")) %>%
  rename(OREB_away=OREB) %>%
  mutate(OREB=OREB_home+OREB_away) # adding  our home and away OREB variables for a total OREB.



#Creating Home Team and Away Team Variables and putting names inside NAME column.
#Unite: concatenates characters and places them into a new variable.
ALL_TEAMS <- TEAMS %>%
  select(TEAM_ID,CITY,NICKNAME) %>%
  tidyr::unite(NAME,CITY,NICKNAME,sep=" ")



#Merging Team Name into original data
SIMPLE_GAMES_OREB_TEAM <- left_join(SIMPLE_GAMES_OREB,ALL_TEAMS,by=c("HOME_TEAM_ID"="TEAM_ID")) %>%
  rename("Home Team"=NAME) %>%
  left_join(ALL_TEAMS,by=c("VISITOR_TEAM_ID"="TEAM_ID")) %>%
  rename("Away Team"=NAME) %>%
  select(GAME_DATE_EST,"Home Team","Away Team",everything()) %>%
  select(-GAME_ID,-HOME_TEAM_ID,-VISITOR_TEAM_ID)



#Creating division and adding full names to join with full data set later.
NAME <- c("Boston Celics", "Brooklyn Nets", "New York Knicks", "Philadelphia 76ers", "Toronto Raptors", "Chicago Bulls", "Cleveland Cavaliers", "Detroit Pistons", "Indiana Pacers", "Milwaukee Bucks", "Atlanta Hawks", "Charlotte Hornets", "Miami Heat", "Orlando Magic", "Washington Wizards", "Denver Nuggets", "Minnesota Timberwolves", "Oklahoma City Thunder", "Portland Trail Blazers", "Utah Jazz", "Golden State Warriors", "Los Angeles Clippers", "Los Angeles Lakers", "Phoenix Suns", "Sacramento Kings", "Dallas Mavericks", "Houston Rockets", "Memphis Grizzlies", "New Orleans Pelicans", "San Antonio Spurs")
DIVISION <- c("Atlantic", "Atlantic", "Atlantic", "Atlantic", "Atlantic", "Central", "Central", "Central", "Central", "Central", "Southeast", "Southeast", "Southeast", "Southeast", "Southeast", "Northwest", "Northwest", "Northwest", "Northwest", "Northwest", "Pacific", "Pacific", "Pacific", "Pacific", "Pacific", "Southwest", "Southwest", "Southwest", "Southwest", "Southwest")
DIVISIONS <- data.frame(NAME, DIVISION)



#Adding divisions to both TEAMS and SIMPLE_GAMES_OREB_TEAM
# URL : https://www.nba.com/teams
ALL_TEAMS_DIV <- left_join(ALL_TEAMS,DIVISIONS,by=c("NAME"))

SIMPLE_GAMES_OREB_DIV = 
  left_join(SIMPLE_GAMES_OREB_TEAM, ALL_TEAMS_DIV, by = c("Home Team" = "NAME")) %>%
  rename("Home_Division"="DIVISION") %>%
  left_join(ALL_TEAMS_DIV,by=c("Away Team"="NAME")) %>%
  rename("Away_Division"="DIVISION") %>%
  select(-TEAM_ID.x, -TEAM_ID.y) %>%
  select(GAME_DATE_EST, `Home Team`, Home_Division, `Away Team`, Away_Division, everything())

# Exporting for teammates:
write.csv(TURNIN, "C:\\Users\\ap3340\\Documents\\YOUR_STUFF\\Data_Analyst\\R_PROJECTS\\Datasets\\pre_final_data.csv")




##### Beginning the Random Forest to predict Spread in our case.

# Importing added variables that teammates included.
predicting_data <- read.csv("final_data_bigger_version.csv") %>%
  select(-c(1,2,Game_Date, Season, Points_Home, Points_Away, Home_Advantage, OReb_Home, OReb_Away, Spread, OReb)) %>%
  tidyr::drop_na()

set.seed(0)
library(randomForest)

rf_model <- randomForest(Total ~ .,data=predicting_data, importance = TRUE)


# DOING THE ACTUAL PREDICTIONS WITH THE NEW DATA
# this new data has same inputs as the most recent team's from most recent years from previous dataset.
# Importing the games I want to predict on. This dataset has the actual scores that took place, as well.
final_data <- read.csv("finalpredictions_with_variables.csv") %>%
  select(-c(Game_Date, Season))

# Doing the predictions
predictions_for_total <- predict(rf_model, newdata=final_data)


final_data$total <- predictions_for_total

# Getting the root mean square error.
sqrt( mean((final_data$True_Total - final_data$total)^2) ) # rmse = 20.11537.

