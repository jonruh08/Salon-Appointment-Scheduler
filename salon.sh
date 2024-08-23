#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  echo -e "\nPlease enter the service ID you would like to book."
  read SERVICE_ID_SELECTED

  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "That is not a valid service ID.\n"
  else
    SERVICE_SELECTION_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    SERVICE_SELECTION_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    
    if [[ -z $SERVICE_SELECTION_ID ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid service ID.\n"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get new customer name
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi      
      # Appointment time
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      echo -e "\nWhat is the time for you booking?"
      read SERVICE_TIME
      INSERT_APPOINTMENT_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_SELECTION_ID, '$SERVICE_TIME')")
      echo I have put you down for a $SERVICE_SELECTION_NAME at $SERVICE_TIME, $CUSTOMER_NAME.
    fi
  fi
  
  # echo "Which service would you like to book?" 
  # echo -e "\n1) Rent a bike\n2. Return a bike\n3. Exit"
  # read MAIN_MENU_SELECTION
}

MAIN_MENU