import bs4
import os
import requests
import time

def main():
    url = input("Enter the URL to scrape: ")
    if not url:
        input("Enter a valid URL to scrape: ")

    extension = input("Enter the extension of the files to download: ")
    if not extension:
        input("Enter a valid extension: ")

    delay = input(("Enter the delay, in seconds, between each download."
        " Enter 0 for no delay: "))
    if not delay.isdigit():
        input("Enter a nonnegative integer for delay: ")

    download(url, extension, int(delay))


def download(url, extension, delay):
    extension = extension.lower()  # sanitize for comparison purposes.

    r = requests.get(url)
    r.raise_for_status()  # Raise error if url is inaccessible.

    soup = bs4.BeautifulSoup(r.text, "html5lib")
    links = soup.find_all('a')

    names = []
    full_urls = []

    for tag in links:
        link = tag.get('href')
        if absolute_path(link):
            full_url = link
        else:
            full_url = url + link

        name = parse_url(full_url)

        if full_url.lower().endswith(extension):
            names.append(name)
            full_urls.append(full_url)

    if not os.path.isdir('Downloads'):
        os.mkdir('Downloads')

    for name, full_url in zip(names, full_urls):
        to_download = requests.get(full_url, stream=True)
        file_path = os.path.join('Downloads', name)
        print('Downloading {full_url} to {file_path}'.format(
            full_url=full_url, file_path=file_path))
        with open(file_path, 'wb') as f:
            for chunk in to_download.iter_content(chunk_size=1024):
                if chunk:
                    f.write(chunk)
        time.sleep(delay)  # optional time delay


def absolute_path(link):
    if link is None:
        raise ValueError("No link found.")
    elif link.startswith('http://'):
        return True
    elif link.startswith('https://'):
        return True
    elif link.startswith('ftp://'):
        return True
    elif link.startswith('file:///'):
        return True
    else:
        return False


def parse_url(full_url):
    last_slash_location = full_url[::-1].find('/')
    return full_url[-last_slash_location:]

if __name__ == "__main__":
    main()
