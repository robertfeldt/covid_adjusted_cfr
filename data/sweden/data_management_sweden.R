# Setup ----
source("setup.R")

# Controls ----

# Apply to selected_swedish_cases_20200328_1036.csv for now so use its dates:
day_start = as.Date("2020-01-29")
day_data = as.Date("2020-01-30")
day_max = as.Date("2020-03-28")
day_quarantine = as.Date("2020-03-16") # Sweden not yet in quarantine. Take day of 500 people max restriction, for now:

## Age distribution in Italy for 9 age classes ----

age_dist = read_excel("data/age_structure.xlsx") %>%
  filter(country=="Sweden") %>%
  gather("age","n",3:23) %>%
  mutate(n=as.numeric(n),age2=c(0,0,10,10,20,20,30,30,40,40,50,50,60,60,70,70,80,80,80,80,80)) %>%
  group_by(age2) %>%
  summarise(n=sum(n)) %>%
  pull(n)
age_dist = age_dist/sum(age_dist)

# Population in Sweden, source:
# https://www.worldometers.info/world-population/sweden-population/
# which on 2020-03-28 at 11:20 was 10,082,924
pop_t = 10.082924e6

# Eurostat 2018:
#pop_t = 10.183175e6

## Case incidence in Sweden up to 2020-03-28 from ECDC
sweden_data_28march = read.csv("data/sweden/selected_swedish_cases_20200328_1036.csv") %>%
  tbl_df() %>%
  mutate(date=ymd(paste("2020",month,day,sep="-"))) %>%
  filter(date>=day_data,date<=day_max)
incidence_cases = pull(sweden_data_28march,cases)

ggplot(sweden_data_28march) +
  geom_col(aes(x=date,y=cases))

## Deaths incidence in Sweden up to 2020-03-28 from ECDC
incidence_deaths = pull(sweden_data_28march,deaths)

ggplot(sweden_data_28march) +
  geom_col(aes(x=date,y=deaths))


## Age distribution of cases in Sweden up to 2020-03-28 taken from graphs
## linked to by Folkhalsomyndigheten:
# https://experience.arcgis.com/experience/09f821667ce64bf7be6f9f87457ed9aa
# I merged the 80-89 and 90+ categories with data in the graph:
#  80-89: 331, 47
#  90+: 157, 18
# and entered the row:
#  80,488,65,
age_distributions_cases_deaths_28march = read.csv("data/sweden/age_distributions_cases_deaths_28march.csv") %>%
  tbl_df()

cases_tmax = pull(age_distributions_cases_deaths_28march,cases)
prop_cases_tmax = cases_tmax / sum(cases_tmax)

mort_tmax = pull(age_distributions_cases_deaths_28march,deaths)
prop_mort_tmax = mort_tmax / sum(mort_tmax)
