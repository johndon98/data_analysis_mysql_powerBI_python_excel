This file contains information on how to replicate the results of my master thesis titled, 
"The Economic Impact of ESG ratings: A replication study estimating dynamic treatment effects in presence of treatment effect heterogeneity"

------------------------

Note: Please replace the file paths in .do files and notebooks according to your local directory setup.
Note: The regression outputs from IW estimation are manually copied onto .xlsx files since esttab/ outreg did not work on the output from the "eventstudyinteract" library. 

General Structure:

1. All data cleaning/ merging is done in python notebooks "Fund_holdings_and_MSCI_ratings", "Fund_holdings_and_Refinitiv_ratings", "Fund_holdings_and_MSCI_ratings_excluding_index_funds_ETF" and "esg_weight_contsruction".

2. The final dataframes are exported as .dta files (found in STATA dta files) and used to run regressions on STATA using .do files (found in STATA do files).

3. STATA regression outputs are stored as .csv/.xlsx files and used as input for the figures in "figures_master_thesis" notebook.

------------------------

1.In order to run the "python_notebooks", one needs to provide the files in the "data" folder as input.

2.In order to run the "STATA do files", one needs to provide the files in the "STATA dta files" folder as input.

3."Figures and tables" contain all the necessary data inputs each from MSCI and Refinitiv needed to run the "figures_master_thesis" notebook.
   All figures in the "figures_master_thesis" notebook are based on the regression outputs from STATA, stored in .csv/.xlsx file formats.
   The "Tables" folder contains files used to build all the tables in the thesis.

------------------------

Fund and ESG dataframe construction:


All fund related input data can be found in "CRSP fund data" folder.

To build a dataframe one needs to merge "fund_hdr", "fund_style_equity_only" and "holdings data" according to the steps in "Fund_holdings_and_MSCI_ratings" or "Fund_holdings_and_Refinitiv_ratings" notebooks for MSCI and Refinitiv data respectively. 

Use "sec_header" and "cusips_9_overall_redone" to obtain a common key/link (i.e., cusips/ ISIN's) to merge with MSCI and Refinitiv ESG data.

------------------------


In case of further questions/ feedback, please feel free to contact me at johndoncy98@gmail.com or j.doncy@campus.lmu.de
