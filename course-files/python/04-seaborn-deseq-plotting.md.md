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
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
```

We will need `pandas` for data manipulation, `matplotlib` for plot customization, `seaborn` for plotting, and `numpy` for some additional calculations.


# Load the data

For this example, we will use DESeq2 results from a differential expression analysis. 
Briefly, this dataset compares knockout and wildtype samples for a specific gene, placenta enriched 1 (or PLAC1) in rats (_Rattus norvegicus_). This gene is involved in the development of the placenta and is expressed in the placenta and testis. The study aims to find the role of PLAC1 in the placenta and its how it affects the development of the placenta. 

The results compare 5 replicates each of WT and KO samples.

```python
filepath = 'DESeq2results-KOvsWT_fc.tsv'
deseq = pd.read_csv(filepath, sep='\t')
```

First, examine data structure and contents.

```python
deseq.head()
```

The data contains the following columns (standard  DESeq2 output):

- `Gene`: gene name
- `baseMean`: average of normalized counts
- `log2FoldChange`: log2 fold change
- `lfcSE`: standard error of log2 fold change
- `stat`: Wald statistic
- `pvalue`: p-value
- `padj`: adjusted p-value

plus, additional columns:

- `PLAC1.1KO` through `PLAC1.5WT`: normalized counts for each sample (5 WT, 5 KO)
- `external_gene_name` : gene name
- `gene_biotype`: gene biotype
- `description`: gene description


We will also exampine data columns information.

```python
deseq.info()
```


# Basic plotting

## Create a volcano plot

A volcano plot is a scatter plot that shows the relationship between fold change and statistical significance. 

In a simple form:

```python
sns.scatterplot(data= deseq, x='log2FoldChange', y='padj')
plt.xlabel('log2 Fold Change')
plt.ylabel('Adjusted p-value')
```

We may have to adjust the plot size and resolution:

```python
plt.rcParams['figure.figsize'] = [8, 6]
plt.rcParams['figure.dpi'] = 300 
```

As you can see, the p-value ranges from 0 to 1, and it is not very easy to interpret the plot. It is a common practice to transform the p-value to -log10(p-value) to make it easier to interpret.

So we will add another column to the data frame with -log10(p-value) and use that for plotting.

```python
deseq['negLog10.padj'] = -np.log10(deseq['padj'])
```

Now, we can plot the volcano plot with -log10(p-value).

```python
sns.scatterplot(data= deseq, x='log2FoldChange', y='negLog10.padj')
plt.xlabel('log2 Fold Change')
plt.ylabel('-log10 Adjusted p-value')
```

Now, it looks like a typical volcano plot. You can see the genes with high fold change and low p-value are more significant.

Next, we will color them based on upregulated or downregulated genes. For this, we will create filters and apply them to create a column that can be used for `hue` in the `scatterplot`.

```python
upFilter = (deseq['log2FoldChange'] > 1.5) & (deseq['padj'] <= 0.05)
downFilter = (deseq['log2FoldChange'] < -1.5) & (deseq['padj'] <= 0.05)
```

Now, we will create a new column `regulation` and assign values based on the filters.

```python
deseq['regulation'] = 'NS'
deseq.loc[upFilter, 'regulation'] = 'up-regulated'
deseq.loc[downFilter, 'regulation'] = 'down-regulated'
```

Now, we can use this column for `hue` in the `scatterplot`.

```python
sns.scatterplot(data= deseq, x='log2FoldChange', y='negLog10.padj', hue='regulation')
plt.xlabel('log2 Fold Change')
plt.ylabel('-log10 Adjusted p-value')
```

Typically, overexpressed genes are colored in red, and underexpressed genes are colored in green. The genes that are not significantly differentially expressed are colored in grey (convention used since microarray days).


Let's redo the plot with a different color palette.

```python
sns.scatterplot(data= deseq, x='log2FoldChange', y='negLog10.padj', hue='regulation', palette=['green','red', 'grey'])
plt.xlabel('log2 Fold Change')
plt.ylabel('-log10 Adjusted p-value')
```


If you want to draw lines separating the borders, you can use the `axhline` and `axvline` functions.

```python
sns.scatterplot(data= deseq, x='log2FoldChange', y='negLog10.padj', hue='regulation', palette=['green','red', 'grey'])
plt.xlabel('log2 Fold Change')
plt.ylabel('-log10 Adjusted p-value')
plt.axvline(-1.5,color="grey",linestyle="--")
plt.axvline(1.5,color="grey",linestyle="--")
plt.axhline(-np.log10(0.05),color="grey",linestyle="--")
```

If you want to move the legend outside the plot, you can use the `bbox_to_anchor` argument in the `legend` function.

```python
sns.scatterplot(data= deseq, x='log2FoldChange', y='negLog10.padj', hue='regulation', palette=['green','red', 'grey'])
plt.xlabel('log2 Fold Change')
plt.ylabel('-log10 Adjusted p-value')
plt.axvline(-1.5,color="grey",linestyle="--")
plt.axvline(1.5,color="grey",linestyle="--")
plt.axhline(-np.log10(0.05),color="grey",linestyle="--")
plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
```

you can also swap `sns.relplot` in place of `sns.scatterplot` to get similar results.



You might also want to label the points with gene names. You can use the `text` function to do this.
For this, we will create another column with gene names and use it to label the points.
We will only use top 5 significant genes for this example.

```python
topUp = deseq.loc[upFilter].nsmallest(5, 'log2FoldChange')
topDown = deseq.loc[downFilter].nsmallest(5, 'log2FoldChange')
```

Now, we can use the `text` function to label the points.

```python
sns.scatterplot(data= deseq, x='log2FoldChange', y='negLog10.padj', hue='regulation', palette=['green','red', 'grey'])
plt.xlabel('log2 Fold Change')
plt.ylabel('-log10 Adjusted p-value')
plt.axvline(-1.5,color="grey",linestyle="--")
plt.axvline(1.5,color="grey",linestyle="--")
plt.axhline(-np.log10(0.05),color="grey",linestyle="--")
plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
for i in range(5):
    plt.text(topUp['log2FoldChange'].iloc[i], topUp['negLog10.padj'].iloc[i], topUp['external_gene_name'].iloc[i], fontsize=8)
    plt.text(topDown['log2FoldChange'].iloc[i], topDown['negLog10.padj'].iloc[i], topDown['external_gene_name'].iloc[i], fontsize=8)
