
#_______________________________________________________________________________
# Using filter() from the dplyr package!

library(dplyr)

demo <- read.csv("demographics.csv")

### owners with income equal to 60
demo2 <- filter(demo, income == 60)

### married owners
demo2 <- filter(demo, marital == "Married")

### married owners with income greater than 55
demo2 <- filter(demo, marital == "Married" & income > 55)

### we can have multiple conditions
demo2 <- filter(demo, income > 55 & marital == "Married" & carcat == "Luxury")
demo2 <- filter(demo, income > 55 , marital == "Married" , carcat == "Luxury")

### owners with age between 35 and 45
demo2 <- filter(demo, 35<age & age<45)

### owners who are married or the income greater than 55
demo2 <- filter(demo, income>55 | marital == "Married")

### select cases with specific values of a variable and "order by"
demo2 <- filter(demo, age %in% c(42, 45, 60)) %>%
  arrange(age)


### owners with ages different from 42, 45, and 60
demo2 <- filter(demo, !age %in% c(42,45,60))
View(demo2)

#_______________________________________________________________________________
# Using select() from the dplyr package!

#### select only variables age, marital status and gender
demo2 <- select(demo, age, marital, gender)

### selecting range of variables using the colon ':'
demo2 <- select(demo, income:carcat)


### we can specify the variables order number instead of their names

### select the 3rd and 5th columns (income and car price)
demo2 <- select(demo, c(3,5))

### select the variables from the 2nd to the 4th 
demo2 <- select(demo, 2:4)

### to remove a column, we can put minus sign in front of variable
demo2 <- select(demo, -c(age, income))
demo2 <- select(demo, -age, -income)
demo2 <- select(demo, -1, -3)

### 'contains' selects variables that contain a certain string in their name
demo2 <- select(demo, contains("ret"))

### 'starts_with' selects variables that contain a string that start with its input
demo2 <- select(demo, starts_with("in"))

### 'ends_with' selects variables that contain a string that end with its input
demo2 <- select(demo, ends_with("cat"))

#demo2 <- select(demo, carpr, income, everything())

#_______________________________________________________________________________
# Using mutate() from the dplyr package!

### Creating a second income that takes first income column and multiplies it by 10
demo2 <- mutate(demo, income2 = income * 10)

### Add a new variable containing the difference between income and car price
demo2 <- mutate(demo, diff = income - carpr)

### Create a vector and add it to the data frame as a variable
### Note that it must be same size in row count
y <- rnorm(nrow(demo), 0, 1)
demo2 <- mutate(demo, new_var = y)

### Applying same process to multiple variables:
demo2 <- mutate(demo, across(c(1,5), ~ ./1000, .names = "{col}_2"))
demo2 <- mutate(demo, across(c(age,carpr), ~ ./1000, .names = "{col}_2"))

### Diving all numeric values to 1000
demo2 <- mutate(demo, across(where(is.numeric), ~ ./1000))
View(demo2)

demo2 <- mutate(demo, age = demo$age*3, income = demo$income*3) #this way is not as efficient
# because what if you have a ton of variables you need to do this to?


### Compute the means of columns 1 and 5
demo2 <- mutate(demo, across(c(1,5), .fns = mean, .names = "{col}_mean"))

### Computing mean of all columns that are numeric
demo2 <- mutate(demo, across(where(is.numeric), .fns = mean, .names = "{col}_mean"))

### Dividing columns 1,3 & 5 by 1000 for retired owners only
### NOTICE THAT: '~ .' is equal to " on cells ", basically. The dot represents whats inside the cells.
demo2 <- mutate(filter(demo, retired == 'Yes'), across(c(1,3,5), ~ ./1000, .names = "{col}_2"))

#_______________________________________________________________________________
# Using arrange() from the dplyr package!

# Ordering by ascending
demo2 <- arrange(demo, income)
# Ordering by descending
demo2 <- arrange(demo, desc(income))
# Ordering A-Z
demo2 <- arrange(demo, educ)
# Ordering Z-A
demo2 <- arrange(demo, desc(educ))

# Order by income and THEN education; ascending
demo2 <- arrange(demo, income, educ)

# Order by income in ascending and education in descending
demo2 <- arrange(demo, income, desc(educ))


