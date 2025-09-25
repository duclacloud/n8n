# Example Data Files

This folder contains two CSV files with the ficticious volunteer data used in the course.

## Files Included

- `Volunteer-Index-Full.csv` - Complete volunteer dataset with 111 records
- `Volunteer-Index-Short.csv` - Abbreviated volunteer dataset with 9 records

Both files contain the same data structure with the following columns:

- `ID`: int
- `Full Name`: str
- `First Name`: str
- `Last Name`: str
- `Phone`: str
- `Email`: str
- `Events`: str
- `Manager`: str
- `Active`: bool

## How to Import into Google Sheets

Follow these steps to import both CSV files into a single Google Sheets document as separate sheets:

1. **Create a new Google Sheets document:**

   - Go to [Google Sheets](https://sheets.google.com)
   - Sign in with your Google account
   - Click "Blank" to create a new spreadsheet
   - Name your document "Volunteer Index"

2. **Import first file:**

   - Click "File" → "Import"
   - Select "Upload" and drag `Volunteer-Index-Short.csv` into the upload area
   - Choose "Insert new sheet(s)"
   - Click "Import data"

3. **Import second file:**

   - Repeat the process for `Volunteer-Index-Full.csv`

4. **Organize your sheets:**
   - Rename the sheets too "Full" and "Short" respectively

## About the Data

The data contained in both CSV files (`Volunteer-Index-Full.csv` and `Volunteer-Index-Short.csv`) is entirely fictitious and has been generated using artificial intelligence for demonstration and educational purposes only. Any resemblance to real persons, living or deceased, or actual events is purely coincidental. This data should not be used for any real-world volunteer management or contact purposes.

The phone numbers, email addresses, and personal information are completely fabricated and do not correspond to any real individuals or organizations.

## Usage Notes

- The "Full" dataset contains 111 volunteer records
- The "Short" dataset contains 9 volunteer records (a subset of the full dataset)
- Both files use the same data structure for consistency
- The data is designed to be used with n8n workflows and automation examples
- All email addresses use the placeholder domain `@example.com`
- All phone numbers follow the format `555-555-XXXX`
