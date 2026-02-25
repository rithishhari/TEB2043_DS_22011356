library(dplyr)
library(stringr)
library(lubridate)


user_home <- Sys.getenv("HOME")
if (user_home == "") user_home <- Sys.getenv("USERPROFILE") # For Windows

file_path <- file.path("C:/Users/User/Downloads/UncleanDataset.csv")

# Read the file
if (!file.exists(file_path)) {
  stop("File not found! Please check if 'UncleanDataset.csv' is in your Downloads folder.")
}

raw_lines <- readLines(file_path, warn = FALSE, encoding = "latin1")
raw_lines <- iconv(raw_lines, from = "latin1", to = "UTF-8", sub = "")
raw_lines <- raw_lines[nzchar(trimws(raw_lines))] # drop blank lines

col_names <- c("Student_ID", "First_Name", "Last_Name",
               "Age", "Gender", "Course",
               "Enrollment_Date", "Total_Payments")

# --- 2. DETECT AND SEPARATE PIPE vs CSV ROWS ---
# FIXED: Using fixed = TRUE because '|' is a regex special character
is_pipe <- grepl("|", raw_lines[-1], fixed = TRUE)

# --- Parse pipe-delimited rows ---
parse_pipe <- function(line) {
  # Keep only the first comma-block in case of self-duplicates
  first_block <- strsplit(line, ",", fixed = TRUE)[[1]][1]
  fields <- trimws(strsplit(first_block, "|", fixed = TRUE)[[1]])
  length(fields) <- 8  # Ensure exactly 8 columns
  fields
}

pipe_lines <- raw_lines[-1][is_pipe]
if (length(pipe_lines) > 0) {
  pipe_rows <- do.call(rbind, lapply(pipe_lines, parse_pipe))
  df_pipe <- as.data.frame(pipe_rows, stringsAsFactors = FALSE)
  colnames(df_pipe) <- col_names
} else {
  df_pipe <- data.frame(matrix(ncol = 8, nrow = 0))
  colnames(df_pipe) <- col_names
}

# --- Parse comma-delimited rows ---
csv_lines <- raw_lines[-1][!is_pipe]
if (length(csv_lines) > 0) {
  # Prepend header for read.csv to correctly parse quoted numbers
  csv_text <- c(paste(col_names, collapse = ","), csv_lines)
  df_csv <- read.csv(
    textConnection(csv_text),
    header = TRUE,
    stringsAsFactors = FALSE,
    na.strings = c("", "NA"),
    strip.white = TRUE,
    colClasses = "character",
    fill = TRUE,   # allow short rows
    flush = TRUE   # ignore extra columns
  )
  df_csv <- df_csv[, col_names]  # Keep only expected columns
} else {
  df_csv <- data.frame(matrix(ncol = 8, nrow = 0))
  colnames(df_csv) <- col_names
}

# --- Combine both PIPE and CSV data ---
df_raw <- bind_rows(df_pipe, df_csv)
df_raw[df_raw == ""] <- NA  # Convert blanks to NA

# 3. Fix cases where Gender and Age are combined (e.g., "M 25")

mixed <- !is.na(df_raw$Gender) & grepl("^[MFmf]\\s+\\d+$", df_raw$Gender)
df_raw$Age[mixed] <- regmatches(df_raw$Gender[mixed], regexpr("\\d+", df_raw$Gender[mixed]))
df_raw$Gender[mixed] <- substr(trimws(df_raw$Gender[mixed]), 1, 1)


# 4. Fix cases where Last_Name is a duplicate of First_Name

same_name <- !is.na(df_raw$First_Name) & !is.na(df_raw$Last_Name) &
  trimws(df_raw$First_Name) == trimws(df_raw$Last_Name)
df_raw$Last_Name[same_name] <- NA


# 5. Split full names in First_Name when Last_Name is missing

full_in_first <- !is.na(df_raw$First_Name) &
  grepl("\\s+", trimws(df_raw$First_Name)) &
  is.na(df_raw$Last_Name)
