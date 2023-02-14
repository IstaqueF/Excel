#Title: Investigating covid virus trend 
#We will analyse Which countries have had the highest number of positive cases against the number of tests?

library(readr)

#Load the file CSV file 
covid_df <- read_csv("covid19.csv")

#Determine the dimension of dataframe 
dim(covid_df)

#Determine column names and store it in variables 
vector_cols <- colnames(covid_df)

#Display the content of vector_cols and determine the data structure 
print(vector_cols)
class(vector_cols)

#Display the first few rows of dataset
head(covid_df)

#Display summary of dataset using glimse( ) from tibble package 
install.packages("tibble")
library(tibble)
glimpse(covid_df)

#filter the rows with Province_state = "All States" and remove Provice_state column
library(dplyr)
covid_df_all_states <-covid_df %>% filter(Province_State == "All States") %>% select(-Province_State)
covid_df_all_states

#Select the columns related to daily measures and store it in variable 
covid_df_all_states_daily <- select(covid_df,Date,Country_Region, active, hospitalizedCurr, daily_tested, daily_positive)
print(covid_df_all_states_daily)

#Summarize the dataframe by computing the sum of tested(DESC),positive,active and hospitalized cases grouped by country
covid_df_all_states_daily_sum <- covid_df_all_states_daily %>% group_by(Country_Region) %>% summarize(tested = sum(daily_tested),positive = sum(daily_positive),active = sum(active),hospitalized =sum(hospitalizedCurr))%>%arrange(-tested)
print(covid_df_all_states_daily_sum)                                                                              

#Extract the top 10 rows
covid_top_10 <- head(covid_df_all_states_daily_sum,10)
print(covid_top_10)

#Create vectors for each column of the covid_top_10 dataframe 
countries <- covid_top_10$Country_Region
tested_cases <- covid_top_10$tested
positive_cases <- covid_top_10$positive
active_cases <- covid_top_10$active
hospitalized_cases <- covid_top_10$hospitalized

#name the above vectors element with country names vector
names(tested_cases) <- countries
names(positive_cases) <-  countries
names(active_cases) <- countries
names(hospitalized_cases) <- countries

#identify the top 3 positive against tested cases 
positive_cases/tested_cases
positive_tested_top_3 <- c("United Kingdom"=0.113260617,"United States"=0.106979446,"Turkey"=0.080711720)
print(positive_tested_top_3)

#keep all the information of the top 3 countries by creating a matrix from the vectors
united_kingdom <- c(0.11, 1473672, 166909, 0, 0)
united_states <- c(0.10, 17282363, 1877179, 0, 0)
turkey <- c(0.08, 2031192, 163941, 2980960, 0)
covid_mat <- rbind(united_kingdom,united_states,turkey)
colnames(covid_mat) <- c("Ratio", "tested", "positive", "active", "hospitalized")
print(covid_mat)

question <- "Which countries have had the highest number of positive cases against the number of tests?"
answer <- c("Positive tested cases" = positive_tested_top_3)
answer

#Create list to contain the data structures created above 
Datasets <- list("Original"= covid_df,"allstates"= covid_df_all_states, "daily"= covid_df_all_states_daily,"top10"= covid_top_10)
Matrices <- list(covid_mat)
vectors <- list(vector_cols,countries)

data_structure_list <- list("Dataframe"=Datasets,"Matrix"= Matrices,"vector"=vectors)

covid_analysis_list <- list(question,answer,data_structure_list)
covid_analysis_list

#From the Matrix we can see the top 3 countries with highest tested case during that time period. Alongside the ratios the relevant values have been included in the Matrix