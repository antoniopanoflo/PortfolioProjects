
library(dplyr)
library(ggplot2)


# Reading in the dataset and getting a quick look at the class types.
sleep <- read.csv("sleepstudydata.csv")
glimpse(sleep)
head(sleep)

# The data contains six columns answering the following questions:
# Enough: Do you think that you get enough sleep?
# Hours: On average, how many hours of sleep do you get on a weeknight?
# PhoneReach: Do you sleep with your phone within arms reach?
# PhoneTime: Do you use your phone within 30 minutes of falling asleep?
# Tired: On a scale from 1 to 5, how tired are you throughout the day? (1 being not tired, 5 being very tired)
# Breakfast: Do you typically eat breakfast?


# Changing each Yes/No variable from char to factor and dropping rows with NA values.
sleep <- sleep %>%
  mutate(Enough=as.factor(Enough), PhoneReach=as.factor(PhoneReach),
         PhoneTime=as.factor(PhoneTime), Breakfast=as.factor(Breakfast)) %>%
  tidyr::drop_na()


any(is.na(sleep)) # Ensuring NA values are eliminated


# First question to answer: for those who sleep 6 hours or less,
# how many of them sleep with a phone within reach?
# We can see that for those who sleep 2 or 4 hours, phone reach is evenly divided.
# As we look at students who sleep 5 or 6, however, we see a drastic increase 
# in students who sleep with a phone within reach, proportionally.

sleep %>% 
  filter(Hours <= 6) %>%
  ggplot(aes(y=Hours,fill=PhoneReach)) + 
  geom_bar(position="fill") + 
  labs(title="x",x="Student Count")  
