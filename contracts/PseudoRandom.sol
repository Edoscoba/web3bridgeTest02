// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract LudoGame {
    // Mapping of player addresses to their current positions
    mapping(address => uint256) public playerPositions;

    // Mapping of player addresses to their turns
    mapping(address => bool) public playerTurns;

    uint256 public currentTurn; 
    uint256 public numPlayers;  
    uint256 public mapSize = 52; 
    uint256 public diceSize = 6; 

    uint256 public seed; 
    address[] public players; // Array to store player addresses

    event DiceRolled(address player, uint256 roll);
    event PlayerMoved(address player, uint256 newPosition);
    event PlayerWon(address player);

    // Constructor to initialize the game (no visibility needed)
    constructor() {
        seed = block.timestamp;
    }

    // Function to add a player to the game
    function addPlayer() public {
        // Ensure the player isn't already in the game
        require(playerPositions[msg.sender] == 0, "Player already in the game");

        // Add player to the game
        playerPositions[msg.sender] = 1;
        playerTurns[msg.sender] = false;
        players.push(msg.sender);
        numPlayers++;

        // Set the first player to take the first turn
        if (numPlayers == 1) {
            playerTurns[msg.sender] = true;
            currentTurn = 0; // The first player in the array takes the first turn
        }
    }

    // Function to roll the dice and move the player
    function rollDice() public {
        // Check if it's the player's turn
        require(playerTurns[msg.sender] == true, "Not your turn");

        // Generate a pseudorandom number between 1 and diceSize
        uint256 roll = (seed + block.timestamp) % diceSize + 1;
        seed = roll;

        emit DiceRolled(msg.sender, roll);

        // Move the player based on the dice roll
        movePlayer(roll);
    }

    // Function to move a player
    function movePlayer(uint256 roll) internal {
        uint256 newPosition = playerPositions[msg.sender] + roll;

        // Check if the new position is beyond the map
        if (newPosition > mapSize) {
            newPosition = mapSize;
        }

        playerPositions[msg.sender] = newPosition;
        emit PlayerMoved(msg.sender, newPosition);

        // Check if the player has won
        if (newPosition == mapSize) {
            emit PlayerWon(msg.sender);
        }

        // Switch turns to the next player
        playerTurns[msg.sender] = false;
        currentTurn = (currentTurn + 1) % numPlayers;

        address nextPlayer = players[currentTurn];
        playerTurns[nextPlayer] = true;
    }


    function getPlayerAddress(uint256 turnNumber) public view returns (address) {
        require(turnNumber < numPlayers, "Invalid turn number");
        return players[turnNumber];
    }
}
