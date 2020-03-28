# Filter the Swedish cases from an ECDC csv file and save in two csv files,
# one with all Swedish cases found and one that starts right before the first 
# case. The latter might be handy to cut down on computational cost of models.
using DataFrames, CSV

const ECDC_FILE = if length(ARGS) == 1
    ARGS[1]
else
    "covid19_worldwide_cases_ecdc_20200328_1036.csv"
end

df = CSV.read(ECDC_FILE)
println("Found $(nrow(df)) entries in file $ECDC_FILE")

# Get date and timestamp from orig file name
m = match(r"_(\d{8}_\d{4})\.csv$", ECDC_FILE)
const OrigTimestamp = m[1]

swedish_entries = (df.countriesAndTerritories .== "Sweden")

dfseall = df[swedish_entries, :]

# To sort on date we first parse as Julia date. 
using Dates
const dateFormat = DateFormat("dd/mm/yyy")
dfseall.juliaDate = Date.(dfseall.dateRep, dateFormat)
sort!(dfseall, [:juliaDate])

# Add some derived metrics:

# 1. Cumulative number of cases
dfseall.TotalCases = cumsum(dfseall.cases)

# 2. Cumulative number of deaths
dfseall.TotalDeaths = cumsum(dfseall.deaths)

# 3. Incidence proportion based on population 2018 in ECDC data:
dfseall.Incidence2018 = round.(100.0 * dfseall.TotalCases ./ dfseall.popData2018, digits = 5)

# 4. Incidence proportion based on population 2020 according to:
# https://www.worldometers.info/world-population/sweden-population/
# which on 2020-03-28 at 11:20 was 10,082,924
SwedishPopulation20200328_1120 = 10_082_924
dfseall.Incidence2020 = round.(100.0 * dfseall.TotalCases ./ SwedishPopulation20200328_1120, digits = 5)

# 5. crude Case Fatality Rate (CFR):
protecteddiv(a, b) = (b == 0.0) ? 0.0 : (a/b)
dfseall.cCFR = round.(100.0 .* protecteddiv.(dfseall.TotalDeaths, dfseall.TotalCases), digits = 5)

function save_to_csv(prefix, df)
    filename = prefix * "_" * OrigTimestamp * ".csv"
    println("Writing $(nrow(df)) entries to file $filename")
    CSV.write(filename, df)
end

# Save all Swedish cases:
save_to_csv("all_swedish_cases", dfseall)

# Find and save one which starts at day of first case, first ensure date sorted:
startrow = first(findall(row -> dfseall.cases[row] >= 1, 1:nrow(dfseall)))

# We start 3 days before the first case
selecfromrow = max(1, startrow-3)
dfseselected = dfseall[selecfromrow:end, names(df)]

# Now save these selected ones:
save_to_csv("selected_swedish_cases", dfseselected[:, names(df)])
