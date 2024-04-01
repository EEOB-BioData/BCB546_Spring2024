# Before you begin

## Update your course repository

You need to clone the course repository to Nova. You probably already have cloned this, so you can skip this step.

```bash
git clone git@github.com:EEOB-BioData/BCB546_Spring2024.git
```

You will still need to pull new changes to this repository at the beginning of class. This will enable you to access new data files and scripts needed for in-class activities.

```bash
cd BCB546_Spring2024
git pull
```

Note that if you have modified any files in the repository, you will need to commit those changes before you can pull new changes. If you don't care about the changes, just delete and re-clone the repository.

## Start Jupyter notebook on Nova on demand.

You can start Jupyter notebook on Nova on demand. This will allow you to run Jupyter notebook on the server and access it from your local machine.

1. Go to the [Nova OnDemand](https://nova-ondemand.its.iastate.edu/) and login
2. Under the "Interactive Apps" tab, click on "Jupyter Notebook", request desired resources and click "Launch"
3. Wait for the job to start and click on the "Connect to Jupyter" button



# Getting Started

To being with, we will need to load the `pandas` library. This library will provide us with the tools we need to work with dataframes.

```python
import pandas as pd
```

Often times, we will also need other libraries to help us with our data analysis. For example, we may need to use the `numpy` library when working with arrays or `os` module when working with files. We can import these libraries as follows:

```python
import numpy as np
import os
```

With `os` module you can get the current working directory using the following command:

```python
os.getcwd()
```

This will return the current working directory as a string. `os` also allows you to construct bash commands and execute them using `os.system()`. For example, to list the files in the current working directory, you can use the following command:

```python
os.system('ls')
# or
cmd = 'ls' # you can construct more complex commands this way
os.system(cmd)
```

There are other ways to run bash commands as well (magic commands, or with `!`), but `os` is a good way to do it programmatically and is easier to use when you need to construct more complex commands.

# Data Structures

The primary data structure in `pandas` is the `DataFrame`. This is a two-dimensional table with rows and columns. You can create a `DataFrame` from a dictionary, a list of dictionaries, a list of lists, or a numpy array.

```python
# Create a DataFrame from a dictionary
data = {'name': ['John', 'Anna', 'Peter', 'Linda'],
        'age': [23, 36, 32, 45],
        'city': ['New York', 'Paris', 'Berlin', 'London']}
df = pd.DataFrame(data)
print(df)
```

You can also create a `DataFrame` from a list of dictionaries. This is useful when you have data that is not in a tabular format.

```python
data = [{'name': 'John', 'age': 23, 'city': 'New York'},
        {'name': 'Anna', 'age': 36, 'city': 'Paris'},
        {'name': 'Peter', 'age': 32, 'city': 'Berlin'},
        {'name': 'Linda', 'age': 45, 'city': 'London'}]
df = pd.DataFrame(data)
print(df)
```

# Our data

For this lesson, we will be using the Portal Teaching data, a subset of the data from the ecological study by Ernst et al. (2009): [Long-term monitoring and experimental manipulation of a Chihuahuan Desert ecosystem near Portal](http://www.esapubs.org/archive/ecol/E090/118/default.htm), Arizona, USA Specifically, we will be using files from the [Portal Project Teaching Database](https://figshare.com/articles/Portal_Project_Teaching_Database/1314459).

This section will use the surveys.csv file that can be downloaded from the `course-files/python` folder of the course repository. Pull from the course repository and change to to course-files/python or copy the surveys.csv file to the directory from which you would like to work.

In this lesson, we are studying the species and weight of (vertebrate) animals captured in plots in our study area. The observed data are stored as a `.csv` file (comma-separated value): each row holds information for a single animal, and the columns represent:


## Reading data

To read the data from the `surveys.csv` file, we can use the `read_csv` function from `pandas`.

```python
surveys_df = pd.read_csv('surveys.csv')
```

You can view the contents of the dataframe

```python
print(surveys_df) # or just type the variable name `surveys_df`
```

## Basic information about the data

To get basic information about the data, you can use the `info()` method.

```python
surveys_df.info()
```

This will return the number of rows and columns, the column names, the number of non-null values in each column, and the data type of each column.

`type`, `dtypes` and `shape` are also useful attributes to get information about the data.

```python
type(surveys_df)
surveys_df.dtypes
surveys_df.shape
```


To look at just the columns of a DataFrame, you can use the `columns` attribute.

```python
surveys_df.columns
```

similiarly, you can look at the index of the DataFrame using the `index` attribute.

```python
surveys_df.index
```

other useful options include `head()` and `tail()` methods to view the first and last few rows of the DataFrame.

```python
surveys_df.head()
```

```python
surveys_df.tail()
```

## Selecting data

You can select data from a DataFrame using the `iloc` method. This method allows you to select rows and columns by their integer index.

Select first row

```python
surveys_df.iloc[0]
```

select the first 5 rows
```python
surveys_df.iloc[0:5] 
```

select the first 5 rows and the first 3 columns

```python
surveys_df.iloc[0:5, 0:3]
```


You can also select data using the column names. This can be done using the `loc` method.

```python
surveys_df.loc[0:5, ['species_id', 'record_id', 'hindfoot_length']]
```

You can also select data based on conditions. For example, to select all rows where the `species_id` is equal to `NL`, you can use the following command:

```python
surveys_df[surveys_df['species_id'] == 'NL']
```

You can also combine conditions using `&` (and) and `|` (or). For example, to select all rows where the `species_id` is equal to `NL` and the `sex` is equal to `M`, you can use the following command:

```python
surveys_df[(surveys_df['species_id'] == 'NL') & (surveys_df['sex'] == 'M')]
```

Let's get a list of all the species. The pd.unique method tells us all of the unique values in the `species_id` column. These are two-character identifiers of the species names (e.g., NL represents the rodent _Neotoma albigula_).

```python
pd.unique(surveys_df['species_id'])
```

# Practice questions:

1. Select unique `plot_id` values.
2. Select all rows where the `weight` is greater than 50.
3. Select all rows where the `weight` is greater than 50 and the `species_id` is equal to `NL`.
4. `nunique()` is a useful method to get the number of unique values in a column. Use this method to get the number of unique `species_id` values.



# Groups in pandas

We often want to calculate summary statistics grouped by subsets or attributes within fields of our data. For example, we might want to calculate the average weight of all individuals per plot.

We can calculate basic statistics for all records in a single column using the .describe() method:

```python
surveys_df['weight'].describe()
```

We can also extract one or more columns from the DataFrame and calculate the mean weight per plot.

```python
surveys_df.groupby('plot_id')['weight'].mean()
```

We can also calculate multiple summary statistics at once using the `agg` method.

```python
surveys_df.groupby('plot_id')['weight'].agg(['mean', 'median', 'std'])
```

Other main statistics that can be calculated include `count`, `sum`, `min`, `max`, `std`, `var`, `sem`, `skew`, `kurt`, `quantile`, `cumsum`, `cumprod`, `cummax`, `cummin`.

You can also group by multiple columns.

```python
surveys_df.groupby(['species_id', 'sex'])['weight'].mean()
```

Or, we can also count just the rows that have the species “PL” (_Peromyscus leucopus_):



# Practice questions:

1. Using the .describe() method on the DataFrame sorted by sex, determine how many individuals were observed for each.
2. Use `groupby` method to group 2 columns `['plot_id','sex']` and calculate the mean of the `weight` column.


# Column operations


You can add a new column to a DataFrame by assigning a value to a new column name. For example, to add a new column `weight_kg` that contains the weight in kilograms, you can use the following command:

```python
surveys_df['weight_kg'] = surveys_df['weight'] / 1000
```

Inspect the DataFrame to see the new column.

```python
surveys_df.head()
```

Or check the stats of the new column.

```python
surveys_df['weight_kg'].describe()
```

# Practice questions:

1. Add a new column `hindfoot_cm` that contains the hindfoot length in centimeters.
2. Calculate the mean of the `hindfoot_cm` column grouped by `species_id` and `sex`.

# Missing data

To check for missing data, you can use the `isnull()` method.

```python
surveys_df.isnull()
```

To count the number of missing values in each column, you can use the `isnull()` method followed by the `sum()` method.

```python
surveys_df.isnull().sum()
```

To drop rows with missing data, you can use the `dropna()` method.

```python
surveys_df.dropna()
```

To fill missing data with a specific value, you can use the `fillna()` method.

```python
surveys_df.fillna(0)
```

# Practice questions:

1. Drop all rows with missing data and save the result to a new DataFrame.

# Exporting data

To export a DataFrame to a CSV file, you can use the `to_csv()` method.

```python
surveys_df.to_csv('surveys_clean.csv', index=False)
```

This will save the DataFrame to a file called `surveys_clean.csv` without the index column.


# Plotting

You can plot data from a DataFrame using the `plot()` method. For example, to plot the mean weight per plot, you can use the following command:

```python
by_plot_sex = surveys_df.groupby(['plot_id','sex'])
plot_data = by_plot_sex['weight'].mean()
plot_data
```     
This calculates the sums of weights for each sex within each plot as a table

To plot:

```python
plot_data.plot(kind='bar')
```

We can reshape the data using unstack to separate `M` and `F` values into separate columns.

```python
plot_data_unstack = plot_data.unstack()
plot_data_unstack
```

Now we can plot the data.

```python
plot_data_unstack.plot(kind='bar')
```

a bit refined plot:
```python
stkplot = plot_data_unstack.plot(kind='bar', stacked=True)
stkplot.set_ylabel("Mean weight")
stkplot.set_xlabel("Plot ID")
stkplot.set_title("Mean weight by plot")
```


# Practice take home questions (not graded):

Continue working with the surveys_df DataFrame on the following challenges:

1. Plot the average weight over all species and plots sampled each year (i.e., year on the horizontal axis and average weight on the vertical axis).

2. Come up with another way to view and/or summarize the observations in this dataset. What do you learn from this?

Feel free to use the `#scripting_help` channel in Slack to discuss these exercises.