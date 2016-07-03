# Penny-Press
A program that finds micro-cap stocks that are trending on social media and posts new news about them on Facebook and Twitter

## About this project
The primary driver for price and volume appreciation of a micro-cap (a.k.a penny) stock is new news about the company - news such as signing a major client, being issued a patent or releasing an aticipated product. Whether the news in accurate is beside the point, since the market usually reacts before verification of the news is completed.

This program looks for trending micro-cap stocks and checks if there is new news about about the company. If there is new news, it will post a link in the body of a tweet as well as to a facebook page.

## About the code
* I wrote the code in Perl, since it appears Perl is the predominant language on GitHub. I am open to doing a re-write in Phython if that gets more activity. Feel free to create a Phyton branch and we'll see which gets the most commits.
* I do share share out my own Twitter app's consumer and secret keys in the code. Here is a link that has information on how to [register your own app in twitter] (https://apps.twitter.com/).

## To-dos
* As of now the code does not check various sources for trending stocks. Rather, the stocks that are checked for news come from a flat file.
*  News is not added to Facebook directly in the code. I simply link the twitter user page to a facebook account. I would like to add code to write to the Facebook page directly.
*  I have played with sending news to people's cell phones via SMS. I used Google Voice to do this, but it's so unreliable. I have thought about using a service such as Nexmo, but that is a fee-based solution.