if (any(full_in_first)) {
  split_names <- str_split_fixed(trimws(df_raw$First_Name[full_in_first]), "\\s+", 2)
  df_raw$First_Name[full_in_first] <- split_names[, 1]
  df_raw$Last_Name[full_in_first] <- split_names[, 2]
}

# 6. Convert Student_ID to integer; non-numeric -> NA

df_raw$Student_ID <- suppressWarnings(as.integer(trimws(df_raw$Student_ID)))

# 7. Clean Age: remove non-digits and set unrealistic ages (<15 or >70) to NA

df_raw$Age <- suppressWarnings(as.integer(gsub("[^0-9]", "", df_raw$Age)))
df_raw$Age[!is.na(df_raw$Age) & (df_raw$Age < 15 | df_raw$Age > 70)] <- NA

# 8. Standardize Gender values to "M" or "F"; invalid -> NA

df_raw$Gender <- toupper(trimws(df_raw$Gender))
df_raw$Gender[!df_raw$Gender %in% c("M", "F")] <- NA

# 9. Correct Course names and remove invalid entries

fix_course <- function(x) {
  x <- trimws(x)
  x <- ifelse(grepl("^machine learn", x, ignore.case = TRUE), "Machine Learning", x)
  x <- ifelse(grepl("^web dev", x, ignore.case = TRUE), "Web Development", x)
  x <- ifelse(grepl("^data sci", x, ignore.case = TRUE), "Data Science", x)
  x <- ifelse(grepl("^data anal", x, ignore.case = TRUE), "Data Analysis", x)
  x <- ifelse(grepl("^cyber", x, ignore.case = TRUE), "Cyber Security", x)
  x[x == "4" | is.na(x)] <- NA
  x
}
df_raw$Course <- fix_course(df_raw$Course)

# 10. Clean Total_Payments: remove non-numeric characters and convert to numeric

df_raw$Total_Payments <- suppressWarnings(
  as.numeric(gsub("[^0-9.]", "", trimws(df_raw$Total_Payments)))
)

# 11. Parse Enrollment_Date in multiple formats; flag unrealistic years

parse_dates <- function(x) {
  x <- trimws(x)
  x[x %in% c("NA", "N/A", "")] <- NA
  d <- parse_date_time(x, orders = c("Ymd", "dmy", "dmY", "d-b-y", "d-b-Y"), quiet = TRUE)
  as.Date(d)
}
df_raw$Enrollment_Date <- parse_dates(df_raw$Enrollment_Date)
current_year <- as.integer(format(Sys.Date(), "%Y"))
bad_year <- !is.na(df_raw$Enrollment_Date) &
  (as.integer(format(df_raw$Enrollment_Date, "%Y")) < 2000 |
     as.integer(format(df_raw$Enrollment_Date, "%Y")) > current_year)
df_raw$Enrollment_Date[bad_year] <- NA


# 12. Drop rows that are completely empty (no ID, name, age, or payment)

df_clean <- df_raw %>%
  filter(!(is.na(Student_ID) & is.na(First_Name) & is.na(Last_Name) &
             is.na(Age) & is.na(Total_Payments)))


# 13. Remove duplicates; keep first occurrence of Student_ID

df_clean <- df_clean %>%
  distinct() %>%
  mutate(.row_order = row_number()) %>%
  arrange(.row_order) %>%
  group_by(Student_ID) %>%
  slice(1) %>%
  ungroup() %>%
  select(-.row_order)


# 14. Assign sequential IDs to rows missing Student_ID

missing_id <- is.na(df_clean$Student_ID)
if (any(missing_id)) {
  max_id <- max(df_clean$Student_ID, na.rm = TRUE)
  df_clean$Student_ID[missing_id] <- seq(max_id + 1, max_id + sum(missing_id))
}

# 15. Format names, date, and sort by Student_ID