#_______________________________________________________________________________
# Using summarize() from the dplyr package!
# this command computes summary statistics of the variables
# syntax: summarize(data frame, summary function)


### Computing mean of income variable. Will be a list with one element named avginc.
meaninc <- summarize(demo, avginc = mean(income, na.rm=TRUE))
typeof(meaninc)

### Computing standard deviation of the income
summarize(demo, stdinc=sd(income,na.rm=T))

### Computing sum of the income variable
summarize(demo, suminc=sum(income,na.rm=T))

### Computing median of the income variable
summarize(demo, medianinc=median(income,na.rm=T))

### Computing minimum of the income variable
summarize(demo, mininc=min(income,na.rm=T))

### Computing maximum of the income variable
summarize(demo, maxinc=min(income,na.rm=T))

### Computing variance of income variable
summarize(demo, varinc=var(income,na.rm=T))

### Can compute several statistics at once
summarize(demo,
          avginc=mean(income, na.rm=T),
          stdinc=sd(income,na.rm=T),
          varinc=var(income,na.rm=T),
          rowcount = n()) # n() counts rows.

### Computing mean for variables age and car price using the across function
summarize(demo, across(c(1,5), mean))

### Computing mean for all numeric variables
summarize(demo, across(where(is.numeric), mean))

### Computing sd for all numeric but only luxury car owners
summarize(filter(demo,carcat == "Luxury"), across(where(is.numeric), sd))

### Compute mean for all variables that start with letter "c"
# You'll get an NA for carcat bc that column isn't numerical
summarize(demo, across(starts_with("c"), mean))

### Compute mean for all NUMERIC variables that start with letter "c"
summarize(demo, across(starts_with("c") & where(is.numeric), mean))

### Extracting numeric variables and THEN deriving mean
demo2 <- select(demo, age, income, carpr)
summarize(demo2, across(everything(), mean))

#_______________________________________________________________________________
# Using group_by() from the dplyr package!

# Simply specifying which variable will be getting grouped by as we operate.
demo2 <- group_by(demo, educ)
# Filtering our data that I'll be using.
demo3 <- filter(demo, age > 40)

### Computing avg income 
summarize(demo2, avgimc=mean(income))

### Computing means 1 and 4 with across function
# You'll notice that 4 is actually educ -- what we group by-- but R skips it and goes 
# on to carpr! Once grouped by, consider grouped vars "hidden".
summarize(demo2, across(c(1,4), mean))

### Compute the means of all numeric variables for the luxury cars only
summarize(filter(demo2, carcat == "Luxury"), across(where(is.numeric),mean))

#_______________________________________________________________________________
# n_distinct() example -- counts distinct inputs in a column
# faster way of typing length(unique())
n_distinct(demo$marital)

# tally() example -- counts rows or computes sum in a column
tally(demo)
tally(demo, income)

# add_tally example -- adds a column to main data frame that contains sum of var
View(add_tally(demo, income))

# sample_n example -- extracts a random number of samples from chosen dataset
View(sample_n(demo, 4))

# top_n example -- Same thing as LIMIT from SQL. Extracts topmost rows
# You must select by a variable. If not chosen, R will select for you
View(top_n(demo,5,income))

# glimpse() is a little like str() but tries to be as specific as possible
glimpse(demo)


#_______________________________________________________________________________
# Using dplyr's pipe operator (%>%)!

demo <- read.csv("demographics.csv")

### Select owners younger than 40 and with some college education
demo2 <- demo %>% filter(age<40 & educ == "Some college")

### Retain income, car category, and car price vars 
demo2 <- demo %>% select(income, carcat, carpr)

### Now, select those younger than 40 with some college and only return income,
### car category and car price vars only.
demo2 <- demo %>% 
  filter(age<40 & educ == "Some college") %>%
  select(income, carcat, carpr)

### Select those younger than 40 with some college and only return income,
### car category and car price vars only. Then, compute new var 'x' 
### as income / price
demo2 <- demo %>% 
  filter(age<40 & educ == "Some college") %>%
  select(income, carcat, carpr) %>%
  mutate(x = income / carpr)

### Select those younger than 40 with some college and only return income,
### car category and car price vars only. Then, compute new var 'x' 
### as income / price. Then, sort data frame by income in desc order.
demo2 <- demo %>% 
  filter(age<40 & educ == "Some college") %>%
  select(income, carcat, carpr) %>%
  arrange(desc(income))

