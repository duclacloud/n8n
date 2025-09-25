# n8n Workflows - AI Agents and Automation

This folder contains the built-out n8n workflows from the course. These workflows demonstrate how to create AI agent automation systems with Google Sheets, OpenAI, and Slack integrations using MCP.

## Workflow Files

- `Volunteer_Lookup.json` - Main AI Agent workflow from the course that performs volunteer lookups
- `Google_Sheets_MCP.json` - Custom MCP server providing Google Sheets integration (dependency for `Volunteer_Lookup`)
- `Row_lookup.json` - Google Sheets row lookup and custom filtering utility workflow (dependency for `Google_Sheets_MCP` and `Built_Out_Automation_Flow`)
- `Built_Out_Automation_Flow.json` - Optional: Multi-agent workflow with more advanced filtering and no MCP integration.

## How to Import into n8n

You can place these workflows in either:

- **Personal area** - For individual use and testing
- **Project** - For team collaboration and shared access

### Steps to Import Workflows

1. **Open your n8n instance**

2. **Navigate to the desired location (Personal or Project)**

3. **Create a new blank workflow for each JSON file:**

   - Name each workflow to match the JSON file:
     - `Volunteer_Lookup`
     - `Google_Sheets_MCP`
     - `Row_lookup`
     - `Built_Out_Automation_Flow` (optional)

4. **Import the JSON files:**

   - Click on the "···" menu button in the top right corner of the workflow editor
   - In the drop-down, select "Import from file"
   - Select the corresponding JSON file from this folder

5. **Import in the following order to respect dependencies:**

   - `Row_lookup.json` (first)
   - `Google_Sheets_MCP.json` (second)
   - `Volunteer_Lookup.json` (main workflow)
   - `Built_Out_Automation_Flow.json` (optional reference)

> [!IMPORTANT]  
> These workflows will not work out of the box! To get them to work you need to set up the required accounts, authentication, and sample data as described below.

## Requirements

To use these workflows as provided, you need Google, OpenAI, and Slack accounts. The authentication process for each service is covered in detail in the course.

1. **Google Sheets Account**

   - _NOTE: Using a free account dedicated to this project is recommended_
   - Create a Google account at [Google](https://accounts.google.com/signup)
   - See `example-data/README.md` for instructions on how to set up the data

2. **OpenAI API Account**

   - Sign up for OpenAI API access at [OpenAI](https://platform.openai.com/signup)
   - Create a new Project
   - In the Project, create a new API key

3. **Slack Workspace**

   - _NOTE: Using a free Slack workspace dedicated to this project is recommended_
   - Sign up for a Slack account at [Slack](https://slack.com/get-started)
   - Setup instructions for the Slack bot is covered in detail in the course

## Sample Data

Sample volunteer data is available in the `example-data/` folder:

- `Volunteer-Index-Full.csv` - Complete dataset
- `Volunteer-Index-Short.csv` - Abbreviated dataset for testing

See `example-data/README.md` for instructions on how to set up the data.
