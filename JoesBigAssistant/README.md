**Joe's Big Assistant** is a data scraper for the Facebook page [Joe's Big Idea](https://www.facebook.com/joesbigidea/), based on [minimaxir's Facebook page post scraper](https://github.com/minimaxir/facebook-page-post-scraper).

jba.py is the scraper script. RUN-JBA.bat allows Windows users with no knowledge of Python to run the script.

JBA gathers, for each post on the Facebook page with page ID **page_id**, the following information (see **scrape()**):
- Time posted (in UTC)
- Type
- FOJBI first name
- FOJBI last name
- Permalink to post
- Link attached to post
- Number of comments
- Number of shares
- Number of reactions
- Total reaches
- Total impressions

"FOJBI first name" and "FOJBI last name" refer to specific information on Joe's Big Idea Facebook page and are gathered via a simple regular-expression pattern matcher. (See **get_hat_tip_name()**)

The script then compiles the gathered information into an .xlsx file. During the process, a .csv file is generated as well.

Please make sure to write in an appropriate Facebook Graph API access token for the **access_token** variable. Without an access token, the scraper will not work.
