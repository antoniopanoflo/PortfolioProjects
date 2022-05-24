#!/usr/bin/env python
# coding: utf-8

# # 911 Calls Capstone Project

# For this capstone project we will be analyzing some 911 call data from [Kaggle](https://www.kaggle.com/mchirico/montcoalert). The data contains the following fields:
# 
# * lat : String variable, Latitude
# * lng: String variable, Longitude
# * desc: String variable, Description of the Emergency Call
# * zip: String variable, Zipcode
# * title: String variable, Title
# * timeStamp: String variable, YYYY-MM-DD HH:MM:SS
# * twp: String variable, Township
# * addr: String variable, Address
# * e: String variable, Dummy variable (always 1)
# 
# Just go along with this notebook and try to complete the instructions or answer the questions in bold using your Python and Data Science skills!

# ##### Setting up the data

# ____
# ** Import numpy and pandas **

# In[1]:


import numpy as np
import pandas as pd


# ** Importing visualization libraries and seting %matplotlib inline for visualization output within our notebook. **

# In[3]:


import matplotlib.pyplot as plt
import seaborn as sns
get_ipython().run_line_magic('matplotlib', 'inline')


# ** Reading in the csv file**

# In[4]:


df = pd.read_csv('911.csv')
df.info()


# In[5]:


df.head()


# ** Top 5 zipcodes and their respective counts for 911 calls? **

# In[6]:


df['zip'].value_counts().head(5)


# ** Top 5 townships (twp) for 911 calls? **

# In[7]:


df['twp'].value_counts().head(5)


# ** Take a look at the 'title' column, how many unique title codes are there? **

# In[8]:


df["title"].nunique()


# ##### Creating New Features to the dataset

# **Creating a new column for each dept being called on for the situation and naming it 'reason'. **

# In[9]:


df['title'].iloc[3].split(':')


# In[10]:


df['reason'] = df['title'].apply(lambda title: title.split(":")[0])


# ** What is the most common Reason for a 911 call based off of this new column? **

# In[11]:


df['reason'].value_counts().head(1)


# ** Using seaborn to create a countplot of 911 calls by reason'. **

# In[12]:


sns.countplot(x='reason', data=df)


# ___
# ** Now let us begin to focus on time information. What is the data type of the objects in the timeStamp column? **

# In[13]:


type(df['timeStamp'].iloc[0])


# ** Using [pd.to_datetime](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.to_datetime.html) to convert the column from strings to DateTime objects. **

# In[14]:


df['timeStamp'] = pd.to_datetime(df['timeStamp'])


# ** You can now grab specific attributes from a Datetime object by calling them. For example:**
# 
#     time = df['timeStamp'].iloc[0]
#     time.hour
# 
# **You can use Jupyter's tab method to explore the various attributes you can call. Now that the timestamp column are actually DateTime objects, use .apply() to create 3 new columns called Hour, Month, and Day of Week. You will create these columns based off of the timeStamp column, reference the solutions if you get stuck on this step.**

# In[15]:


time = df['timeStamp'].iloc[0]
time.hour


# In[16]:


df['hour'] = df['timeStamp'].apply(lambda time: time.hour)
df['month'] = df['timeStamp'].apply(lambda time: time.month)
df['day of week'] = df['timeStamp'].apply(lambda time: time.dayofweek)

#Confirming the added columns.
df.head(2)


# ** Noticing how the Day of Week is an integer 0-6 and using .map() with this dictionary to map the actual string names to the day of the week instead of keeping the integers: **
# 
#     dmap = {0:'Mon',1:'Tue',2:'Wed',3:'Thu',4:'Fri',5:'Sat',6:'Sun'}

# In[17]:


dmap = {0:'Mon',1:'Tue',2:'Wed',3:'Thu',4:'Fri',5:'Sat',6:'Sun'}


# In[18]:


df['day of week'] = df['day of week'].map(dmap)


# ** Now use seaborn to create a countplot of the Day of Week column with the hue based off of the Reason column. **

# In[19]:


sns.countplot(x='day of week',data = df, hue = 'reason')

#Relocating the legend.
plt.legend(bbox_to_anchor=(1.25, 1),loc='upper right')


# In[20]:


#Grouping by month will use our current month column in the data set as the new index for the rows.

byMonth = df.groupby('month').count()
byMonth.tail()
#byMonth['lat'].plot()


# ##### Creating a linear fit to depict a linear fit on the number of calls per month.

# In[21]:


# We need to allow seaborn to access the month information for the x-axis. We do this by resetting the month index
# temporarily. This allows there to be a linear join between month 8 and month 12 when there was missing data.
sns.lmplot(x = "month", y = "twp", data = byMonth.reset_index())


# ** Creating a new column called 'Date' that contains the date from the timeStamp column.** 

# In[30]:


#creating a lambda function to count all distinct dates presented in the dataset.
t = df['timeStamp'].iloc[0]
df['date'] = df['timeStamp'].apply(lambda t : t.date())

df.groupby('date').count()


# ### Creating plot to showcase activity level for each reason of 911 calls throughout the year.

# In[41]:


df['reason'].unique()


# In[64]:


plt.figure(figsize=(7,4))
df[df['reason']=='EMS'].groupby('date').count()['lat'].plot()
plt.tight_layout()
plt.title('EMS')


# In[63]:


plt.figure(figsize=(7,4))
df[df['reason']=='Fire'].groupby('date').count()['lat'].plot()
plt.tight_layout()
plt.title('Fire')


# In[62]:


plt.figure(figsize=(7,4))
df[df['reason']=='Traffic'].groupby('date').count()['lat'].plot()
plt.tight_layout()
plt.title('Traffic')

