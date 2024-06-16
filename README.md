Robot Framework Project description.

This project implements a Robotic Process Automation (RPA) solution using the Robot Framework to automate tasks for an online banking system. The robot performs several key tasks on behalf of the Bank Manager, focusing on the processes of adding new customers and opening their accounts based on a weekly CSV file (new-customers.csv) provided by the Sales Team.

Tasks Performed by the Robot
Bank Manager Login:

The robot logs into the system by clicking the Bank Manager login button.
Onboard Customers:

For each new customer listed in new-customers.csv:
Add Customer:
Validates the customer's postcode using a regular expression to ensure it follows the required format.
Adds the customer's first name, last name, and postcode to the system if the postcode is valid.
Logs invalid postcodes by writing the customer's first and last names to invalid.txt in the output directory.
Open Account:
Opens the first account for the newly added customer by selecting the customer and the account type (currency) from the provided options.
Creates a credit agreement document in the agreements folder with the filename format: firstname_lastname_accno_credit_agreement.txt.
Creates an additional FX agreement document for Dollar or Rupee accounts with the filename format: firstname_lastname_accno_FX_agreement.txt.
Archive Agreement Documents:

Archives all the agreement documents into a zip file and moves the archive to the folder C:\temp\doc_server, simulating an online document store.
Generate New Customer Report:

Generates a report by capturing a screenshot of the customer table. The image is saved in the output folder.
