
# A. Create Smaller Dataset -----------------------------------------------


# --- Packages ---
library(readxl)
library(writexl) # to save smaller file

# --- Step 1: Load only the needed columns from the big GHED file ---
path_big <- "./input/GHED_data.XLSX"       # change if your file is in another folder
path_small <- "./output/GHED_small.xlsx"    # this will be the lighter version we create

# Read full data (only the 'Data' sheet)
df <- read_excel(path_big, sheet = "Data")

# --- Step 2: Keep only the columns we need ---
df_small <- df[, c("code", "location", "year", "gghed_pc_usd", "ext_pc_usd")]

# --- Step 3: Save to a new smaller file ---
write_xlsx(df_small, path_small)

cat("✅ Done! Saved smaller dataset as:", path_small, "\n")