df_clean <- df_clean %>%
  arrange(Student_ID) %>%
  mutate(
    Student_ID = as.integer(Student_ID),
    First_Name = str_to_title(trimws(First_Name)),
    Last_Name = str_to_title(trimws(Last_Name)),
    Enrollment_Date = format(Enrollment_Date, "%Y-%m-%d")
  )


# 16. Normalize Total_Payments for courses with high currency scale 

clean_courses <- c("Data Science", "Machine Learning", "Web Development")
clean_median <- median(df_clean$Total_Payments[df_clean$Course %in% clean_courses], na.rm = TRUE)

course_medians <- tapply(df_clean$Total_Payments, df_clean$Course, median, na.rm = TRUE)
high_scale_courses <- names(course_medians[!is.na(course_medians) & course_medians > 5000])

for (crs in high_scale_courses) {
  idx <- !is.na(df_clean$Course) & df_clean$Course == crs
  min_val <- min(df_clean$Total_Payments[idx], na.rm = TRUE)
  if (min_val > 0) {
    scale <- clean_median / min_val
    df_clean$Total_Payments[idx] <- round(df_clean$Total_Payments[idx] * scale, 2)
  }
}


blank_idx <- is.na(df_clean$Course)
blank_vals <- df_clean$Total_Payments[blank_idx]
if (length(blank_vals) > 0 && !all(is.na(blank_vals)) && median(blank_vals, na.rm = TRUE) > 5000) {
  min_blank <- min(blank_vals, na.rm = TRUE)
  scale <- clean_median / min_blank
  df_clean$Total_Payments[blank_idx] <- round(df_clean$Total_Payments[blank_idx] * scale, 2)
}

# 17. Dynamically cap extreme Total_Payments per course using mean + 3*SD
df_clean <- df_clean %>%
  group_by(Course) %>%
  mutate(
    course_mean = mean(Total_Payments, na.rm = TRUE),
    course_sd   = sd(Total_Payments, na.rm = TRUE),
    course_cap  = course_mean + 3 * course_sd,  # dynamic cap for outliers
    Total_Payments = if_else(
      !is.na(Total_Payments) & Total_Payments > course_cap,
      median(Total_Payments[!is.na(Total_Payments) & Total_Payments <= course_cap]),
      Total_Payments
    )
  ) %>%
  select(-course_mean, -course_sd, -course_cap) %>%
  ungroup()


# 18. Impute missing values with logical values
#     - Age: mean
#     - Gender: mode
#     - Course: mode
#     - Enrollment_Date: median date
#     - Total_Payments: median

mode_val <- function(x) {
  x <- x[!is.na(x)]
  names(sort(table(x), decreasing = TRUE))[1]
}

mean_age <- as.integer(round(mean(df_clean$Age, na.rm = TRUE)))
mode_gender <- mode_val(df_clean$Gender)
mode_course <- mode_val(df_clean$Course)
valid_dates <- sort(df_clean$Enrollment_Date[!is.na(df_clean$Enrollment_Date)])
median_date <- valid_dates[ceiling(length(valid_dates)/2)]
median_payment <- median(df_clean$Total_Payments, na.rm = TRUE)

df_clean <- df_clean %>%
  mutate(
    Age = if_else(is.na(Age), mean_age, Age),
    Gender = if_else(is.na(Gender), mode_gender, Gender),
    Course = if_else(is.na(Course), mode_course, Course),
    Enrollment_Date = if_else(is.na(Enrollment_Date), median_date, Enrollment_Date),
    Total_Payments = if_else(is.na(Total_Payments), median_payment, Total_Payments)
  )

# 19. Save cleaned dataset to your Downloads folder
# We use the same path logic to make sure it hits the right folder
user_home <- Sys.getenv("HOME")
if (user_home == "") user_home <- Sys.getenv("USERPROFILE")

output_path <- file.path("C:/Users/User/Downloads/cleanDataset.csv")

write.csv(df_clean, file = output_path, row.names = FALSE, na = "")

# Print a success message so you know it worked!
cat("Success! Your cleaned file is saved at:", output_path)
