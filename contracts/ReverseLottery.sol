//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

contract ReverseLottery {
    struct Round {
        mapping(address => bool) playerToClaims;
        address[] players;
        address loser;
        uint256 playerCount;
        uint256 potAmt;
        uint256 expiry;
        bool state;
    }

    uint256 public lockIn;
    uint256 public roundId;
    uint256 public roundSize;
    uint256 public roundDuration;
    uint256 public storedSeed;
    uint256 public houseFeePercent;
    uint256 public houseFees;
    address private gameMaster;

    mapping(uint256 => Round) public rounds;

    modifier onlyGameMaster() {
        require(msg.sender == gameMaster, "ONLY_GAME_MASTER");

        _;
    }

    constructor(
        uint256 newLockIn,
        uint256 newRoundDuration,
        uint256 newStoredSeed,
        uint256 newHouseFeePercent,
        address newGameMaster
    ) {
        lockIn = newLockIn;
        roundDuration = newRoundDuration;
        storedSeed = newStoredSeed;
        houseFeePercent = newHouseFeePercent;
        gameMaster = newGameMaster;
        startRound();
        collectRandomness();
    }

    function startRound() public {
        uint256 id = roundId++;

        Round storage round = rounds[id];
        round.expiry = block.timestamp + roundDuration;
        round.state = true;

        collectRandomness();
    }

    function collectRandomness() public {
        storedSeed ^= block.prevrandao;
    }

    function endRound() external {
        Round storage round = rounds[roundId];

        require(block.timestamp >= round.expiry, "ROUND_HAS_NOT_EXPIRED");

        collectRandomness();

        address loserAddr = round.players[storedSeed % round.playerCount];
        round.loser = loserAddr;
        round.playerToClaims[loserAddr] = false;
        --round.playerCount;
        round.state = false;
        uint256 potAmt = round.playerCount * lockIn;
        uint256 houseFee = (potAmt * houseFeePercent) / 100;

        houseFees += houseFee;
        round.potAmt = potAmt - (2 * houseFee);

        roundSize = 0;

        msg.sender.call{value: houseFee}("");
    }

    function claim(uint256 id) external {
        Round storage round = rounds[id];

        require(!round.state, "ROUND_IS_OPEN");
        require(round.playerToClaims[msg.sender], "NOT_ELIGIBLE_TO_CLAIM");

        round.playerToClaims[msg.sender] = false;

        collectRandomness();

        msg.sender.call{value: round.potAmt / round.playerCount}("");
    }

    function withdraw() external {
        gameMaster.call{value: houseFees}("");
    }

    function transferOwnership(address newGameMaster) external onlyGameMaster {
        gameMaster = newGameMaster;
    }

    function changeRoundDuration(
        uint256 newRoundDuration
    ) external onlyGameMaster {
        roundDuration = newRoundDuration;
    }

    function enter() external payable {
        require(msg.value == lockIn, "INCORRECT_LOCKIN_AMOUNT");

        Round storage round = rounds[roundId];

        require(round.state, "ROUND_IS_CLOSED");

        round.playerToClaims[msg.sender] = true;

        unchecked {
            ++roundSize;
        }

        collectRandomness();
    }

    function exit() external payable {
        require(roundSize == 1, "GAME_IS_ACTIVE");

        Round storage round = rounds[roundId];

        require(round.state, "ROUND_IS_CLOSED");

        round.state = false;

        round.playerToClaims[msg.sender] = false;

        collectRandomness();

        msg.sender.call{value: lockIn}("");
    }
}
