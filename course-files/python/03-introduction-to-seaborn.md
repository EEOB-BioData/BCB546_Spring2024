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

To begin, we need to import the necessary libraries.

```python
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
```

Although we are learning about Seaborn, we will still use Pandas to load and manipulate the data, `matplotlib`  for additional customization, and `seaborn` for plotting.

# Load the data

To check what built-in datasets are available in Seaborn, you can use the following command:

```python
sns.get_dataset_names()
```

This will return a list of available datasets. For this exercise, we will first use the `iris` dataset.

```python
iris = sns.load_dataset('iris')
iris.head()
```

We will also load some other datasets for the exercises.

```python
titanic = sns.load_dataset('titanic')
titanic.head()
```

```python
tips = sns.load_dataset('tips')
tips.head()
```

# Basic plotting

## Create a scatter plot of the iris dataset

```python
sns.scatterplot(data=iris, x='sepal_length', y='sepal_width', hue='species')
```

## Create a boxplot of the iris dataset

```python
sns.boxplot(data=iris, x='species', y='sepal_length')
```

## Create a violin plot of the iris dataset

```python
sns.violinplot(data=iris, x='species', y='sepal_length')
```

## Data exploration

Explore the titanic dataset and to understand the relationship between the variables.


```python
titanic.head()
```

```python
titanic.info()
```

It contains information of all the passengers aboard the RMS Titanic.

Let's check the number of passengers in each class.

```python
sns.catplot(data=titanic, x='class', kind='count')
```

And grouped by their survival:

```python
sns.catplot(data=titanic, x='class', kind='count', hue='survived')
```

Let's check the same with "sex" as well.

```python
sns.countplot(x='survived', hue='sex', data=titanic)
```

You can check this information for other variables as well.

```python
sns.countplot(x='survived', hue='embarked', data=titanic)
```


If you want to see overall survival rate, you can use the following command:

```python
sns.countplot(x='survived', data=titanic)
```

Other informational plots can be created using the `sns.catplot` function.

```python
sns.catplot(data=titanic, x='class', y='fare', kind='box')
```

For Iris dataset, since it is a small dataset, we can use the `pairplot` function to visualize the relationship between all the variables.

```python
sns.pairplot(iris, hue='species')
```







