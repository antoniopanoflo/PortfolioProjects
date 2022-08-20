# Data set for all pre-season 2013 football games.
NFL2013 <- read.csv('https://raw.githubusercontent.com/Carolina-Data-Challenge/datasets/main/FootballDatasets/NFL/CumulativeStats/nfl2013stats.csv')


library(dplyr)
library(ggplot2)
library(stringr)

# Here, we will get rid of the duplicates by keeping only one side of 
# the ties (one game only) and by sub-setting the winners out and only keeping the winners. 
# Creating a spread, dropping the one variable that defense doesn't have, and removing all NAs.
# I think Thirddownpctoff/def means how often they got to third down out of the plays they had.
# Removing % from string in variables: ThirdDownPctOff & ThirdDownPctDef
# and converting to double to divide by 100 so as to still represent 
# percentage in numerical form.
NFL2013.Final <- NFL2013 %>%
  filter(ScoreOff >= ScoreDef) %>%
  #filter(!row_number() %in% c(168)) %>%
  mutate(Spread = ScoreOff - ScoreDef,
         ThirdDownPctOff = as.double(substring(ThirdDownPctOff,1, nchar(ThirdDownPctOff)-1)),
         ThirdDownPctDef = as.double(substring(ThirdDownPctDef,1, nchar(ThirdDownPctDef)-1)),
         across(c(ThirdDownPctOff, ThirdDownPctDef), ~ ./100)) %>%
  select(-PuntAvgOff) %>%
  tidyr::drop_na()


# Noticing that the Denver Broncos played great the entire season. 
# Raises questions about their consistent performance.
ggplot(NFL2013.Final, aes(x=TeamName, y=ScoreOff, fill = TeamName)) + 
  geom_boxplot() +
  coord_flip() + 
  theme(legend.position = "none") + labs(y= "2013 Score Data", x= "Teams" ) +
  geom_point(stat="summary", fun=mean, shape=15, size=1.5)

#_______________________________________________________________________________

# Considering how the Broncos played so well but the Seahawks won the superbowl later on, 
# we test if the seahawks played abnormally well (sleep, performance-enhancing drugs).
# Some games only had broncos on defense so in order to not leave out those scores, 
# we create an entire vector where we merge both of them.

SeahawksOff <- filter(NFL2013.Final, TeamName == "Seattle Seahawks") %>%
  mutate(SeahawkScores = ScoreOff)
SeahawksDef <- filter(NFL2013.Final, Opponent == "Seattle Seahawks") %>%
  mutate(SeahawkScores = ScoreDef)

# Note that due to smaller sample size, this t-test will 
# have lower power in providing correct significance. 
# Checking at least resemblance of normality.
hist(SeahawkGameScores)


SeahawkGameScores <- c(SeahawksDef$SeahawkScores, SeahawksOff$SeahawkScores)
SB2014Score <- 43

# Is there evidence to suggest that our data's true mean is less than 43? left-tailed.
# null: superbowl seahawks score; 43.
# alternative: mean is much lower
# if true mean is significantly lower, then we reject null and thus,
# they played abnormally well.
t.test(SeahawkGameScores, alt = "less", mu = SB2014Score, conf.level = 0.99)

# ANSWER: The Seahawks did play abnormally well during their superbowl game,
# at least when using their pre-season performance as indicators.
# Had I had access to regular reason data, I could've made a 
# conglomerate data set or better yet, a two sample t-test to preserve behavior.
# Doesn't disprove their score though. This could've applied to their defensive behavior, too.





# Left tailed attempt in raw code.

SeahawksMean <- mean(SeahawkGameScores)
Seahawks.Std.Dev <- sd(SeahawkGameScores)

t <- (SB2014Score - SeahawksMean) / (Seahawks.Std.Dev / sqrt(length(SeahawkGameScores)))
p_value = pt(t,length(SeahawkGameScores)-1, lower.tail = F) # deg. of freedom adjustment.

# 0.00000323503

#_______________________________________________________________________________



# ********
# To avoid multicollinearity, we plot many variables against each other,
# Ultimately, staying with 4 that don't show strong signs of multicollinearity.
# Rush attempts and pass attempts, for example, were strongly correlated.
# Note: We are not trying to predict outcome but simply see how much
# each variable contributes to it. This is why our R^2 won't matter-- bc we aren't trying to predict.
pairs(select(NFL2013.Final, c(4:5,7,10)))


Model <- lm(ScoreOff ~ FirstDownOff+ThirdDownPctOff+RushYdsOff+PassYdsOff, data = NFL2013.Final)
summary(Model)
plot(Model, 1:2)

# From our Multiple Linear Regression (& chosen variables), we see that the number of first downs contribute the most.
# We see that for each first down the offensive team gets,
# their total score rises by 0.45.
# Our constant (intercept) is the value (the mean) we expect to have for 
# final offensive score if the rest of our variables remain at 0.

# The model is portrayed by:
#  6.602268 + 0.452526(x1) + 8.479595(x2) + 0.022859(x3) + 0.026645(x4)

#Where:
# x1:Num of offensive first downs.
# x2:Percent of offensive plays that get to the third down.
# x3:Yards gained during rushes.
# x4: Yards gained during passes.
# Had I started off with more uncorrelated variables, I could've used step-wise 
# backwise/forward elimination.

# With our first graph, we hope to see a random scattering of points and that is exactly what we see. There seems to be the same variability (constant variance) throughout all the different values of x. 

# From our Normal Q-Q Plot, we notice that the model is mostly normal so we can carry on.


## Only if we were trying to truly predict total score of offensive team, 
## only then would QQ Plots be useful.



#_______________________________________________________________________________


# Looking at the total sum score between both teams on the field
# over the last 10-12 years.

NFLAllYears<- read.csv('Regular.csv')

NFLAllYears <- na.omit(NFLAllYears)
NFLAllYears$Visitor.Score <- as.numeric(NFLAllYears$Visitor.Score)
NFLAllYears$Home.Score <- as.numeric(NFLAllYears$Home.Score)
NFL <- NFLAllYears %>%
  mutate(Total.Score = Visitor.Score + Home.Score, Year = str_sub(Date, start= -4)) %>%
  select(-c(Date)) %>%
  na.omit()
NFL$Year <- as.numeric(NFL$Year)
plottable <- aggregate(Total.Score ~ Year, NFL, mean)

ggplot(plottable, aes(x=Year, y=Total.Score, colour = Year)) + 
  geom_bar(stat = 'identity') + 
  scale_colour_gradientn(colours=rainbow(2)) + theme_minimal() + theme(legend.position = "none") + labs(x= "Year", y= "Year Score Averages" )




# Although there hasn't been a steady increase in the average total 
# sum score of the football games, in the past few years, 
# that number was challenging records set in the previous century and 
# ultimately, broke that record recently. You could say that football players
# score on each other more frequently now. Doesn't necessarily mean they're better.
