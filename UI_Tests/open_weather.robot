*** Settings ***
Library    Browser
Library    DateTime
Library    OperatingSystem
Library    Collections

*** Variables ***
${URL}    https://openweathermap.org/
${SEARCH_FIELD}    //input[@placeholder='Search city']
${FORECAST_DATES}    //ul[contains(@class, 'day-list')]
#${SEARCH}    //button[normalize-space(text())='Search']
${SEARCH}    //button[contains(@class, 'button-round dark')]

${ERROR_MESSAGE}    div.sub.not-found.notFoundOpen

*** Test Cases ***
Verify 8-Day Forecast Labels
    New Browser    chromium
    New Page    ${URL}
    ${today}=    Get Current Date    result_format=%Y-%m-%d
    ${expected_dates}=    Create List
    FOR    ${index}    IN RANGE    0    8
        ${new_date}=   Get Future Date   ${today}    ${index} days
        ${formatted_date}=    Convert Date     ${new_date}    %a, %b %d
        Append To List    ${expected_dates}    ${formatted_date}
    END
    Log To Console    ${expected_dates}


    ${displayed_texts}=    Create List
    FOR    ${i}    IN RANGE    1    9
        ${day}=    Get Text    //ul[contains(@class, 'day-list')]//li[${i}]
        ${date}=    Get From List    ${day.split("\n")}    0
        Append To List    ${displayed_texts}    ${date}
    END

    Log To Console    ${displayed_texts}
    Lists Should Be Equal    ${displayed_texts}    ${expected_dates}
    Close Browser

Verify City Search Functionality
    New Browser    headless=true
    New Page    ${URL}        
    Input City Name And Verify    Helsinki, FI     ${SEARCH_FIELD}      Helsinki, FI
    Verify Incorrect City Search    TestCity    ${ERROR_MESSAGE}        TestCity
    Close Browser

*** Keywords ***
Get Future Date
    [Arguments]    ${current_date}    ${days_offset}
    ${current_datetime}=    Convert Date    ${current_date}    format=%Y-%m-%d
    ${new_datetime}=    Add Time To Date    ${current_datetime}    ${days_offset}
    ${formatted_date}=     Convert Date    ${new_datetime}    %Y-%m-%d
    [Return]    ${formatted_date}

Input City Name And Verify
    [Arguments]    ${city}    ${locator}    ${expected_text}=None
    Wait For Elements State    ${SEARCH_FIELD}    visible
    Fill Text    ${SEARCH_FIELD}    ${city}
    Click     ${SEARCH}
    #${ELEMENTS} =    Get Elements    //ul[contains(@class, 'search-dropdown-menu')]//li
    #Log To Console      ${ELEMENTS}
    #Wait Until Keyword Succeeds    3x    3 sec    Get Element Count    //ul[@class='search-dropdown-menu']     ==   1
    Sleep   1s
    Wait Until Keyword Succeeds    3x    5s    Wait For Elements State    //ul[contains(@class, 'search-dropdown-menu')]    timeout=5s
    ${ELEMENTS} =    Get Elements    //ul[contains(@class, 'search-dropdown-menu')]//li
    ${count} =    Get Length    ${ELEMENTS}
    Should Be True    ${count} > 0    "No search results found!"
    Click    ${ELEMENTS}[0]
    ${title} =    Get Text    //h2[text()='Helsinki, FI']
    Should Be Equal    ${title}    Helsinki, FI

Verify Incorrect City Search
    [Arguments]    ${city}    ${locator}    ${expected_text}=None
    Wait For Elements State    ${SEARCH_FIELD}    visible
    Fill Text    ${SEARCH_FIELD}    ${city}
    Click     ${SEARCH}
    Sleep   1s
    Run Keyword If    '${city}' == 'TestCity'    Verify Error Message    ${ERROR_MESSAGE}

Verify Error Message
    [Arguments]    ${error_message_locator}
    ${error_message} =    Get Text    div.sub.not-found.notFoundOpen
    Should Contain    ${error_message}    Not found. To make search more precise put the city's name, comma, 2-letter country code (ISO3166).