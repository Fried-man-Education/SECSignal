# SECSignal
AI-driven insights and analysis on SEC filings, empowering investors with concise financial intelligence

## Homepage

- **Search Bar**: Allows users to search for any publicly traded company by name or ticker symbol.
  - https://www.sec.gov/Archives/edgar/cik-lookup-data.txt
  - https://www.sec.gov/files/company_tickers.json
- **Featured Companies**: Showcase trending companies, perhaps those with recent major filings or significant market news.
  - https://finnhub.io/docs/api/
  - https://www.alphavantage.co
- **Latest Filings**: Display the most recent 10-Q and 10-K filings across all companies.
- **Other Data**
  - [Market Status](https://finnhub.io/docs/api/market-status)
  - [Market Holiday](https://finnhub.io/docs/api/market-holiday)
  - [IPO Calendar](https://finnhub.io/docs/api/ipo-calendar)
  - [FDA Committee Meeting Calendar](https://finnhub.io/docs/api/fda-committee-meeting-calendar)

## Company Profile Page

- **Company Overview**: 
  - Logo, name, ticker symbol, and a brief description.
  - Current stock price, market cap, and other key metrics (sourced from stock market APIs).
- **Filings Section**: 
  - List of all 10-Q and 10-K filings, sorted by date.
  - Each filing has a summary card showing key insights (e.g., sentiment analysis result, major financial changes).
  - Clicking on a filing opens a detailed view with deeper insights and visualizations.
- **Trends & Analysis**:
  - Interactive charts showing financial trends over time.
  - Sentiment analysis results over consecutive filings.
  - Risk heatmaps and profiles.
- **Bookmark Option**: Allows users to bookmark the company for easy access and notifications.
- **Other Data**
  - [Basic Financials](https://finnhub.io/docs/api/market-status](https://finnhub.io/docs/api/company-basic-financials)
  - [Insider Transactions](https://finnhub.io/docs/api/market-holiday](https://finnhub.io/docs/api/insider-transactions)
  - [Insider Sentiment](https://finnhub.io/docs/api/insider-sentiment)
  - [Financials As Reported](https://finnhub.io/docs/api/insider-sentiment](https://finnhub.io/docs/api/financials-reported)
  - [SEC Filings](https://finnhub.io/docs/api/filings)
  - [Recommendation Trends](https://finnhub.io/docs/api/recommendation-trends)
  - [Earnings Surprises](https://finnhub.io/docs/api/company-earnings)
  - [Earnings Calendar](https://finnhub.io/docs/api/earnings-calendar)
  - [Quote](https://finnhub.io/docs/api/quote)
  - [USPTO Patents](https://finnhub.io/docs/api/stock-uspto-patent)
  - [H1-B Visa Application](https://finnhub.io/docs/api/stock-visa-application)
  - [Senate Lobbying](https://finnhub.io/docs/api/stock-lobbying)
  - [USA Spending](https://finnhub.io/docs/api/stock-usa-spending)

## Detailed Filing View

- **Document Viewer**: Displays the original SEC filing document.
- **Extracted Data Panel**: Shows extracted data points like revenue, profit, debt, etc.
- **Sentiment Analysis Result**: Visual indicator (e.g., a meter or graph) showing the sentiment of the filing.
- **Risk Factors**: Highlighted and categorized risks extracted from the filing.

## User Profile & Settings

- **Bookmarked Companies**: List of companies the user has bookmarked.
- **Notification Settings**: 
  - Toggle email notifications on/off.
  - Choose the frequency of notifications (e.g., real-time, daily digest).
  - Customize the type of notifications (e.g., only major filings, any company news).
- **User Preferences**: Customize visual themes, data display preferences, etc.

## Additional Features

- **Industry Analysis**: Allow users to view industry-wide trends and benchmarks.
- **Competitor Comparison**: Side-by-side comparison of two or more companies.
- **News & Alerts Section**: Display relevant news articles or analyst reports related to the company.

## Backend Components

- **Data Collection & Storage**: Integrate with the SEC's EDGAR database and stock market APIs. Store data efficiently for quick retrieval.
- **AI/ML Engine**: Process filings for sentiment analysis, risk extraction, and trend recognition. Continuously update and refine models.
- **Notification System**: Send out email push notifications based on user preferences.

## User Experience

The design should prioritize ease of use, with a clean and intuitive interface. Visual aids like charts, heatmaps, and icons can make the data more digestible. Tooltips and help sections can guide users unfamiliar with financial jargon.

Security measures such as encryption and two-factor authentication should be implemented to protect user data and preferences.

- [IBM Plex Sans](https://fonts.google.com/specimen/IBM+Plex+Sans)
- Accent: #345078
## Schedule
| Date  | Milestone                               | Meta-skill Highlight |
|-------|-----------------------------------------|----------------------|
| 09/25 | Setup with Flutter & Firebase           | Perishable Process   |
| 10/05 | Design UI/UX in Flutter                 | Trend Recognition    |
| 10/15 | Integrate Firebase backend              | Perishable Process   |
| 10/25 | Search Bar & Company Profile            | Trend Recognition    |
| 11/05 | Detailed Filing View setup              | Perishable Process   |
| 11/15 | User Profile & Settings                 | Trend Recognition    |
| 11/25 | Optimize & Initial Tests                | Perishable Process   |
| 12/01 | Finalize & Prep for Deployment          | Fact vs. Fiction     |
| 12/07 | Review & Deploy SECSignal               | Comprehensive Review |

