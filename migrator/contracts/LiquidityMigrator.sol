pragma solidity >=0.6.6;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import './IUniswapV2Pair.sol';
import './BonusToken.sol';


contract LiquidityMigrator {
    IUniswapV2Router02 public router;
    IUniswapV2Pair public pair;
    IUniswapV2Router02 public routerFork;
    IUniswapV2Pair public pairFork;
    BonusToken public bonusToken;
    address public admin;
    //balances of the people who invested in LP token in the contract
    //balance of th LP token initialy invested
    mapping(address => uint ) public unclaimedBalances;
    bool public migrationDone;

    constructor(
        address _router,
        address _pair,
        address _routerFork,
        address _pairFork,
        address _bonusToken
        ) public {
            //initialize all the pointers
            router = IUniswapV2Router02(_router);
            pair = IUniswapV2Pair(_pair);
            routerFork = IUniswapV2Router02(_routerFork);
            pairFork = IUniswapV2Pair(_pairFork);
            bonusToken = BonusToken(bonusToken);
            //save address of the admin
            admin = msg.sender;
        }

//first step is to deposit liquidity token in contract
        function deposit(uint amount) external {
            require(migrationDone == false, 'migration already done');
            //before call deposit, wa call approve function with the address of the contract
            pair.transferFrom(msg.sender, address(this), amount);
            //need to give the bonus token to the sender as a reward to send this LP tokens
            bonusToken.mint(msg.sender, amount);
            unclaimedBalances[msg.sender] += amount;
        }

        //when we have enough tokens, we proceed to the migration
        function migrate() external {
            require(msg.sender == admin, 'only admin');
            require(migrationDone == false, 'migration already done');
            //pointers for 2 tokens of the underlying markets
            IERC20 token0 = IERC20(pair.token0());
            IERC20 token1 = IERC20(pair.token1());
            //what is LP token balance of the smart contract
            uint totalBalance = pair.balanceOf(address(this));
            router.removeLiquidity(
                address(token0),
                address(token1),
                //LP token balance
                totalBalance,
                //possible to specify the amount
                0,
                0,
                address(this),
                //limte date : now
                block.timestamp
            );

            //whats out underlying balance
            uint token0Balance = token0.balanceOf(address(this));
            uint token1Balance = token1.balanceOf(address(this));

            //approve our uniswap to spend tokens
            token0.approve(address(routerFork), token0Balance);
            token1.approve(address(routerFork), token1Balance);

            routerFork.addLiquidity(
                address(token0),
                address(token1),
                token0Balance,
                token1Balance,
                token0Balance,
                token1Balance,
                address(this),
                block.timestamp
            );
            //the liquidity is send to the fork of the uniswap
            migrationDone = true;
        }

        //need to allocate the liquidity to the different investors
        //investors will have to individually to call the function
        //separate allocation because the large numbers management will cost money (gas cost)
        function claimLptokens() external {
            //the caller of function have some tokens
            require(unclaimedBalances[msg.sender] >= 0, 'no unclaimed balance');
            require(migrationDone == true, 'migration not done yet');
            //save the amount to send
            uint amountToSend = unclaimedBalances[msg.sender];
            //unclaimed balances are set to 0
            unclaimedBalances[msg.sender] = 0;
            //tranfser  the LP tokens to the sender of the transaction
            pairFork.transfer(msg.sender, amountToSend);
            //now the investor own the token and can redeem the underlying tokens
            //and receive the bonus tokens
            

        }

}