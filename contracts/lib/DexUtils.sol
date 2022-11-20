// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";

contract DexUtils is Ownable {
    using SafeMath for uint256;

    address internal factoryAddress = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    function getFactoryAddress() public view returns (address) {
        return factoryAddress;
    }
    function setFactoryAddress(address _account) public onlyOwner {
        factoryAddress = _account;
    }


    function getPairPrice(
        address _token0,
        address _token1
    ) public view returns (uint256 price) {
        if (_token0 == _token1) {
            return 1e18;
        }
        IUniswapV2Factory factory = IUniswapV2Factory(factoryAddress);
        address pairAddr = factory.getPair(_token0, _token1);
        if (pairAddr == address(0)) {
            return 0;
        }
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddr);
        address token0 = pair.token0();
        address token1 = pair.token1();
        uint8 decimal0 = ERC20(token0).decimals();
        uint8 decimal1 = ERC20(token1).decimals();
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        if (token0 == _token0) {
            price = reserve1.mul(10**decimal0).mul(1e18).div(reserve0).div(
                10**decimal1
            );
        } else {
            price = reserve0.mul(10**decimal1).mul(1e18).div(reserve1).div(
                10**decimal0
            );
        }
    }

    function getLPTokenInfo(address _lptoken)
    external
    view
    returns (
        address token0,
        uint8 decimals0,
        string memory symbol0,
        address token1,
        uint8 decimals1,
        string memory symbol1
    )
    {
        IUniswapV2Pair pair = IUniswapV2Pair(_lptoken);
        token0 = pair.token0();
        token1 = pair.token1();
        decimals0 = ERC20(token0).decimals();
        decimals1 = ERC20(token1).decimals();
        symbol0 = ERC20(token0).symbol();
        symbol1 = ERC20(token1).symbol();
    }

    function getReleaseLiquidity(address _lptoken, uint256 _amountlp)
    public
    view
    returns (uint256 amount0, uint256 amount1)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(_lptoken);
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        uint256 total = pair.totalSupply();
        amount0 = reserve0.mul(_amountlp).div(total);
        amount1 = reserve1.mul(_amountlp).div(total);
    }
}
