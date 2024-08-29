#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # get list of services
  SERVICES=$($PSQL "SELECT * FROM services;")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  # get user selection
  read SERVICE_ID_SELECTED
  SERVICE=$($PSQL "SELECT name from services WHERE service_id=$SERVICE_ID_SELECTED;")

  if [[ -z $SERVICE ]]
  then
    SERVICE_MENU "I could not find that service. What would you like today?"
  else
    # Service exists
    # Grab phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    # check if customer exists based on phone number
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

    if [[ -z $CUSTOMER_NAME ]]
    then
      # Have user enter their name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # Insert new record for customer
      CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME') RETURNING customer_id;")
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

    # Get appointment SERVICE_TIME
    echo -e "\nWhat time would you like your $(echo "$SERVICE" | sed -E 's/^ *//g'), $(echo "$CUSTOMER_NAME" | sed -E 's/^ *//g')?"
    read SERVICE_TIME
    # INSERT appointment
    APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

    echo -e "\nI have put you down for a $(echo "$SERVICE" | sed -E 's/^ *//g') at $SERVICE_TIME, $(echo "$CUSTOMER_NAME" | sed -E 's/^ *//g')."
  fi
}



SERVICE_MENU