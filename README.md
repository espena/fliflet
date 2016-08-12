# fiflet
Statistics tool for mining into Electronic Public Records of Norway.

This PHP applications is designed to run both as a client application (invoked
from a console, i.e. via a Cron job), and as a web application.

## Client application
Invoked from the command-line:

<code>
:~ php index.php [command]
</code>

[command] can be one of the following:

<ul>
  <li><b>scrape</b> Run the scraper to collect data.</li>
  <li><b>list-suppliers</b> Output the list of data suppliers with IDs.</li>
  <li><b>regen-suppliers</b> Update the list of data suppliers from server.</li>
  <li><b>nuke-database</b> Drop and recreate the database. Use with caution.</li>
</ul>

## Web application
