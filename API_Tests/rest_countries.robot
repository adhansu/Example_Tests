*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    Browser
Library    JSONLibrary

*** Variables ***
${BASE_URL}    https://restcountries.com/v3.1/lang
${FILTER_FIELDS}     name,currencies,capital
@{EXPECTED_COUNTRIES}    Finland
@{REQUIRED_FIELDS}    name    currencies    capital    flag    languages    region    subregion    timezones

*** Test Cases ***
Validate Country Data By Language
    ${response}=    GET     ${BASE_URL}/portuguese        expected_status=200
    ${country_list}=    Set Variable    ${response.json()}  
    Should Not Be Empty    ${country_list}
    ${first_country}=    Get From List    ${country_list}    0
    Dictionary Should Contain Key    ${first_country}    name
    Dictionary Should Contain Key    ${first_country}    languages
    Dictionary Should Contain Key    ${first_country}    currencies

Validate Country Data By Language - Finnish
    ${response}=    GET    ${BASE_URL}/finnish    expected_status=200
    ${country_list}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${country_list}
    ${actual_countries}=    Create List
    FOR    ${country}    IN    @{country_list}
        ${name}=    Set Variable    ${country["name"]["common"]}
        Append To List    ${actual_countries}    ${name}
    END
    ${expected_countries}=    Create List    @{EXPECTED_COUNTRIES}
    Lists Should Be Equal    ${actual_countries}    ${expected_countries}
    FOR    ${country}    IN    @{country_list}
        FOR    ${field}    IN    @{REQUIRED_FIELDS}
            Dictionary Should Contain Key    ${country}    ${field}
        END
    END

Validate Country Data By Language With Filters
    ${url}=    Catenate     ${BASE_URL}/portuguese?fields=${FILTER_FIELDS}
    ${response}=    GET    ${url}    expected_status=200
    ${first_country}=    Get From List    ${response.json()}    0
    Dictionary Should Contain Key    ${first_country}    name
    Dictionary Should Contain Key    ${first_country}    currencies
    Dictionary Should Contain Key    ${first_country}    capital

#Edge Case
Handle Invalid Country Name
    ${response}=    GET    ${BASE_URL}/NotARealCountry    expected_status=404
    ${content_type}=    Get From Dictionary    ${response.headers}    Content-Type
    Run Keyword If    '${content_type}' == 'application/json'    Handle JSON Response    ${response}
    Run Keyword If    '${content_type}' != 'application/json'    Handle Non-JSON Response    ${response}

*** Keywords ***   
Handle JSON Response
    [Arguments]    ${response}
    ${response_data}=    Set Variable    ${response.json()}
    
    Dictionary Should Contain Key    ${response_data}    status
    Dictionary Should Contain Key    ${response_data}    message
    Should Be Equal As Strings    ${response_data['message']}    Not Found

Handle Non-JSON Response
    [Arguments]    ${response}
    Status Should Be    404    ${response}