#!/bin/bash

# Constants
MESSAGE_GREETING="Welcome to the Hourly Jackpot Scraper!"
MESSAGE_CURRENCY="Please enter desired currency (USD, GBP, EUR, BRL): "
MESSAGE_NOT_VALID_NUMBER="Argument is not a valid number"
MESSAGE_NOT_VALID_CURRENCY="is not a valid currency. Please try again."
MESSAGE_NOT_FOUND="Amount for Hourly Drop Jackpot not found."
VALID_CURRENCIES=("USD" "GBP" "EUR" "BRL")
JACKPOT_NAME="Hourly  Drop Jackpot"
TIMER_DEFAULT_DURATION=30
REQUEST_URL="https://feed-casino888.redtiger.cash/jackpots?jackpotId=williamHill&currency="


scrapeHourlyJackpot() {
    local currency="$1"
    local request_url="$REQUEST_URL$currency"

    local response_body=$(curl -s "$request_url")

    local success=$(echo "$response_body" | jq -r '.success')
    if [ "$success" != "true" ]; then
        echo "$MESSAGE_NOT_FOUND"
        return
    fi

    local amount=$(echo "$response_body" | jq -r '.result.jackpots.pots[] | select(.name == "Hourly  Drop Jackpot").amount')
    if [ -z "$amount" ]; then
        echo "$MESSAGE_NOT_FOUND"
        return
    fi

    echo "$amount"
}

main() {
    # Greet the user
    echo $MESSAGE_GREETING
    
    # Parse command-line arguments
    if [ $# -eq 0 ]; then
        duration=$TIMER_DEFAULT_DURATION
    else
        duration=$1  
        if ! [[ $duration =~ ^[0-9]+$ ]]; then
            echo $MESSAGE_NOT_VALID_NUMBER
            return 1
        fi
    fi
    
    # Prompt for currency input and validate
    while true; do
        echo $MESSAGE_CURRENCY
        read currency
        currency=$(echo $currency | tr '[:lower:]' '[:upper:]')  # Convert to uppercase
        
        # Validate currency
        if [[ " ${VALID_CURRENCIES[@]} " =~ " $currency " ]]; then
            break
        else
            echo "$currency $MESSAGE_NOT_VALID_CURRENCY"
        fi
    done
    
    lowercaseCurrency=$(echo $currency | tr '[:upper:]' '[:lower:]')  # Convert to lowercase
    # Timer loop
    while true; do
        jackpotAmount=$(scrapeHourlyJackpot $lowercaseCurrency)
        echo "$JACKPOT_NAME: $jackpotAmount $currency"
        sleep $duration 
    done
}

# Run main
main "$@"
