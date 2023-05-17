#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -tc"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
SERVICES=$($PSQL "SELECT service_id, name FROM services;")
MAIN_MENU () {
  #If there is an argument - this is a return to the main menu
  #If not - first launch
  if [[ $1 ]]
    then
    echo -e "\n$1"
    else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi
  #show services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  #if service is not a number - revert to main menu with the argument
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
     MAIN_MENU "I could not find that service. What would you like today?"
  else 
    SERVICE_NAME=$(echo $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;") | sed -E 's/^ *| *$//g')
    #if this is a number but service is not found - revert
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else 
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$(echo $($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';") | sed -E 's/^ *| *$//g')
      #if there is not customer with this name - trying to create new one
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        CREATE_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      CREATE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")     
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
 
}
MAIN_MENU