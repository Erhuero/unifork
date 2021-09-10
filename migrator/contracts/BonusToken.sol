pragma solidity =0.6.6;

//contract to receive bonuses when deposit
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract BonusToken is ERC20{
    //save a deployment address
    address public admin;
    address public liquidator;
    //trigger a constructor of the token
    constructor() ERC20('Bonus Token', 'BTK') public {
        admin = msg.sender;
    }

    function setLiquidator(address _liquidator) external {
        require(msg.sender == admin, 'only admin');
        liquidator = _liquidator;
    }

    //mint/create bonus token everytime someone sned the LP token
    function mint(address to, uint amount) external {
        require(msg.sender == liquidator, 'only liquidator');
        //inheritance from ERC20
        //give the bonus to investor
        _mint(to, amount);
    }
}