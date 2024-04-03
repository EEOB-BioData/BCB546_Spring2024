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

For this short exercise, we will be using the `pandas` library in Python to manipulate a GFF3 file.
GFF3 is a file format used for storing genomic features in a plain text format. It is a tab-delimited file that describes the features of a genome assembly. Each line in the file represents a feature, such as a gene, exon, or CDS. These features can be nested, eg: CDS, and exons are within the mRNA feature, mRNA is within the gene feature. 
The file is divided into nine columns (usually referred as attributes column), will contain feature specific information and is not standardized. The first eight columns are mandatory and are as follows:

1. `seqid`: chromosome or scaffold the feature is located.  
2. `source`: Source of the feature, eg: a database or tool that generated the feature.
3. `type`: feature type, eg: `gene`, `mRNA`, `CDS`, `exon` etc.
4. `start`: genomic start position of the feature.
5. `end`: genomic end position of the feature.
6. `score`: Feature score, can be a floating-point number, missing is represented by "`.`".
7. `strand`: strand of the feature, can be + or -, missing is represented by "`.`".
8. `phase`: usually for `CDS` feature, and can be `0`, `1`, or `2`. missing is represented by "`.`".
9. `attributes`: a semicolon-separated list of tag-value pairs, where the tag and value are separated by `=`. The tag-value pairs are feature specific.


## Importing the required libraries

We will be using the `pandas` library to read and manipulate the GFF3 file. We will also use the `os` library to check if the file exists. Later for plotting, we will also use the `seaborn` library. And one specific function from `matplotlib` library to save the plots.

```python
import pandas as pd
import os
import seaborn as sns 
import matplotlib.pyplot as plt
```

## Download the GFF3 files