```

Additional customization can be done, but we will stop here and save the plot.

```python
plt.savefig('volcano_plot.png')
```



## Heatmap

Heatmaps are a great way to visualize the expression of genes across samples.

For this example, we will use the normalized counts for the top 10 differentially expressed genes from the above table. We will use the same filters we created earlier.

```python
topUp = deseq.loc[upFilter].nlargest(10, 'log2FoldChange')
topDown = deseq.loc[downFilter].nsmallest(10, 'log2FoldChange')
```

To merge these 2 dataframes:

```python
heatmapData = pd.concat([topUp, topDown])
```

Now, we will select only the columns we need for the heatmap.

```python
heatmapData = heatmapData[['external_gene_name', 'PLAC1.1KO', 'PLAC1.2KO', 'PLAC1.3KO', 'PLAC1.4KO', 'PLAC1.5KO', 'PLAC1.1WT', 'PLAC1.2WT', 'PLAC1.3WT', 'PLAC1.4WT', 'PLAC1.5WT']]
```

Looks like there is one `NaN` value in the data. We will exclude that row.

```python
heatmapData = heatmapData.dropna()
```

We can reindex the data frame for the gene column

```python
heatmapData = heatmapData.set_index('external_gene_name')
```

Now, we will use the `heatmap` function to plot the heatmap.

```python
sns.heatmap(heatmapData)
```

You can customize it with different color palettes, row and column labels, etc.

```python
sns.heatmap(heatmapData, cmap='coolwarm', annot=True, fmt=".2f")
plt.xlabel('Gene')
plt.ylabel('Sample')
```


Similar to heatmap, you can also use `clustermap` function to cluster the rows and columns. This can be useful to identify patterns in the data.

```python
sns.clustermap(heatmapData, z_score=0, cmap='coolwarm')
plt.xlabel('Gene')
plt.ylabel('Sample')
```

you can also add values to the heatmap.

```python
sns.clustermap(heatmapData, z_score=0, cmap='coolwarm', annot=True, fmt=".2f")
plt.xlabel('Gene')
plt.ylabel('Sample')
```

Let's save this plot.

```python
plt.savefig('heatmap.png')
```








Let's log transform the data for better visualization.

```python
sns.heatmap(np.log2(heatmapData), cmap='coolwarm', annot=True, fmt=".2f")
plt.xlabel('Gene')
plt.ylabel('Sample')
```

Let's save this plot.

```python
plt.savefig('heatmap.png')
```


## Gene expression plots


One common task in DE analysis is to plot the expression of genes across samples. This can be done using seaborn's point plot.

Note: you can also create various other plots like violin plot, box plot, etc. using seaborn, but for simplicity, we will use point plot here.

Previously, we generated the top 10 differentially expressed genes. We will use that data for this example.


```python
topUp = deseq.loc[upFilter].nlargest(10, 'log2FoldChange')
topDown = deseq.loc[downFilter].nsmallest(10, 'log2FoldChange')
```

We will filter to keep the required columns.

```python
topUp = topUp[['external_gene_name', 'PLAC1.1KO', 'PLAC1.2KO', 'PLAC1.3KO', 'PLAC1.4KO', 'PLAC1.5KO', 'PLAC1.1WT', 'PLAC1.2WT', 'PLAC1.3WT', 'PLAC1.4WT', 'PLAC1.5WT']]
topDown = topDown[['external_gene_name', 'PLAC1.1KO', 'PLAC1.2KO', 'PLAC1.3KO', 'PLAC1.4KO', 'PLAC1.5KO', 'PLAC1.1WT', 'PLAC1.2WT', 'PLAC1.3WT', 'PLAC1.4WT', 'PLAC1.5WT']]
```

we will reshape this data to long format.

```python
topUp = topUp.melt(id_vars='external_gene_name', var_name='Sample', value_name='Normalized expression')
topDown = topDown.melt(id_vars='external_gene_name', var_name='Sample', value_name='Normalized expression')
```

A 'condition' column identifying KO and WT samples will be added.

```python
topUp['condition'] = 'KO'
topDown['condition'] = 'KO'
filter = topUp['Sample'].str.contains('WT')
topUp.loc[filter, 'condition'] = 'WT'
topDown.loc[filter, 'condition'] = 'WT'
```

Drop columns with NaN values.

```python
topUp = topUp.dropna()
topDown = topDown.dropna()
```

Rename `external_gene_name` as simply 'Gene'.

```python
topUp = topUp.rename(columns={'external_gene_name': 'Gene'})
topDown = topDown.rename(columns={'external_gene_name': 'Gene'})
```

We now have the dataset suitable for plotting.

```python
g = sns.FacetGrid(topDown, col="Gene", col_wrap=4, height=2)
g.map(sns.pointplot, "condition", "Normalized expression", order=['KO', 'WT'])
```

We could make the y-axis free for each plot, so that we can visualize the difference better:

```python
g = sns.FacetGrid(topDown, col="Gene", col_wrap=4, height=2, sharey=False)
g.map(sns.pointplot, "condition", "Normalized expression", order=['KO', 'WT'])
```

the trend is much clearer now. You can also remove error bars and change color.

```python
g = sns.FacetGrid(topDown, col="Gene", col_wrap=4, height=2, sharey=False)
g.map(sns.pointplot, "condition", "Normalized expression", order=['KO', 'WT'], color=".3", errorbar=None)
```

For upregulated genes, we can do the same.

```python
g = sns.FacetGrid(topUp, col="Gene", col_wrap=4, height=2, sharey=False)
g.map(sns.pointplot, "condition", "Normalized expression", order=['KO', 'WT'], color=".3", errorbar=None)
```


If you prefer visualizing expression for each replicate, you can use `regplot` instead.

```python
g = sns.FacetGrid(topDown, col="Gene", col_wrap=4, height=2, sharey=False)
g.map(sns.regplot, 'condition', 'Normalized expression', fit_reg=False)
```


Other plots can be generated as well, but we will stop here and save the plots.

```python
g = sns.FacetGrid(topDown, col="Gene", col_wrap=4, height=2, sharey=False)
g.map(sns.pointplot, "condition", "Normalized expression", order=['KO', 'WT'], color=".3", errorbar=None)
g.savefig('gene_expression_downregulated.png')
```

```python
g = sns.FacetGrid(topUp, col="Gene", col_wrap=4, height=2, sharey=False)
g.map(sns.pointplot, "condition", "Normalized expression", order=['KO', 'WT'], color=".3", errorbar=None)
g.savefig('gene_expression_upregulated.png')
```

