
library(dplyr)
library(tidyr)

#The primary goal of this project is to design models for prediction of Total.
#Predicted spread will be evaluated by root mean squared error (RMSE).
#MSE is highly biased for higher values. RMSE is better in terms of reflecting performance when dealing with large error values. RMSE is more useful when lower residual values are preferred.

#Total=Home Points+Away Points


# All NBA games (matches) since 2004.
GAMES=read.csv(url("https://raw.githubusercontent.com/mattymo18/STOR-538-Project2-2021/master/Source-Data/games.csv"))

# All collected player details from the games mentioned in dataset GAMES. 
GAMES_DETAILS=read.csv(url("http://raw.githubusercontent.com/mattymo18/STOR-538-Project2-2021/master/Source-Data/games_details.csv"))

TEAMS=read.csv(url("https://raw.githubusercontent.com/mattymo18/STOR-538-Project2-2021/master/Source-Data/teams.csv"))


#Preview Datasets
head(filter(GAMES,GAME_ID==12000047)) %>% View
head(filter(GAMES_DETAILS,GAME_ID==12000047)) %>% View

### Transforming data to later add more variables.

# Eliminating unneeded fields.
SIMPLE_GAMES <- GAMES %>% 
  select(GAME_DATE_EST, GAME_ID, HOME_TEAM_ID, VISITOR_TEAM_ID, PTS_home, PTS_away) %>%
  mutate(SPREAD = PTS_home - PTS_away, Total = PTS_home + PTS_away)

# Aggregating all OREB for each game but for both teams.
SIMPLE_OREB <- GAMES_DETAILS %>%
  group_by(GAME_ID, TEAM_ID) %>% 
  summarize(OREB = sum(OREB, na.rm = TRUE), .groups="drop")


# Giving teams their respective OREB from the simple_oreb calculation.
# Changing capitalization on header and rearranging its order.
GAMES_OREB <- SIMPLE_GAMES %>%
  left_join(SIMPLE_OREB, by = c("GAME_ID", "HOME_TEAM_ID"="TEAM_ID")) %>%
  left_join(SIMPLE_OREB, by = c("GAME_ID", "VISITOR_TEAM_ID"="TEAM_ID")) %>%
  rename(OREB_HOME = OREB.x, OREB_AWAY = OREB.y, PTS_HOME = PTS_home, 
         PTS_AWAY = PTS_away, TOTAL = Total) %>%
  mutate(OREB = OREB_HOME + OREB_AWAY)

# Creating Team Names
TEAMNAMES <- TEAMS %>%
  select(TEAM_ID, CITY, NICKNAME) %>%
  unite(NAME, CITY, NICKNAME, sep = " ")


# Adding Team Names to the GAMES_OREB dataset.
GAMES_OREB_TEAM <- GAMES_OREB %>%
  left_join(TEAMNAMES, by = c("HOME_TEAM_ID"="TEAM_ID")) %>%
  left_join(TEAMNAMES, by = c("VISITOR_TEAM_ID"="TEAM_ID")) %>%
  rename(HOME_TEAM=NAME.x, AWAY_TEAM=NAME.y) %>%
  select(-HOME_TEAM_ID, -VISITOR_TEAM_ID)


# Creating division and adding full names to join with full data set later.
# URL : https://www.nba.com/teams
NAME <- c("Boston Celtics", "Brooklyn Nets", "New York Knicks", "Philadelphia 76ers", "Toronto Raptors", "Chicago Bulls", "Cleveland Cavaliers", "Detroit Pistons", "Indiana Pacers", "Milwaukee Bucks", "Atlanta Hawks", "Charlotte Hornets", "Miami Heat", "Orlando Magic", "Washington Wizards", "Denver Nuggets", "Minnesota Timberwolves", "Oklahoma City Thunder", "Portland Trail Blazers", "Utah Jazz", "Golden State Warriors", "Los Angeles Clippers", "Los Angeles Lakers", "Phoenix Suns", "Sacramento Kings", "Dallas Mavericks", "Houston Rockets", "Memphis Grizzlies", "New Orleans Pelicans", "San Antonio Spurs")
DIVISION <- c("Atlantic", "Atlantic", "Atlantic", "Atlantic", "Atlantic", "Central", "Central", "Central", "Central", "Central", "Southeast", "Southeast", "Southeast", "Southeast", "Southeast", "Northwest", "Northwest", "Northwest", "Northwest", "Northwest", "Pacific", "Pacific", "Pacific", "Pacific", "Pacific", "Southwest", "Southwest", "Southwest", "Southwest", "Southwest")
DIVISIONS <- data.frame(NAME, DIVISION)

# Adding divisions and reordering all fields.
GAMES_OREB_TEAM_DIV <- GAMES_OREB_TEAM %>%
  left_join(DIVISIONS, by = c("HOME_TEAM"="NAME")) %>%
  left_join(DIVISIONS, by = c("AWAY_TEAM"="NAME")) %>%
  rename(HOME_DIVISION = DIVISION.x, AWAY_DIVISION = DIVISION.y) %>%
  select(GAME_DATE_EST, HOME_TEAM, HOME_DIVISION, AWAY_TEAM, AWAY_DIVISION, everything()) %>%
  select(-GAME_ID)


# Simply looking at all the games that didn't have matching dates and thus game details when I performed the left-joins.
NA_VALUE_GAMES <- filter(if_any(everything(), is.na))


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



#### Using more 1000 trees instead of 500 to see if it improves (lowers) the RMSE.
rf_model2 <- randomForest(Total ~ .,data=predicting_data, importance=T, ntree=1000)

predictions_for_total_2 <- predict(rf_model2, newdata=final_data)
final_data$total_rf2 <- predictions_for_total_2

# New RMSE of 20.17991
sqrt(mean((final_data$True_Total - final_data$total_rf2)^2))
# MAE of 15.45186
# On average, I was never off by more than ~15 points.
mean(abs(final_data$True_Total - final_data$total_rf2))


