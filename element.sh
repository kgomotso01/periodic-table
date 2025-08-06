#!/bin/bash

# Check if argument is provided
if [[ $# -eq 0 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Connect to database
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Get the argument
ELEMENT=$1

# Check if argument is a number (atomic number)
if [[ $ELEMENT =~ ^[0-9]+$ ]]
then
  # Query by atomic number
  ELEMENT_INFO=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e INNER JOIN properties p ON e.atomic_number = p.atomic_number INNER JOIN types t ON p.type_id = t.type_id WHERE e.atomic_number = $ELEMENT;")
else
  # Query by symbol or name (case insensitive)
  ELEMENT_INFO=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e INNER JOIN properties p ON e.atomic_number = p.atomic_number INNER JOIN types t ON p.type_id = t.type_id WHERE e.symbol ILIKE '$ELEMENT' OR e.name ILIKE '$ELEMENT';")
fi

# Check if element was found
if [[ -z $ELEMENT_INFO ]]
then
  echo "I could not find that element in the database."
else
  # Parse the result
  echo "$ELEMENT_INFO" | while IFS='|' read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  done
fi