### Select owners younger than 40 with some college education and then 
### compute the average income and standard deviation of income.
demo2 <- demo %>% 
  filter(age<40 & educ == "Some college") %>%
  summarize(avgincome = mean(income,na.rm=T),sdincome = sd(income,na.rm=T))

### Computing the means of the numeric variables in the demo data frame for 
### each gender category separately
demo2 <- demo %>% 
  group_by(gender) %>%
  summarize(across(where(is.numeric), mean))

### Select the owners of luxury cars and extract the max
### of the numeric variables by gender category
demo2 <- demo %>% 
  group_by(gender) %>%
  filter(carcat == "Luxury") %>%
  summarize(across(where(is.numeric), max))

### Retain income and car price only and derive the average by gender
demo2 <- demo %>% 
  group_by(gender) %>% 
  select(carpr, income) %>%
  summarize(across(everything(), mean))

### Select owners with income over 40 and return their number 
### for each marital status - gender combination
demo2 <- demo %>%
  filter(income>40) %>%
  count(marital, gender)

### Select owners with age over 40 and compute sums of their incomes
demo %>% group_by(marital) %>%
  filter(age>40) %>%
  tally(income)

### Select the owners of standard cars and extract a sample of 50 owners @ random
demo %>%
  filter(carcat == "Standard") %>%
  sample_n(50)

### Select standard car owners. Retain age, income, car price, car category.
### Then, extract a sample of 50 from that @ random. Finally, get top 5 of those in income.
demo %>%
  filter(carcat == "Standard") %>%
  select(age, income, carpr, carcat) %>%
  sample_n(50) %>%
  top_n(5, income)

### Select owners of standard cars. Retain age, income, car price, car category.
### Extract a sample of 50 owners at random. Then get a glimpse of the new data frame.
demo2 <- demo %>%
  filter(carcat == "Standard") %>%
  select(age, income, carpr, carcat) %>%
  sample_n(50) %>%
  glimpse

#_______________________________________________________________________________
# Using dplyr Joins!

# Important to note that joins in dplyr are not symmetric.
# Meaning, inner_join(df1,df2) may be different from inner_join(df2,df1)

cities <- read.csv("cities.csv")
View(cities)
buildings <- read.csv("buildings.csv")
View(buildings)

### Inner Join:
### Joining will be done by variable city bc it's the common variable
### Neither of these next two joins will have rows with cities 'Frankfurt' & "Wroclaw'
### simply bc the cities table doesn't have those.
ij <- inner_join(cities, buildings)
### Same join, different order
ij2 <- inner_join(buildings, cities)



### Semi Join:
### The semi-join will retain only the cities that are in BOTH dataframes
## but only the variables initially found in the 'cities' dataset.
sj <- semi_join(cities,buildings)



### Left Join:
### The left-join returns all rows from the first data frame and all variables 
### from all the data frames as long as the vars are present in each var.
### If there are multiple matches, all combinations are returned
### Again, Frankfurt & Wroclaw aren't in the output table bc not in the cities table.
lj <- left_join(cities,buildings)

### This one, however, will have Frankfurt and Wroclaw bc not we are taking on
### buildings as the main table despite there not being a documented population or country
### for its right table, cities, so there are NAs there.
lj2 <- left_join(buildings,cities) 


### Anti Join:
### This one will be empty bc each city found in 'cities' table is also in 'buildings' 
### table. This defeats the purpose of it being anti so we don't return anything.
aj <- anti_join(cities, buildings)

### This one, however, will include two cities that aren't found in the 'cities' table
aj2 <- anti_join(buildings, cities)


### Full Join:
### A full join will include all inputs in variables regardless if they have a match 
### or not. Just expect NAs when you don't have a matching record on the other table
fj <- full_join(cities, buildings)
fj2 <- full_join(buildings, cities)


#_______________________________________________________________________________
# Using dplyr in conjunction with ggplot2!
require(dplyr)
require(ggplot2)


### Create a column chart that represents the avg car price by car category
### Important: Have to use geom_col bc geom_bar can't be used if there is already 
### a y-axis defined inside aes().
demo %>% 
  group_by(carcat) %>%
  summarize(avgcarpr = mean(carpr, na.rm=T)) %>%
  ggplot(aes(x = carcat, y = avgcarpr)) + geom_col(fill = "darkblue")

