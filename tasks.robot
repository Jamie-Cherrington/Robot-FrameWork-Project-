*** Settings ***
Documentation       COM397 Bank Customer Onboarding

#=== NOTE === for each "### TODO- ", do not remove these lines.

### TODO-01 - Import the required libraries

Library             RPA.Browser.Selenium
Library    OperatingSystem
Library    String
Library    Collections
Library    RPA.Archive

 


*** Variables ***
${url}                              https://com397bankdemo.z16.web.core.windows.net/
@{ac_no}    ${EMPTY}

${OUTPUT DIR}    OutputDir
### TODO-02 - regular expression for postcode and account number

${dest}    doc_server      # Destination folder for the zip file

${post_code_re}    \\w{1,2}\\d{1,2}\\s\\d\\w\\w

${Num_re}    \\d{4}
# Locators
${bank_manager_login_button}        xpath://html/body/div/div/div[2]/div/div[1]/div[2]/button    #locator buttons

${add_customer_button}              xpath://html/body/div/div/div[2]/div/div[1]/button[1]
${add_customer_form_first_name}     xpath://html/body/div/div/div[2]/div/div[2]/div/div/form/div[1]/input
${add_customer_form_last_name}      xpath://html/body/div/div/div[2]/div/div[2]/div/div/form/div[2]/input
${add_customer_form_post_code}      xpath://html/body/div/div/div[2]/div/div[2]/div/div/form/div[3]/input
${add_customer_form_submit}         xpath://html/body/div/div/div[2]/div/div[2]/div/div/form/button

### TODO-03
${open_account_button}    xpath://html/body/div/div/div[2]/div/div[1]/button[2]    #additional locators for buttons              
${open_account_customer_select}     xpath://html/body/div/div/div[2]/div/div[2]/div/div/form/div[1]/select    
${open_account_currency_select}    xpath:/html/body/div/div/div[2]/div/div[2]/div/div/form/div[2]/select     
${open_account_process}    xpath:/html/body/div/div/div[2]/div/div[2]/div/div/form/button        


### TODO-04
${customers_button}    xpath://html/body/div/div/div[2]/div/div[1]/button[3]      #locators for customer tab 
${customer_list_table}    xpath://html/body/div/div/div[2]/div/div[2]/div/form/div/div/input  #locators for customer list table     


*** Tasks ***
Customer Onboarding
    Bank Manager Login
    Onboard Customers
    Zip Agreement Documents
    Generate Report
    Log    Customer Onboarding Complete


*** Keywords ***
Bank Manager Login
    Open Browser    ${url}    browser=chrome

    # Wait and Click "Bank Manager Login" Button
    Wait Until Page Contains Element    ${bank_manager_login_button}
    Click Element    ${bank_manager_login_button}

Onboard Customers

    ### TODO-05

    ${customer_file}=    Get File    new-customers.csv    #reads in data from the customes.csv file and splits it into a list and removes the first line (titles)
    @{customers}=    Split To Lines    ${customer_file}
    ${discard}=    Remove From List    ${customers}    0    

    Create File    ${OUTPUT DIR}/invalid.txt    List of customers with missing data\n
   

    ### TODO-06
    FOR    ${customer}    IN    @{customers}
        @{fields}=    Split String    ${customer}     separator=,    #splits the data into individual fields and adds to the 'add customer' keyword
        Add Customer    @{fields}
    END


	

Add Customer
    [Arguments]    ${first_name}    ${last_name}    ${post_code}    ${currency}

    # Wait and Click "Add Customer" Button
    Wait Until Page Contains Element    ${add_customer_button}
    Click Element    ${add_customer_button}
    

    ${valid_post_code}=    Run Keyword And Return Status
    ...    Should Match Regexp
    ...    ${post_code}
    ...    ${post_code_re}

    
    IF    ${valid_post_code} == ${True}    

        ### TODO-07
       
        Input Text    ${add_customer_form_first_name}    ${first_name}    #adds the customer' first name data to the form
        Input Text    ${add_customer_form_last_name}    ${last_name}    #adds the customer's last name data to the form
        Input Text    ${add_customer_form_post_code}    ${post_code}    #add the customers postcode to the form

        Click Element    ${add_customer_form_submit}
        ${message}=    Handle Alert    DISMISS 
        Open Account    ${first_name}    ${last_name}    ${currency}    #opens the account for the customer
		
    ELSE    
 
		### TODO-08
        Append To File    ${OUTPUT DIR}/invalid.txt    ${first_name},    #adds the invalid data to the invalid.txt file 
        Append To File    ${OUTPUT DIR}/invalid.txt    ${last_name},
        Append To File    ${OUTPUT DIR}/invalid.txt    ${currency}\n    
    END

Open Account
    [Arguments]    ${first_name}    ${last_name}    ${currency}

    # Click "Open Account" button
    Click Element    ${open_account_button}

    # Wait for List box
    Wait Until Page Contains Element    ${open_account_customer_select}
    Select From List By Label
    ...    ${open_account_customer_select}
    ...    ${first_name} ${last_name}
    Select From List By Label
    ...    ${open_account_currency_select}
    ...    ${currency}
    Click Element    ${open_account_process}

	### TODO-09
   
    ${message}=    Handle Alert    #handles the alert message
    ${getId}=    Get Regexp Matches    ${message}    ${Num_re}    #gets the account number from the alert message
    @{ac_no}[0]=    Convert To List    ${getId}    #converts the account number to a list   
    
    # A credit agreement is created for every new customer
    Create File    agreements/${first_name}_${last_name}_${ac_no}[0]_credit_agreement.txt
    Append To File
    ...    agreements/${first_name}_${last_name}_${ac_no}[0]_credit_agreement.txt
    ...    Business Terms and Conditions for account: ${ac_no}[0]

	
    # An additional foreign exchange agreement is created for every new customer
    # whose account is in Dollars or Rupees
    IF    $currency == 'Dollar' or $currency == 'Rupee'
		### TODO-10
        Create File    agreements/${first_name}_${last_name}_${ac_no}[0]_FX_credit_agreement.txt    
        Append To File
        ...    agreements/${first_name}_${last_name}_${ac_no}[0]_FX_credit_agreement.txt
        ...    Foreign Exchange Terms and Conditions for account: ${ac_no}[0]
    END

Zip Agreement Documents
	### TODO-11
    Archive Folder With Zip    agreements    doc_server/agreements.zip   #zips the agreement files into a zip file   
    @{zip_contents}=    List Archive     doc_server/agreements.zip    #lists the contents of the zip file

    Copy File     doc_server/agreements.zip    ${dest}    #copies the zip file to the doc_server folder


Generate Report
    # Click on "Customers" button
    ### TODO-12
    Click Element    ${customers_button}

    Wait Until Page Contains Element   xpath://html/body/div/div/div[2]/div/div[2]/div/div/table    #waits for the page to load the table
    
    Capture Element Screenshot    xpath://html/body/div/div/div[2]/div/div[2]/div/div/table    ${OUTPUT DIR}/new_customer_report.png    #captures a screenshot of the table and saves it to the OutputDir
