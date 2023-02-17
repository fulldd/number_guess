#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GAME (){
  
  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]
    then
    echo "That is not an integer, guess again:"
    read GUESS
    GAME
  else
    if [[ $TARGET == $GUESS ]]
      then
      GUESSCOUNT=$(($GUESSCOUNT + 1))
      if [[ -z $BEST ]]
      then
         UPDATEGUESS=$($PSQL "update users set best_game = '$GUESSCOUNT' where username='$USERNAME'")
         
      else
        if [[ $GUESSCOUNT < $BEST ]]
          then
          UPDATEGUESS=$($PSQL "update users set best_game = '$GUESSCOUNT' where username='$USERNAME'")
        fi
      fi
      UPDATEPLAYED=$($PSQL "update users set games_played = games_played + 1 where username='$USERNAME'")
      echo "You guessed it in $GUESSCOUNT tries. The secret number was $TARGET. Nice job!"
      
    elif [[ $TARGET -gt $GUESS ]]
      then
        GUESSCOUNT=$(($GUESSCOUNT + 1))
        echo "It's higher than that, guess again:"
        read GUESS
        GAME
    else
      GUESSCOUNT=$(($GUESSCOUNT + 1))
        echo "It's lower than that, guess again:"
        read GUESS
        GAME
    fi
  fi
}


echo "Enter your username:"
read USERNAME
USERRESULT=$($PSQL "select username from users where username = '$USERNAME'")
if [[ -z $USERRESULT ]]
  then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "insert into users(username) values ('$USERNAME')")
  PLAYED=$($PSQL "select games_played from users where username='$USERNAME'")
  BEST=$($PSQL "select best_game from users where username='$USERNAME'")
else
  PLAYED=$($PSQL "select games_played from users where username='$USERNAME'")
  BEST=$($PSQL "select best_game from users where username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $PLAYED games, and your best game took $BEST guesses."
fi

# 
declare -i TARGET
TARGET=$(( $RANDOM % 1000 + 1 ))

echo "Guess the secret number between 1 and 1000:"
read GUESS
declare -i GUESSCOUNT
GUESSCOUNT="0"

GAME
