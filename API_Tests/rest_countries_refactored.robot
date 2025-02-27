*** Settings ***
Library    Browser
Library    Collections
Library    RequestsLibrary
#Library    JSONLibrary

*** Variables ***
${BASE_URL}    https://restcountries.com/v3.1/lang
@{EXPECTED_COUNTRIES}    Finland
@{REQUIRED_FIELDS}    name    currencies    capital    flag    languages    region    subregion    timezones


*** Test Cases ***
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

