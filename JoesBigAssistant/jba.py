# Joe's Big Assistant, Version 0.1
# based on https://github.com/minimaxir/facebook-page-post-scraper

import certifi
import urllib3
import json
import datetime
import csv
import time
import re
from xlsxwriter.workbook import Workbook

JBA_VERSION = 0.1
API_VERSION = "2.7" # PUT A STRING HERE
QUERY_MAX = 100 # PUT AN INTEGER HERE
WORKSHEET_NAME = 'JBI_stats_' + str(datetime.date.today())

page_id  = "joesbigidea"
access_token = 

# initiate a PoolManager object.
# See: https://urllib3.readthedocs.io/en/latest/user-guide.html
http = urllib3.PoolManager(
    cert_reqs='CERT_REQUIRED',
    ca_certs=certifi.where())

# main function
def scrape(page_id, access_token):
    with open(WORKSHEET_NAME + '.csv', 'w') as f:
        w = csv.writer(f)
        w.writerow(["Time Posted (UTC)", "Type", "FOJBI First Name",
            "FOJBI Last Name", "Link to Post", "Attached Link",
            "Comments", "Shares",
            "Reactions", "Reaches", "Impressions"])

        has_next_page = True # We can only query QUERY_MAX posts at a time
        num_processed = 0 # Counter for processed posts
        starttime = datetime.datetime.now()

        print("Scraping " + page_id + "'s Facebook Page: " + str(starttime))

        statuses = get_feed_data(page_id, access_token, QUERY_MAX)

        while has_next_page:
            if statuses['data']: # check that the list is nonempty
                for status in statuses['data']:
                    w.writerow(process_feed_data(status, access_token))
                    num_processed += 1
                    if num_processed % QUERY_MAX == 0:
                        print(num_processed, " Posts Processed: ",
                                datetime.datetime.now())
                        next_url = statuses['paging']['next']
                        statuses = json.loads(request(next_url))
            else:
                has_next_page = False

        print("Processing Completed.")
        print(num_processed, " Posts Processed in ",
                datetime.datetime.now() - starttime)

# Retrieve feed data via Facebook Graph API
def get_feed_data(page_id, access_token, num_statuses):
    base = "https://graph.facebook.com/" + "v" + API_VERSION
    node = "/" + page_id + "/posts"
    fields = "/?fields=id,created_time,type,link,comments.limit(0)" + \
            ".summary(true),shares,reactions.limit(0).summary(true),message"
    parameters = "&limit=" + str(num_statuses) + "&access_token=" + access_token
    url = base + node + fields + parameters

    data = json.loads(request(url))

    return data
    

# Send an HTTP GET request to a specified url
def request(url):
    get_req = http.request('GET',url)
    while get_req.status != 200:
        print("Retrying...")
        get_req = http.request('GET',url)
    return get_req.data.decode("utf-8")

def process_feed_data(status, access_token):
    # id, created_time, and status_type always exist

    status_id = status['id']
    status_time = status['created_time']
    status_type = status['type']
    status_permalink = "https://facebook.com/" + \
                     str(status_id)

    # make sure items exist

    if 'link' in status.keys():
        status_link = sanitize_unicode(status['link']).decode("utf-8")
    else:
        status_link = ''
    
    if 'comments' in status.keys():
        status_comments = status['comments']['summary']['total_count']
    else:
        status_comments = 0
    
    if 'shares' in status.keys():
        status_shares = status['shares']['count']
    else:
        status_shares = 0
    
    if 'reactions' in status.keys():
        status_reactions = status['reactions']['summary']['total_count']
    else:
        status_reactions = 0

    
    # find a string of the form "FOJBI FIRST LAST" and create
    # a list of the form [FIRST,LAST].
    if 'message' in status.keys():
        hat_tip_name = get_hat_tip_name(status_id, access_token,
                   status['message'])
        status_first_name = hat_tip_name[0]
        status_last_name =  hat_tip_name[1]
    else:
        status_first_name = ''
        status_last_name = ''
    
    # get post insights data for status_id
    status_reaches = get_post_insights(status_id, access_token,
                     'post_fan_reach')['data'][0]['values'][0]['value']
    status_impressions = status_reaches = get_post_insights(status_id,
                         access_token,
                         'post_impressions')['data'][0]['values'][0]['value']
#    status_reaches = status_impressions = 'hi'

    # return a tuple of the processed data
    return (status_time, status_type, status_first_name, status_last_name,
            status_permalink, status_link, status_comments,
            status_shares, status_reactions, status_reaches,
            status_impressions)

# change fancy characters to unfancy characters to make the text suitable
# for a url
def sanitize_unicode(text):
        return text.translate({ 0x2018:0x27, 0x2019:0x27, 0x201C:0x22,
            0x201D:0x22,0xa0:0x20 }).encode('utf-8')
        
# retrive post_insights data; requires read_insights permission.
def get_post_insights(status_id, access_token, insights_metric):
    base = "https://graph.facebook.com/" + "v" + API_VERSION
    node = "/" + status_id
    insights = "/insights/" + insights_metric
    parameters = "?access_token=" + access_token
    url = base + node + insights + parameters

    data = json.loads(request(url))

    return data

def get_hat_tip_name(status_id, access_token, status_message):
    regexer = re.compile('FOJBI\s\w+\s\w+')#FOJBI(space)FIRST(space)LAST
    hat_tip_raw = regexer.search(status_message)
    if str(hat_tip_raw) == 'None':
        hat_tip_raw = ''
    else:
        hat_tip_raw = hat_tip_raw.group()
    
    hat_tip_name = hat_tip_raw[6:] # Delete 'FOJBI '
    
    regexer2 = re.compile('\w+') #FIRST
    hat_tip_first = regexer2.search(hat_tip_name)
    if str(hat_tip_first) == 'None':
        hat_tip_first = ''
    else:
        hat_tip_first = hat_tip_first.group()
    
    regexer3 = re.compile('\s\w+') #(space)LAST
    hat_tip_last = regexer3.search(hat_tip_name)
    if str(hat_tip_last) == 'None':
        hat_tip_last = ''
    else:
        hat_tip_last = hat_tip_last.group()
        hat_tip_last = hat_tip_last[1:] #remove (space)

    return [hat_tip_first, hat_tip_last]
    
# run the script!
if __name__ == '__main__':
    print("Welcome to Joe's Big Assistant Ver.", JBA_VERSION)
    scrape(page_id, access_token)
    workbook = Workbook(WORKSHEET_NAME + '.xlsx')
    worksheet = workbook.add_worksheet()
    with open(WORKSHEET_NAME + '.csv', 'r') as f:
        reader = csv.reader(f)
        for r, row in enumerate(reader):
            for c, col in enumerate(row):
                worksheet.write(r,c,col)
    workbook.close()
    print("Data saved to " + WORKSHEET_NAME + ".xlsx")


