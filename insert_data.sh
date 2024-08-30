#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

$PSQL "DROP TABLE IF EXISTS games;"
$PSQL "DROP TABLE IF EXISTS teams;"

$PSQL "
CREATE TABLE teams (
    team_id SERIAL PRIMARY KEY NOT NULL,
    name VARCHAR(255) UNIQUE NOT NULL
);"

$PSQL "
CREATE TABLE games (
    game_id SERIAL PRIMARY KEY NOT NULL,
    year INT NOT NULL,
    round VARCHAR(255) NOT NULL,
    winner_goals INT NOT NULL,
    opponent_goals INT NOT NULL
)
"
$PSQL "
ALTER TABLE games
ADD COLUMN winner_id INT REFERENCES teams(team_id) NOT NULL,
ADD COLUMN opponent_id INT REFERENCES teams(team_id) NOT NULL;
"

tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
#GET team_id
WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
#GET team name
WINNER_TEAM=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
OPPONENT_TEAM=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")

## GET WINNERS TEAMS ##
if [[ -z $WINNER_ID ]]
then
    #check if team are already in db
    if [[ $WINNER != $WINNER_TEAM ]]
    then
        INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams (name) VALUES('$WINNER')")
        if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
        then
            echo Inserted into teams, $WINNER
        fi
    fi
	#get team_id
	WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
fi
## GET OPPONENT TEAMS ##
if [[ -z $OPPONENT_ID ]]
then
    #check if team are already in db
    if [[ $OPPONENT != $OPPONENT_TEAM ]]
    then
        INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams (name) VALUES('$OPPONENT')")
        if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
        then
            echo Inserted into teams, $OPPONENT
        fi
    fi
	#get team_id
	OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
fi

## INSERT GAMES ##
INSERT_MATCH=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND','$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
if [[ $INSERT_MATCH == "INSERT 0 1" ]]
	then
		echo Inserted into games, $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID
	fi
done
