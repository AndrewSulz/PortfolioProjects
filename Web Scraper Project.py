#!/usr/bin/env python
# coding: utf-8

# In[42]:


# import libraries

from bs4 import BeautifulSoup
import pandas as pd
import requests
import smtplib
import time
import datetime


# In[43]:


# Connect to the website

URL = 'https://www.amazon.com/3dRose-118876_4-Geeky-School-Pixels/dp/B013KTBWN6/ref=sr_1_13?keywords=data%2Banalyst%2Bmug&qid=1664810645&qu=eyJxc2MiOiI0Ljk1IiwicXNhIjoiNC40MCIsInFzcCI6IjMuNzQifQ%3D%3D&sr=8-13&th=1'

# Use httpbin.org/get to find the User-Agent information
headers = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36", "Accept-Encoding":"gzip, deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT":"1", "Connection":"close", "Upgrade-Insecure-Requests":"1"}  

page = requests.get(URL, headers=headers)

soup1 = BeautifulSoup(page.content, "html.parser")

soup2 = BeautifulSoup(soup1.prettify(), "html.parser")

title = soup2.find(id='productTitle').get_text()

price = soup2.find(id='apex_desktop').get_text()

print(title)
print(price)




# In[44]:


price1 = price.strip()
placeHolder = price1.find('.') + 3
finalPrice = price1[:placeHolder]

title = title.strip()

print(title)
print(finalPrice)


# In[46]:


today = datetime.date.today()

print(today)


# In[47]:


import csv

header = ['Title', 'Price', 'Date']
data = [title, finalPrice, today]

#with open('WebScraper.csv', 'w', newline='', encoding='UTF8') as f:
    #writer = csv.writer(f)
    #writer.writerow(header)
    #writer.writerow(data)


# In[54]:


df = pd.read_csv(r'/Users/Andrew/WebScraper.csv')

print(df)


# In[53]:


# Now we are appending data to the csv

with open('WebScraper.csv', 'a+', newline='', encoding='UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(data)


# In[55]:


def check_price():
    URL = 'https://www.amazon.com/3dRose-118876_4-Geeky-School-Pixels/dp/B013KTBWN6/ref=sr_1_13?keywords=data%2Banalyst%2Bmug&qid=1664810645&qu=eyJxc2MiOiI0Ljk1IiwicXNhIjoiNC40MCIsInFzcCI6IjMuNzQifQ%3D%3D&sr=8-13&th=1'

    headers = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36", "Accept-Encoding":"gzip, deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT":"1", "Connection":"close", "Upgrade-Insecure-Requests":"1"}  

    page = requests.get(URL, headers=headers)

    soup1 = BeautifulSoup(page.content, "html.parser")

    soup2 = BeautifulSoup(soup1.prettify(), "html.parser")

    title = soup2.find(id='productTitle').get_text()

    price = soup2.find(id='apex_desktop').get_text()
    
    price1 = price.strip()
    placeHolder = price1.find('.') + 3
    finalPrice = price1[:placeHolder]

    title = title.strip()

    import datetime
    
    today = datetime.date.today()
    
    import csv

    header = ['Title', 'Price', 'Date']
    data = [title, finalPrice, today]
    
    with open('WebScraper.csv', 'a+', newline='', encoding='UTF8') as f:
        writer = csv.writer(f)
        writer.writerow(data)
    
    priceFloat = finalPrice[1:]
    priceFloat = float(priceFloat)
    
    if(priceFloat < 10.00):
        send_mail()


# In[56]:


while(True):
    check_price()
    time.sleep(86400)


# In[65]:


df = pd.read_csv(r'/Users/Andrew/WebScraper.csv')

print(df)


# In[ ]:


def send_mail():
    server = smtplib.SMTP_SSL('smtp.gmail.com',465)
    server.ehlo()
    #server.starttls()
    server.ehlo()
    server.login('andrew.c.sulz@gmail.com','xxxxxxxxxxxx')
    
    subject = "The mug you wanted is below $10! Now is your chance to buy!"
    body = "Andrew, This is the moment you have been waiting for. Now is your chance to buy the mug of your dreams. Don't miss out!"
    
    msg = f'subject: {subject}\n\n{body}'
    
    server.sendmail(
        'andrew.c.sulz@gmail.com'
        msg
    )


# In[ ]:




