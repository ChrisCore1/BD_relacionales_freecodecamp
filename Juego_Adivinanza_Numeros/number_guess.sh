#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( 1 + RANDOM % 1000 ))

echo -e "\n----Guess the Number----\n"
echo "Enter your username:"
read USERNAME

USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_DATA ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  echo "$USER_DATA" | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took ${BEST_GAME:-0} guesses."
  done
fi

echo -e "\nGuess the secret number between 1 and 1000:"
TRIES=0

while true
do
  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  (( TRIES++ ))

  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

UPDATE_GAMES=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id = $USER_ID")

CURRENT_BEST=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")

if [[ -z $CURRENT_BEST || $TRIES -lt $CURRENT_BEST ]]
then
  UPDATE_BEST=$($PSQL "UPDATE users SET best_game = $TRIES WHERE user_id = $USER_ID")
fi
