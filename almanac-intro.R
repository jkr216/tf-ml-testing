# devtools::install_github("DavisVaughan/almanac")
# devtools::install_github("DavisVaughan/slide")

library(almanac)
library(slide)
library(dplyr)
library(lubridate)

index <- as.Date("2019-08-29") + c(0, 1, 5, 6, 7)
sales <- rnorm(length(index), mean = 10000, sd = 1000)

company <- tibble(sales = sales, index = index)

# Look back 2 "rows"
company <- company %>%
  mutate(
    roll_by_row = slide_dbl(sales, mean, .before = 2)
  )

company

# You might be used to `partial = FALSE` being the default from rollapply()
company %>%
  mutate(
    roll_by_row = slide_dbl(sales, mean, .before = 2, .complete = TRUE)
  )

# Look back 2 days
company <- company %>%
  mutate(
    roll_by_day = slide_index_dbl(sales, index, mean, .before = days(2))
  )

company

company %>%
  mutate(
    wday = wday(index, TRUE)
  )

# ------------------------------------------------------------------------------

# Recurrence rule:
# - Define how to "recur"
# - Start with a frequency: daily, weekly, monthly, yearly...
# - Add extra rules: On 5th day of the month, on weekends, ...

since <- min(company$index)

rrule <- weekly(since = since) %>%
  recur_on_weekends()

# You can interrogate a recurrence rule to get "event" dates from it

weekends <- sch_seq(from = since, to = since + 30, rrule)
wday(weekends, label = TRUE)

# More importantly, you can use these to "adjust" dates as you move forward

company

friday <- company$index[2]
friday

sch_step(x = friday, n = 1, schedule = rrule)

# ------------------------------------------------------------------------------

starts <- sch_step(x = company$index, n = -2, schedule = rrule)
stops <- company$index

company %>% mutate(
  roll_by_bday = slide_between_dbl(sales, index, .starts = starts, .stops = stops, mean)
)

# ------------------------------------------------------------------------------

on_third_monday <- monthly() %>%
  recur_on_wday("Monday", nth = 3)

sch_seq("2000-01-01", Sys.Date(), on_third_monday)


