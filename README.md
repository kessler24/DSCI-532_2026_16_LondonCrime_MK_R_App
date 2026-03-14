# London Crime Dashboard (R Shiny)

An interactive dashboard for exploring crime trends across London boroughs from 2008–2016. Compare two boroughs side-by-side, filter by year range, and visualize crime breakdowns by type.
View the deployment at https://019cea84-7aba-62e5-638b-25f4ec97d3c7.share.connect.posit.cloud/

## Installation

Make sure you have R installed, then install the required packages from the R console:

```r
install.packages(c("shiny", "bslib", "dplyr", "plotly"))
```

## Data

The app reads from `data/raw/LondonCrimeData.csv`. Ensure this file is present at that relative path before running.

## Running the App

From the R console, set your working directory to the project root and run:

```r
shiny::runApp("app.R")
```

Or open `app.R` in RStudio and click **Run App**.

## Usage

- **Year Range** — filter data to a specific range of years (2008–2016)
- **Borough 1 / Borough 2** — select two London boroughs to compare
- **Restore Defaults** — reset all filters to their original values

The value boxes at the top show the average monthly crime rate for each selected borough and for London as a whole. The stacked bar chart below breaks down total crimes by type for the two selected boroughs.

## Authors

This app is an R conversion of the Python Shiny App, London Crime Dashboard, created by Molly Kessler, Yasaman Baher, Justin Mak. This R conversion was created by Molly Kessler.
