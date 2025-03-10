import pandas as pd

# Load the datasets
users_df = pd.read_csv("/mnt/data/users.csv")
transactions_df = pd.read_csv("/mnt/data/transactions.csv")
products_df = pd.read_csv("/mnt/data/products.csv")

# Check for missing values in each dataset
def missing_values(df, name):
    print(f"Missing values in {name} dataset:")
    print(df.isnull().sum())
    print("-" * 40)

missing_values(users_df, "Users")
missing_values(transactions_df, "Transactions")
missing_values(products_df, "Products")

# Check data types and basic information
def dataset_info(df, name):
    print(f"Dataset: {name}")
    print(df.info())
    print("-" * 40)

dataset_info(users_df, "Users")
dataset_info(transactions_df, "Transactions")
dataset_info(products_df, "Products")

# Display sample rows
def display_samples(df, name):
    print(f"Sample data from {name} dataset:")
    print(df.head())
    print("-" * 40)

display_samples(users_df, "Users")
display_samples(transactions_df, "Transactions")
display_samples(products_df, "Products")

# Identify potential data quality issues
# Users dataset
print("Potential issues in Users dataset:")
if users_df['BIRTH_DATE'].isnull().sum() > 0:
    print(f"- Missing BIRTH_DATE: {users_df['BIRTH_DATE'].isnull().sum()} records")
if users_df['STATE'].isnull().sum() > 0:
    print(f"- Missing STATE: {users_df['STATE'].isnull().sum()} records")
if users_df['LANGUAGE'].isnull().sum() > 0:
    print(f"- Missing LANGUAGE: {users_df['LANGUAGE'].isnull().sum()} records")
if users_df['GENDER'].isnull().sum() > 0:
    print(f"- Missing GENDER: {users_df['GENDER'].isnull().sum()} records")
print("-" * 40)

# Transactions dataset
print("Potential issues in Transactions dataset:")
if transactions_df['BARCODE'].isnull().sum() > 0:
    print(f"- Missing BARCODE: {transactions_df['BARCODE'].isnull().sum()} records")
if transactions_df['FINAL_QUANTITY'].str.lower().str.contains("zero").sum() > 0:
    print(f"- 'zero' values in FINAL_QUANTITY: {transactions_df['FINAL_QUANTITY'].str.lower().str.contains('zero').sum()} records")
print("-" * 40)

# Products dataset
print("Potential issues in Products dataset:")
if products_df['CATEGORY_4'].isnull().sum() > 0:
    print(f"- Missing CATEGORY_4: {products_df['CATEGORY_4'].isnull().sum()} records")
if products_df['MANUFACTURER'].str.contains("PLACEHOLDER", na=False).sum() > 0:
    print(f"- Placeholder manufacturer data: {products_df['MANUFACTURER'].str.contains('PLACEHOLDER', na=False).sum()} records")
if products_df['BRAND'].isnull().sum() > 0:
    print(f"- Missing BRAND: {products_df['BRAND'].isnull().sum()} records")
print("-" * 40)