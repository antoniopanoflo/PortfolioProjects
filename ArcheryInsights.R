


library(readxl)
library(dplyr)
library(ggplot2)




# In this project, I'm going to explore variables that, intuitively,
# may be the ones that contribute most the shot accuracy in archery:

# Gender
# Time to Shoot (in seconds)
# Number of eyes open (1 or 2)
# Number of blinks before shooting

#_______________________________________________________________________________
### Data Cleaning

# loading dataset and removing unnecessary columns.
archery <- read_excel("538_ArcheryData.xlsx") %>%
  select(-c(1,'...25', 'Other info'))

archery$`Eyes Open` <- as.factor(archery$`Eyes Open`)
archery$`Win/Lost` <- as.factor(archery$`Win/Lost`)


# filling in NA blink values for one of the tournaments by grabbing mean number of blinks.
papendal <- subset(archery, Tournament=="Papendal Invitational") %>%
  mutate(Blinks = round(tidyr::replace_na(Blinks, mean(Blinks, na.rm = T))))

# subsetting the rest of the tournaments that didn't have NA values.
not_papendal <- subset(archery, !Tournament %in% c("Papendal Invitational"))


# "stacking" the two previous subset datasets to now have something to work on.
archery <- union_all(papendal, not_papendal)

#_______________________________________________________________________________

### Exploring Time to Shoot on accuracy (Point variable).

# MAKE A BAR PLOT. THE ONE FROM YOUR PAPER. 
# DIFFERENCE IN MEAN TIME TO SHOOT BETWEEN WINNERS AND LOSERS.
# Avg time to shoot ~ win/lost


barplot(archery$`Win/Lost`, mean(archery$`Time to Shoot (s)`))


# The first question insight we look at is whether the amount of time the archers
# take to shoot, impacts how accurate (points per shot) they are.
# We create a regular linear regression to see this and interpret our
# regular linear regression.

# Overall, Time to Shoot is statistically significant with a p-value
# of 0.049-- just under our alpha value of 0.05. So I graph it.
lm = lm(Points ~ `Time to Shoot (s)`, data = archery)
summary(lm)

# changing default theme for global ggplot use.
theme_set(theme_bw())

ggplot(data = archery,
       mapping = aes(x = `Time to Shoot (s)`, y = Points)) +
  geom_jitter(colour = archery$`Time to Shoot (s)`, shape = 19, size = 5) +
  xlab("Time To Shoot (seconds)") + ylab("Points") +
  geom_smooth(method='lm', color='turquoise4', formula = y ~ x)

# We notice through our Residuals vs Fitted  plot that if an archer takes from around
# 9.05 secs. to 9.35 secs. to shoot, our model actually predicts a lower score 
# for their shot (less accuracy).

# Most importantly, we notice a curve and determine that our data isn't best
# captured by a regular linear model. I go on to try a polynomial.
plot(lm, 1)

#_______________________________________________________________________________

### Exploring a more fitting model.

# Once we use a poly regression with a degree to the second, using the 
# updated Residuals vs Fitted, we see that we have dramatically improved the variance of the predicted value
# residuals. Though, we still have the 3 outliers at observations 111, 113, and 118 when 
# looking at our Residuals vs Leverage plot with cook's distances.
poly <- lm(Points ~ poly(`Time to Shoot (s)`, 2, raw=T), data = archery)
plot(poly,4)
summary(poly)



# if raw = T, use raw and not orthogonal polynomials.
ggplot(data = archery,
       mapping = aes(x = `Time to Shoot (s)`, y = Points)) +
  geom_jitter(colour = archery$`Time to Shoot (s)`, shape = 19, size = 4) +
  xlab("poly(Time To Shoot (seconds))") + ylab("Points") +
  geom_smooth(method='lm', 
              color='turquoise4', 
              formula = y ~ poly(x, degree = 2, raw=T))



# adding an index row column to delete outlier rows through the index column as
# good practice.
archery$index <- 1:nrow(archery)
archery_updated <- archery[ !(archery$index %in% c(111,113,118)), ]


# creating a polynomial regression again to see if coefficients have improved.
poly_updated <- lm(Points ~ poly(`Time to Shoot (s)`, 2, raw=T), data = archery_updated)
summary(poly_updated)
plot(poly_updated, 1)

# Noticing that our Multiple R-Squared was previously 0.1819 but has now 
# moved on to 0.2204-- letting us know that the model has been enhanced. 
# The difference between the multiple R-Squared and the Adjusted R-Squared
# has also decreased-- yet another good sign. We move on to graphing.
ggplot(data = archery_updated,
       mapping = aes(x = `Time to Shoot (s)`, y = Points)) +
  geom_jitter(colour = archery_updated$`Time to Shoot (s)`, shape = 19, size = 4) +
  xlab("poly(Time To Shoot (seconds))") + ylab("Points") +
  geom_smooth(method='lm', 
              color='turquoise4', 
              formula = y ~ poly(x, degree = 2, raw=T))


#_______________________________________________________________________________

### Exploring Eyes Open Variable impact on Points per shot (accuracy).

# There is a debate in the archery community on whether
# using one eye or two eyes is best when shooting.
# Here, I graph the spread for both cases, with each gender.


# After making a boxplot we see that having 2 eyes open leads to a lower median 
# lower points per shot-- at least with our dataset. This is the case with both genders.
# It's important to note that we collected a lot less data on female archers.
# ## It would be wise to standardize/normalize the y-axis but I forgot how at the time of this writing and can't find the answer online. Will come back.
ggplot(archery, aes(x=`Eyes Open`, y=Points, fill=`Gender`)) + 
  geom_boxplot() + geom_point(stat="summary", fun=mean) 


# After looking at the estimate for 2 eyes open, our linear model also verifies
# that the predicted score will be -0.6090 (0.6090 less) when the archer uses 2 eyes.
lm_eyes <- lm(Points ~ `Eyes Open`, data = archery)
summary(lm_eyes)


#_______________________________________________________________________________
### Exploring Eyes Open Variable impact on Points per shot (accuracy).

plot(jitter(Points) ~ Blinks, data = archery, ylab="Points", col = 2:21)





#______________________________________________________________________________

### Another neat thing to do is to explore blinks ~ target distance
### but that would be more useful if we had a wider variety in distances.


#_______________________________________________________________________________



# Note: These two mean the same thing. 
summary(lm(Points ~ `Time to Shoot (s)`, data = archery))
summary(lm(Points ~ poly(`Time to Shoot (s)`, 1, raw=T), data = archery))

# Raw = F is us using orthogonal polynomials.
# Raw = T is us NOT using orthogonal polynomials.