### Create a column chart that displays the max car price by car category
demo %>%
  group_by(carcat) %>%
  summarize(maxcarpr = max(carpr, na.rm=T)) %>%
  ggplot(aes(x = carcat, y = maxcarpr)) + geom_col(fill = "darkblue") + 
  xlab("Car Categories") + ylab("Max Car Price")

### Create a column chart that represents the average income 
### by gender for luxury car owners
demo %>%
  group_by(gender) %>%
  filter(carcat == "Luxury") %>%
  summarize(avgincome = mean(income, na.rm=T)) %>%
  ggplot(aes(x = gender, y = avgincome)) + geom_col(fill = "darkblue") + 
  xlab("Gender") + ylab("Avg Income for Luxury Car Owners")

### Create a mean plot that displays 
### the avg income  by education level
### Note: The group=1 is required when we have one grouping variable only.
### It is what tells ggplot to connect all the dots with a line.
demo %>% 
  group_by(educ) %>%
  summarize(avginc = mean(income,na.rm=T)) %>%
  ggplot(aes(x = educ, y = avginc, group =1)) + geom_line(color = "darkred") + 
  scale_x_discrete(guide = guide_axis(angle = 40))

### Create a mean plot chart that displays average car price by gender for the owners 
### with income greater than 70. Notice: You have to group by first.
demo %>%
  group_by(gender) %>%
  filter(income>70) %>%
  summarize(avgcarpr = mean(carpr, na.rm=T)) %>%
  ggplot(aes(x = gender, y = avgcarpr, group=1)) + geom_line(color = "darkred")

### A mean plot chart that represents the average income by gender
### with a separate line for each marital status
demo %>%
  group_by(gender, marital) %>%
  summarize(avginc = mean(income, na.rm=T)) %>%
  ggplot(aes(x = gender, y = avginc, group = marital, color = marital)) + geom_line()

### Same as before but switching x-axis with legend groups and only on people 
### with Economy cars
demo %>%
  group_by(gender, marital) %>%
  filter(carcat=="Economy") %>%
  summarize(avginc = mean(income, na.rm=T)) %>%
  ggplot(aes(x = marital, y = avginc, group = gender, color = gender)) + geom_line() +
  theme_light()


demo %>%
  group_by(gender) %>%
  filter(carcat == "Luxury") %>%
  summarize(avgincome = mean(income, na.rm=T)) %>%
  ggplot(aes(x = gender, y = avgincome)) + geom_bar(fill = "darkblue") + 
  xlab("Gender") + ylab("Avg Income for Luxury Car Owners")

##### Building scatterplots, violin plots, histograms and boxplots!

mk <- read.csv("marketingdb.csv")

### Creating scatterplot to showcase income by age in both males and females.
mk %>% 
  ggplot(aes(x = age, y = income, color = gender)) + geom_point()

### Creating scatterplot that shows relationship between age & income by gender
### for Mastercard users only
mk %>%
  filter(card == "Mastercard") %>%
  ggplot(aes(x=age, y=income, color=gender)) + geom_point()

### Creating scatterplot that shows relationship between age & income by gender
### for people w/ at least 20 years of education.
mk %>%
  filter(ed >= 20) %>%
  ggplot(aes(x=age, y=income, color=gender)) + geom_point()

### Boxplot chart of income by gender category 
### for the owners aged between 35 and 50
demo %>% 
  filter(age >= 35 & age <= 50) %>%
  ggplot(aes(x = gender, y = income, fill = gender)) + geom_boxplot()

### Tossing in a violin plot:
### Creating 3 evenly spaced bins to separate education levels and making violin plots
### based to depict income for each education level.
### Notice: Fill is color within the figure and color is the outline color of figure!
mk %>%
  mutate(class = cut(mk$ed, breaks=3)) %>%
  ggplot(aes(x = class, y=income, fill = class, color = class)) + geom_violin() 

### Creating a histogram to show income by gender category
### For the car prices lower than 50
demo %>%
  filter(carpr < 50) %>%
  ggplot(aes(x = income, fill = gender)) + geom_histogram()



