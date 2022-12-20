// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract GasparyanGame {
    struct Participant {
        address payable player_address;
        uint256 ready_to_play;
        uint256 choice;
        bytes32 move;
    }

    

    uint256 public bettedValue = 0;

    event PlyerAdded(address player);
    event PlayerAddSymbol(address player);
    event PlayerReveal(address player, uint256 choice);
    event PlayerPayed(address player, uint256 amount);

    Participant first_part = Participant(payable(address(0x0)), 1, 0, 0x0);
    Participant second_part = Participant(payable(address(0x0)), 1, 0, 0x0);

    modifier bet_value() {
        require(msg.value > 0);

        _;
    }

    modifier can_apply() {
        require(
            (first_part.player_address == payable(address(0x0)) ||
                second_part.player_address == payable(address(0x0))) &&
                (first_part.ready_to_play == 1 ||
                    second_part.ready_to_play == 1) &&
                (first_part.move == 0x0 || second_part.move == 0x0) &&
                (first_part.choice == 0 || second_part.choice == 0)
        );

        _;
    }


    function add_player()
        public
        payable
        can_apply
        bet_value
        returns (uint256)
    {
        if (first_part.ready_to_play == 1) {
            if (second_part.ready_to_play == 1) {
                bettedValue = msg.value;
            } else {
                require(bettedValue == msg.value, "invalid value");
            }

            first_part.player_address = payable(msg.sender);
            first_part.ready_to_play = 2;

            emit PlyerAdded(msg.sender);
            return 1;
        } else if (second_part.ready_to_play == 1) {
            if (first_part.ready_to_play == 1) {
                bettedValue = msg.value;
            } else {
                require(bettedValue == msg.value, "invalid value");
            }

            second_part.player_address = payable(msg.sender);
            second_part.ready_to_play = 2;

            emit PlyerAdded(msg.sender);
            return 2;
        }
        return 0;
    }

    modifier is_ready() {
        require(
            (first_part.player_address != payable(address(0x0)) &&
                second_part.player_address != payable(address(0x0))) &&
                (first_part.choice == 0 && second_part.choice == 0) &&
                (first_part.move == 0x0 || second_part.move == 0x0) &&
                (first_part.ready_to_play == 2 ||
                    second_part.ready_to_play == 2)
        );
        _;
    }

    modifier is_player_added() {
        require(
            msg.sender == first_part.player_address ||
                msg.sender == second_part.player_address
        );

        _;
    }

    function go(bytes32 move) public is_ready is_player_added returns (bool) {
        if (msg.sender == first_part.player_address && first_part.move == 0x0) {
            first_part.move = move;
            first_part.ready_to_play = 3;
        } else if (
            msg.sender == second_part.player_address && second_part.move == 0x0
        ) {
            second_part.move = move;
            second_part.ready_to_play = 3;
        } else {
            return false;
        }
        emit PlayerAddSymbol(msg.sender);
        return true;
    }

    modifier ready_for_show() {
        require(
            (first_part.choice == 0 || second_part.choice == 0) &&
                (first_part.move != 0x0 && second_part.move != 0x0) &&
                (first_part.ready_to_play == 3 ||
                    second_part.ready_to_play == 3)
        );
        _;
    }

    function show(uint256 choice, string calldata pad)
        public
        ready_for_show
        is_player_added
        returns (bool)
    {
        if (msg.sender == first_part.player_address) {
            require(
                sha256(abi.encodePacked(msg.sender, choice, pad)) ==
                    first_part.move,
                "exception"
            );

            first_part.choice = choice;
            first_part.ready_to_play = 4;

            emit PlayerReveal(msg.sender, choice);
            return true;
        } else if (msg.sender == second_part.player_address) {
            require(
                sha256(abi.encodePacked(msg.sender, choice, pad)) ==
                    second_part.move,
                "exception"
            );
            second_part.choice = choice;

            second_part.ready_to_play = 4;

            emit PlayerReveal(msg.sender, choice);
            return true;
        }
        return false;
    }

    modifier ready_for_pay() {
        require(
            (first_part.choice != 0 && second_part.choice != 0) &&
                (first_part.move != 0x0 && second_part.move != 0x0) &&
                (first_part.ready_to_play == 4 &&
                    second_part.ready_to_play == 4)
        );
        _;
    }

    function find_win() public ready_for_pay is_player_added returns (uint256) {
        if (first_part.choice == second_part.choice) {
            address payable firstMember = first_part.player_address;
            address payable secondMember = first_part.player_address;
            uint256 amount = bettedValue;
            end();
            firstMember.transfer(amount);
            secondMember.transfer(amount);
            emit PlayerPayed(firstMember, amount);
            emit PlayerPayed(secondMember, amount);
            return 0;
        } else if (
            (first_part.choice == 1 && second_part.choice == 3) ||
            (first_part.choice == 2 && second_part.choice == 1) ||
            (first_part.choice == 3 && second_part.choice == 2)
        ) {
            address payable winnerMember = first_part.player_address;
            uint256 amount = 2 * bettedValue;
            end();
            winnerMember.transfer(amount);
            emit PlayerPayed(winnerMember, amount);
            return 1;
        } else {
            address payable winnerMember = second_part.player_address;
            uint256 amount = 2 * bettedValue;
            end();
            winnerMember.transfer(amount);
            emit PlayerPayed(winnerMember, amount);
            return 2;
        }
    }

    function end() private {
        first_part = Participant(payable(address(0x0)), 1, 0, 0x0);
        second_part = Participant(payable(address(0x0)), 1, 0, 0x0);
        bettedValue = 0;
    }
}