We will use maize annotation file for B73 downloaded from MaizeGDB for this tutorial. The file is loacted [here](https://download.maizegdb.org/Zm-B73-REFERENCE-NAM-5.0/) but it has been pre-downloaded to the working directory. 

The file name is `Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.gff3.gz` 

These are unix commands and you can simply prefix `!` to run them on Jupyter notebook.

```python
## in bash (note the exclamation point in front of standard commands)
!wget https://download.maizegdb.org/Zm-B73-REFERENCE-NAM-5.0/Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.gff3.gz
!gunzip Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.gff3.gz
```

**Note**: If you rerun this cell, you will likely get an error since the file already exists in the directory. Be sure to either delete or skip this cell when rerunning.

## Reading the GFF3 file

We will use the `pd.read_csv` function to read the GFF3 file. Since the file is tab-delimited, we will use the `sep` argument to specify the delimiter. We will also use the `comment` argument to skip the header lines in the file. 


```python
gff3_file = "Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.gff3"
columns = ['seqid', 'source', 'type', 'start', 'end', 'score', 'strand', 'phase', 'attributes']
gff3_df = pd.read_csv(gff3_file, sep='\t', comment='#', header=None, names=columns)
```

with `os` library, you can check if the file exists before reading it.

```python
if os.path.exists(gff3_file):
    gff3_df = pd.read_csv(gff3_file, sep='\t', comment='#', header=None, names=columns)
else:
    print(f"{gff3_file} does not exist")
```



## 1. Explore the data

Let's take a look at the first few rows of the dataframe to understand the structure of the data.

```python
gff3_df.head()
```

and the last few rows

```python
gff3_df.tail()
```

To examine the columns and the type of object they are assigned to, we can use the info method.

```python
gff3_df.info()
```

Let's see the unique values in the `type` column. These are the features in the GFF3 file.

```python
gff3_df['type'].unique()
```

We can also see what the unique values in the `seqid` column are.

```python
gff3_df['seqid'].unique()
```

It looks like the GFF3 file has annotations for chromsomes and scaffolds. 

## 2. Filtering the data

Since we are interested in the chr features only, we can filter the dataframe to include `seqid` column that have a match to `chr`.

```python
filter = gff3_df['seqid'].str.contains('chr')
chr_gff3_df = gff3_df[filter]
```

Check the output

```python
chr_gff3_df.head()
chr_gff3_df.tail()
```

Does the output look as expected?

Other common filters include filtering by feature type. For example, to filter only the `gene` features, we can use the following code.

```python
filter = chr_gff3_df['type'] == 'gene'
gene_df = chr_gff3_df[filter]
```

same can be done for `mRNA`, `CDS`, `exon` features as well.


## 3. Format conversion

A common task in bioinformatics is format conversion. We frequently need convert files from one format to another. 
The genomic coordinates in GFF3 files are 1-based, but other formats, such as [BED file format](https://useast.ensembl.org/info/website/upload/bed.html), is 0-based coordinates.

![zero-based-and-one-based-coordinates](https://github.com/EEOB-BioData/BCB546_Spring2024/assets/4835524/17f19f18-06e0-442a-b5b5-d4cd285c4fdc)

source: [biostars.org](https://www.biostars.org/p/84686/)

We will extract only `mRNA` features from the GFF3 file and convert the coordinates to 0-based and save it as a bed file.

```python
filter = chr_gff3_df['type'] == 'mRNA'
mRNA_df = chr_gff3_df[filter]
```

select the columns we need

```python
mRNA_df = mRNA_df[['seqid', 'start', 'end', 'attributes', 'score', 'strand']]
```

For the attribute column, we only need the first attribute which is the ID of the mRNA feature. We will extract this information and add it as a new column in the dataframe.

```python
mRNA_df['mRNA_id'] = mRNA_df['attributes'].str.split(';', expand=True)[0].str.split('=', expand=True)[1]
```

rearrange the columns

```python
mRNA_df = mRNA_df[['seqid', 'start', 'end', 'mRNA_id', 'score', 'strand']]
```

Now we will convert the start position to 0-based by subtracting 1 from the start position.

```python
mRNA_df['start'] = mRNA_df['start'] - 1
```

Finally, we will save the dataframe as a bed file.

```python
mRNA_df.to_csv('B73v5_mRNA.bed', sep='\t', index=False, header=False)
```

Congratulations! You have successfully converted a GFF3 file to a BED file!


## 4. Summary Statistics

Another interesting task is to calculate summary statistics of various features in your GFF3 file. We can calculate the length of each feature by subtracting the start position from the end position (since it is 0-based).

```python
chr_gff3_df['feature_length'] = chr_gff3_df['end'] - chr_gff3_df['start']
```

Total sum of gene feature lengths

```python
chr_gff3_df[chr_gff3_df['type'] == 'gene']['feature_length'].sum()
```

This is the total length of all the genes in the GFF3 file. For a genome of 2.4Gb, this is a very small fraction of the genome. 


Using the `groupby` method, we can calculate various summary statistics for each feature type.

```python
chr_gff3_df.groupby('type')['feature_length'].agg(['count', 'mean', 'median', 'min', 'max', 'std'])
```

change display options to show the values correctly

```python
pd.options.display.float_format = '{:,.2f}'.format
```

```python
chr_gff3_df.groupby('type')['feature_length'].agg(['count', 'mean', 'median', 'min', 'max', 'std'])
```



To save them as a csv file, we can use the `to_csv` method.

```python
summary_stats = chr_gff3_df.groupby('type')['feature_length'].agg(['count', 'mean', 'median', 'min', 'max', 'std'])
summary_stats.to_csv('summary_stats.csv')
```


Also, if you want a specific feature stats, you can also do this:

```python
filter = chr_gff3_df['type'] == 'gene'
gene_df = chr_gff3_df[filter]
gene_df['feature_length'].describe()
```

This will give you the summary statistics for the gene features only.



## 5. Visualizations

Generating count plots is a great way to visualize the distribution of features in your GFF3 file. We can use the `seaborn` library to generate count plots.

```python
sns.countplot(data=chr_gff3_df, x='type')
```

Maybe we should look at single feature across the `seqid`

For `gene` features:

```python
filter = chr_gff3_df['type'] == 'gene'
sns.countplot(data=chr_gff3_df[filter], x='seqid')
```

For `mRNA` features:

```python
filter = chr_gff3_df['type'] == 'mRNA'
sns.countplot(data=chr_gff3_df[filter], x='seqid')
```

We also generate histograms to visualize the distribution of feature lengths.

Let's check the `CDS` feature length distribution.

```python
filter = chr_gff3_df['type'] == 'CDS'
sns.histplot(data=chr_gff3_df[filter], x='feature_length', bins=50)
```

To make the distribution more interpretable, we can use a log scale on the x-axis.

```python
sns.histplot(data=chr_gff3_df[filter], x='feature_length', bins=50, log_scale=True)
```

you can adjust the bins for more granularity.

```python
sns.histplot(data=chr_gff3_df[filter], x='feature_length', bins=1000, log_scale=True)
```

or can also be plotted as a kernel density estimate plot.

```python
sns.kdeplot(data=chr_gff3_df[filter], x='feature_length', log_scale=True)
```

Similarly, you can generate histograms for other features as well.

For `gene` features:

```python
filter = chr_gff3_df['type'] == 'gene'
sns.histplot(data=chr_gff3_df[filter], x='feature_length', bins=50, log_scale=True)
```

To save plots, you can either use the `%%` magic command in Jupyter notebook or use the `savefig` method.

```python
%%capture --no-display fig.png
sns.histplot(data=chr_gff3_df[filter], x='feature_length', bins=50, log_scale=True)
```

or

```python
sns.histplot(data=chr_gff3_df[filter], x='feature_length', bins=50, log_scale=True)
plt.savefig('gene_feature_length_distribution.png')
```


## 6. Advanced filtering

Suppose you want to subset your GFF3 file to retain only primary transcripts. You can use the `attributes` column to filter the dataframe.

```python
filter = chr_gff3_df['attributes'].str.contains('primary_transcript')
chr_gff3_df[filter]
```

As you see, this will only fetch you `mRNA` features but not its child features like `CDS` or `exon`. If you want to fetch all the child features of the primary transcript, you can use the `mRNA_id` column to filter the dataframe.

```python
mRNA_id = chr_gff3_df[filter]['attributes'].str.split(';', expand=True)[0].str.split('=', expand=True)[1]
```

This list of ids are the primary transcripts. You can use this list to filter the dataframe.

```python
import re
# create a pattern to search for the IDs
pattern = re.compile('|'.join(mRNA_id))
# Define a function to check if a given attribute contains any of the IDs
def contains_id(attribute):
    return bool(pattern.search(attribute))
# Apply the function to each row in the DataFrame
primary_gff3_df = chr_gff3_df[chr_gff3_df['attributes'].apply(contains_id)]
```

## 7. Iterating over the dataframe

If you want to iterate over the dataframe, you can use the `iterrows` method.

```python
for index, row in chr_gff3_df.iterrows():
    print(row['seqid'], row['type'], row['start'], row['end'])
```

This is useful when you want to perform some operation on each row of the dataframe.

```python
for index, row in chr_gff3_df.iterrows():
    if row['type'] == 'gene':
        print(row['seqid'], row['type'], row['start'], row['end'])
```

This will print the genomic coordinates of all the genes in the GFF3 file.

The above filtering can also be done using `iterrows` method.

```python
for index, row in chr_gff3_df.iterrows
    if 'primary_transcript' in row['attributes']:
        print(row['seqid'], row['type'], row['start'], row['end'])
```

This will print the genomic coordinates of all the primary transcripts in the GFF3 file.


## Conclusion

In this short exercise, we learned how to read a GFF3 file using `pandas`, filter the data, convert the format, calculate summary statistics, and visualize the data. These are some of the common tasks you might encounter while working with GFF3 files.

`pandas` makes working with non-standardized file formats like GFF3 easy and efficient. It provides a powerful set of tools to manipulate and analyze the data.