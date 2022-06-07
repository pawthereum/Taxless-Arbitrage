// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Pair {
    function sync() external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}

contract Pawthereum is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private _name = "Pawthereum";
    string private _symbol = "PAWTH";

    uint8 private _decimals = 9;

    mapping(address => uint256) internal _reflectionBalance;
    mapping(address => uint256) internal _tokenBalance;
    mapping(address => mapping(address => uint256)) internal _allowances;
    mapping (address => bool) public automatedMarketMakerPairs;

    uint256 private constant MAX = ~uint256(0);

    uint256 internal _tokenTotal = 1000000000e9;
    uint256 internal _reflectionTotal = (MAX - (MAX % _tokenTotal));

    mapping(address => bool) isTaxless;
    mapping(address => bool) internal _isExcluded;
    address[] internal _excluded;

    uint256 public _feeDecimal = 2;
    // 200 = 2%
    uint256 public _taxFee = 200;
    uint256 public _liquidityFee = 200;
    uint256 public _burnFee = 0;
    uint256 public _marketingFee = 200;
    uint256 public _charityFee = 200;
    uint256 public _stakingFee = 0;
    uint256 public _maxTotalFee = 1200;

    struct Purr {
        uint256 buyTaxFee;
        uint256 buyLiquidityFee;
        uint256 buyBurnFee;
        uint256 buyMarketingFee;
        uint256 buyCharityFee;
        uint256 buyStakingFee;
        uint256 sellTaxFee;
        uint256 sellLiquidityFee;
        uint256 sellBurnFee;
        uint256 sellMarketingFee;
        uint256 sellCharityFee;
        uint256 sellStakingFee;
    }

    Purr public _purr = Purr(100, 100, 0, 100, 100, 0, 400, 200, 0, 200, 400, 0);

    uint256 public _taxFeeTotal;
    uint256 public _burnFeeTotal;
    uint256 public _liquidityFeeTotal;
    uint256 public _marketingFeeTotal;
    uint256 public _charityFeeTotal;
    uint256 public _stakingFeeTotal;

    uint256 public _liquidityTokensToSwap;
    uint256 public _marketingTokensToSwap;
    uint256 public _charityTokensToSwap;

    address public marketingWallet;
    address public charityWallet;
    address public stakingWallet;

    address public lpTokenHolder = address(this);

    bool public _isPurrEnabled = false;

    bool public isTaxActive = false;
    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool public swapAndLiquifyMarketing = false;
    bool public swapAndLiquifyCharity = false;
    bool public isLpInitialized = false;

    uint256 public maxTxAmount = _tokenTotal;
    uint256 public maxTokensInSwap = 100_000e9;
    uint256 public minTokensBeforeSwap = 10_000e9;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity,
        uint256 ethIntoLiquidity,
        uint256 ethForMarketing,
        uint256 ethForCharity
    );
    event PurrUpdated(
        bool enabled,
        uint256 buyTaxFee,
        uint256 buyLiquidityFee,
        uint256 buyBurnFee,
        uint256 buyMarketingFee,
        uint256 buyCharityFee,
        uint256 buyStakingFee,
        uint256 sellTaxFee,
        uint256 sellLiquidityFee,
        uint256 sellBurnFee,
        uint256 sellMarketingFee,
        uint256 sellCharityFee,
        uint256 sellStakingFee
    );

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(address _taxWallet, address _router) public {
        marketingWallet = _taxWallet;
        stakingWallet = _taxWallet;
        charityWallet = _taxWallet;

        isTaxless[_msgSender()] = true;
        isTaxless[address(this)] = true;

        _reflectionBalance[_msgSender()] = _reflectionTotal;
        emit Transfer(address(0), _msgSender(), _tokenTotal);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            _router
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        automatedMarketMakerPairs[uniswapV2Pair] = true;
        uniswapV2Router = _uniswapV2Router;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tokenTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tokenBalance[account];
        return tokenFromReflection(_reflectionBalance[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }
  
    function isTaxlessAccount(address account) public view returns (bool) {
        return isTaxless[account];
    }

    function reflectionFromToken(uint256 tokenAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tokenAmount <= _tokenTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            return tokenAmount.mul(_getReflectionRate());
        } else {
            return
                tokenAmount
                    .sub(tokenAmount.mul(_taxFee).div(10**(_feeDecimal + 2)))
                    .mul(_getReflectionRate());
        }
    }

    function tokenFromReflection(uint256 reflectionAmount)
        public
        view
        returns (uint256)
    {
        require(
            reflectionAmount <= _reflectionTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getReflectionRate();
        return reflectionAmount.div(currentRate);
    }

    function excludeAccount(address account) external onlyOwner {
        require(
            account != address(uniswapV2Router),
            "ERC20: We can not exclude Uniswap router."
        );
        require(!_isExcluded[account], "ERC20: Account is already excluded");
        if (_reflectionBalance[account] > 0) {
            _tokenBalance[account] = tokenFromReflection(
                _reflectionBalance[account]
            );
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner {
        require(_isExcluded[account], "ERC20: Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tokenBalance[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(amount <= maxTxAmount, "Transfer Limit exceeded!");

        // total amount of tokens to swap is the accrued taxes
        uint256 totalTokensToSwap = _liquidityTokensToSwap.add(
            _marketingTokensToSwap
        ).add(
            _charityTokensToSwap
        );

        bool overMinTokenBalance = totalTokensToSwap >= minTokensBeforeSwap;
        if (
            !inSwapAndLiquify &&
            overMinTokenBalance &&
            sender != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            swapAndLiquify(totalTokensToSwap);
        }

        uint256 transferAmount = amount;
        uint256 rate = _getReflectionRate();

        if (
            isTaxActive &&
            !isTaxless[_msgSender()] &&
            !isTaxless[recipient] &&
            !inSwapAndLiquify
        ) {
            transferAmount = collectFee(sender, recipient, amount, rate);
        }

        _reflectionBalance[sender] = _reflectionBalance[sender].sub(
            amount.mul(rate)
        );
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(
            transferAmount.mul(rate)
        );

        if (_isExcluded[sender]) {
            _tokenBalance[sender] = _tokenBalance[sender].sub(amount);
        }
        if (_isExcluded[recipient]) {
            _tokenBalance[recipient] = _tokenBalance[recipient].add(
                transferAmount
            );
        }

        emit Transfer(sender, recipient, transferAmount);
    }

    function collectFee(
        address account,
        address recipient,
        uint256 amount,
        uint256 rate
    ) private returns (uint256) {
        uint256 transferAmount = amount;

        uint256 pTaxFee = _taxFee;
        uint256 pLiquidityFee = _liquidityFee;
        uint256 pBurnFee = _burnFee;
        uint256 pMarketingFee = _marketingFee;
        uint256 pCharityFee = _charityFee;
        uint256 pStakingFee = _stakingFee;
    
        // if purr is enabled and this is a buy, use special taxes
        if (_isPurrEnabled && automatedMarketMakerPairs[account]) {
            pTaxFee = _purr.buyTaxFee;
            pLiquidityFee = _purr.buyLiquidityFee;
            pBurnFee = _purr.buyBurnFee;
            pMarketingFee = _purr.buyMarketingFee;
            pCharityFee = _purr.buyCharityFee;
            pStakingFee = _purr.buyStakingFee;
        }

        // if purr is enabled and this is a sell, use special taxes
        if (_isPurrEnabled && automatedMarketMakerPairs[recipient]) {
            pTaxFee = _purr.sellTaxFee;
            pLiquidityFee = _purr.sellLiquidityFee;
            pBurnFee = _purr.sellBurnFee;
            pMarketingFee = _purr.sellMarketingFee;
            pCharityFee = _purr.sellCharityFee;
            pStakingFee = _purr.sellStakingFee;
        }

        //@dev tax fee
        if (pTaxFee != 0) {
            uint256 taxFee = amount.mul(pTaxFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(taxFee);
            _reflectionTotal = _reflectionTotal.sub(taxFee.mul(rate));
            _taxFeeTotal = _taxFeeTotal.add(taxFee);
        }

        //@dev liquidity fee
        if (pLiquidityFee != 0) {
            uint256 liquidityFee = amount.mul(pLiquidityFee).div(
                10**(_feeDecimal + 2)
            );
            transferAmount = transferAmount.sub(liquidityFee);
            _reflectionBalance[address(this)] = _reflectionBalance[
                address(this)
            ].add(liquidityFee.mul(rate));
            if (_isExcluded[address(this)]) {
                _tokenBalance[address(this)] = _tokenBalance[address(this)].add(
                    liquidityFee
                );
            }
            _liquidityTokensToSwap = _liquidityTokensToSwap.add(liquidityFee);
            _liquidityFeeTotal = _liquidityFeeTotal.add(liquidityFee);
            emit Transfer(account, address(this), liquidityFee);
        }

        //@dev burn fee
        if (pBurnFee != 0) {
            uint256 burnFee = amount.mul(pBurnFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(burnFee);
            _tokenTotal = _tokenTotal.sub(burnFee);
            _reflectionTotal = _reflectionTotal.sub(burnFee.mul(rate));
            _burnFeeTotal = _burnFeeTotal.add(burnFee);
            emit Transfer(account, address(0), burnFee);
        }

        //@dev Marketing fee
        if (pMarketingFee != 0) {
            uint256 marketingFee = amount.mul(pMarketingFee).div(
                10**(_feeDecimal + 2)
            );
            transferAmount = transferAmount.sub(marketingFee);

            if (swapAndLiquifyMarketing == false) {
                _reflectionBalance[marketingWallet] = _reflectionBalance[
                    marketingWallet
                ].add(marketingFee.mul(rate));
                if (_isExcluded[marketingWallet]) {
                    _tokenBalance[marketingWallet] = _tokenBalance[
                        marketingWallet
                    ].add(marketingFee);
                }
                emit Transfer(account, marketingWallet, marketingFee);
            } else {
                _reflectionBalance[address(this)] = _reflectionBalance[
                    address(this)
                ].add(marketingFee.mul(rate));
                if (_isExcluded[address(this)]) {
                    _tokenBalance[address(this)] = _tokenBalance[address(this)].add(
                        marketingFee
                    );
                }
                _marketingTokensToSwap = _marketingTokensToSwap.add(marketingFee);
                emit Transfer(account, address(this), marketingFee);
            }

            _marketingFeeTotal = _marketingFeeTotal.add(marketingFee);
        }

        //@dev Charity fee
        if (pCharityFee != 0) {
            uint256 charityFee = amount.mul(pCharityFee).div(
                10**(_feeDecimal + 2)
            );
            transferAmount = transferAmount.sub(charityFee);

            if (swapAndLiquifyCharity == false) {
                _reflectionBalance[charityWallet] = _reflectionBalance[
                    charityWallet
                ].add(charityFee.mul(rate));
                if (_isExcluded[charityWallet]) {
                    _tokenBalance[charityWallet] = _tokenBalance[
                        charityWallet
                    ].add(charityFee);
                }
                emit Transfer(account, charityWallet, charityFee);
            } else {
                _reflectionBalance[address(this)] = _reflectionBalance[
                    address(this)
                ].add(charityFee.mul(rate));
                if (_isExcluded[address(this)]) {
                    _tokenBalance[address(this)] = _tokenBalance[address(this)].add(
                        charityFee
                    );
                }
                _charityTokensToSwap = _charityTokensToSwap.add(charityFee);
                emit Transfer(account, address(this), charityFee);
            }

            _charityFeeTotal = _charityFeeTotal.add(charityFee);
        }

        //@dev Staking fee
        if (pStakingFee != 0) {
            uint256 stakingFee = amount.mul(pStakingFee).div(
                10**(_feeDecimal + 2)
            );
            transferAmount = transferAmount.sub(stakingFee);
            _reflectionBalance[stakingWallet] = _reflectionBalance[
                stakingWallet
            ].add(stakingFee.mul(rate));
            if (_isExcluded[stakingWallet]) {
                _tokenBalance[stakingWallet] = _tokenBalance[stakingWallet].add(
                    stakingFee
                );
            }
            _stakingFeeTotal = _stakingFeeTotal.add(stakingFee);
            emit Transfer(account, stakingWallet, stakingFee);
        }

        return transferAmount;
    }

    function _getReflectionRate() private view returns (uint256) {
        uint256 reflectionSupply = _reflectionTotal;
        uint256 tokenSupply = _tokenTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _reflectionBalance[_excluded[i]] > reflectionSupply ||
                _tokenBalance[_excluded[i]] > tokenSupply
            ) return _reflectionTotal.div(_tokenTotal);
            reflectionSupply = reflectionSupply.sub(
                _reflectionBalance[_excluded[i]]
            );
            tokenSupply = tokenSupply.sub(_tokenBalance[_excluded[i]]);
        }
        if (reflectionSupply < _reflectionTotal.div(_tokenTotal))
            return _reflectionTotal.div(_tokenTotal);
        return reflectionSupply.div(tokenSupply);
    }

    function swapAndLiquify(uint256 totalTokensToSwap) private lockTheSwap {
        // percentage of the total tokens swapped for each tax
        uint256 liquidityRate = _liquidityTokensToSwap.mul(10**(_feeDecimal + 2)).div(totalTokensToSwap);
        uint256 marketingRate = _marketingTokensToSwap.mul(10**(_feeDecimal + 2)).div(totalTokensToSwap);
        uint256 charityRate = _charityTokensToSwap.mul(10**(_feeDecimal + 2)).div(totalTokensToSwap);

        // cannot swap more than what is in the contract address balance
        uint256 contractBalance = balanceOf(address(this));
        if (totalTokensToSwap > contractBalance) {
            totalTokensToSwap = contractBalance;
        }

        // never swap more than the max tokens allowed in a swap
        if (totalTokensToSwap > maxTokensInSwap) {
            totalTokensToSwap = maxTokensInSwap;
        }

        // derive how many tokens we are actually going to swap
        // based on the new total amount (in case it was over the maximum)
        uint256 liquidityAmount = totalTokensToSwap.mul(liquidityRate).div(10**(_feeDecimal + 2));
        uint256 marketingAmount = totalTokensToSwap.mul(marketingRate).div(10**(_feeDecimal + 2));
        uint256 charityAmount = totalTokensToSwap.mul(charityRate).div(10**(_feeDecimal + 2));

        // halve the amount of liquidity tokens
        uint256 tokensForLiquidity = liquidityAmount.div(2);
        uint256 amountToSwapForEth = totalTokensToSwap.sub(tokensForLiquidity);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(amountToSwapForEth);

        uint256 newBalance = address(this).balance.sub(initialBalance);

        // divy up the eth based on the rates
        uint256 ethForMarketing = newBalance.mul(marketingAmount).div(amountToSwapForEth);
        uint256 ethForCharity = newBalance.mul(charityAmount).div(amountToSwapForEth);
        uint256 ethForLiquidity = newBalance.mul(tokensForLiquidity).div(amountToSwapForEth);

        payable(marketingWallet).transfer(ethForMarketing);
        payable(charityWallet).transfer(ethForCharity);

        addLiquidity(tokensForLiquidity, ethForLiquidity);

        // reset values based on how much was used
        _liquidityTokensToSwap = _liquidityTokensToSwap.sub(liquidityAmount);
        _marketingTokensToSwap = _marketingTokensToSwap.sub(marketingAmount);
        _charityTokensToSwap = _charityTokensToSwap.sub(charityAmount);

        emit SwapAndLiquify(
            amountToSwapForEth, 
            newBalance, 
            tokensForLiquidity,
            ethForLiquidity,
            ethForMarketing,
            ethForCharity
        );
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            lpTokenHolder,
            block.timestamp
        );
    }

    function setLpTokenHolder(address _newLpTokenHolder) external onlyOwner {
        lpTokenHolder = _newLpTokenHolder;
    }

    function setPair(address pair) external onlyOwner {
        uniswapV2Pair = pair;
    }

    function setMarketingWallet(address account) external onlyOwner {
        marketingWallet = account;
    }

    function setCharityWallet(address account) external onlyOwner {
        charityWallet = account;
    }
  
    function setStakingWallet(address account) external onlyOwner {
        stakingWallet = account;
    }

    function setTaxless(address account, bool value) external onlyOwner {
        isTaxless[account] = value;
    }

    function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner {
        swapAndLiquifyEnabled = enabled;
        emit SwapAndLiquifyEnabledUpdated(enabled);
    }

    function setTaxActive(bool value) external onlyOwner {
        isTaxActive = value;
    }

    function setTaxFee(uint256 fee) external onlyOwner {
        _taxFee = fee;
        uint feeTotal = _burnFee.add(_liquidityFee).add(_marketingFee).add(_stakingFee).add(_charityFee).add(_taxFee);
        require(feeTotal <= _maxTotalFee, "Total fee cannot exceed maximum");
    }

    function setBurnFee(uint256 fee) external onlyOwner {
        _burnFee = fee;
        uint feeTotal = _burnFee.add(_liquidityFee).add(_marketingFee).add(_stakingFee).add(_charityFee).add(_taxFee);
        require(feeTotal <= _maxTotalFee, "Total fee cannot exceed maximum");
    }

    function setLiquidityFee(uint256 fee) external onlyOwner {
        _liquidityFee = fee;
        uint feeTotal = _burnFee.add(_liquidityFee).add(_marketingFee).add(_stakingFee).add(_charityFee).add(_taxFee);
        require(feeTotal <= _maxTotalFee, "Total fee cannot exceed maximum");
    }

    function setMarketingFee(uint256 fee) external onlyOwner {
        _marketingFee = fee;
        uint feeTotal = _burnFee.add(_liquidityFee).add(_marketingFee).add(_stakingFee).add(_charityFee).add(_taxFee);
        require(feeTotal <= _maxTotalFee, "Total fee cannot exceed maximum");
    }

    function setCharityFee(uint256 fee) external onlyOwner {
        _charityFee = fee;
        uint feeTotal = _burnFee.add(_liquidityFee).add(_marketingFee).add(_stakingFee).add(_charityFee).add(_taxFee);
        require(feeTotal <= _maxTotalFee, "Total fee cannot exceed maximum");
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {
        maxTxAmount = amount;
    }
  
    function setMaxTokensInSwap(uint256 amount) external onlyOwner {
        maxTokensInSwap = amount;
    }

    function setMinTokensBeforeSwap(uint256 amount) external onlyOwner {
        minTokensBeforeSwap = amount;
    }

    function setSwapAndLiquifyMarketing(bool enabled) external onlyOwner {
        swapAndLiquifyMarketing = enabled;
    }

    function setSwapAndLiquifyCharity(bool enabled) external onlyOwner {
        swapAndLiquifyCharity = enabled;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
    }
  
    function setRouterAddress(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function setPurr(
        bool enabled,
        uint256 buyTaxFee,
        uint256 buyLiquidityFee,
        uint256 buyBurnFee,
        uint256 buyMarketingFee,
        uint256 buyCharityFee,
        uint256 buyStakingFee,
        uint256 sellTaxFee,
        uint256 sellLiquidityFee,
        uint256 sellBurnFee,
        uint256 sellMarketingFee,
        uint256 sellCharityFee,
        uint256 sellStakingFee
    ) external onlyOwner {
        require(enabled != _isPurrEnabled, "Purr value already set");

        uint256 totalBuyFee = _addThreeUints(buyTaxFee, buyLiquidityFee, buyBurnFee).add(
            _addThreeUints(buyMarketingFee, buyCharityFee, buyStakingFee)
        );
        require(totalBuyFee <= _maxTotalFee, "Total fee cannot exceed maximum");

        uint256 totalSellFee = _addThreeUints(sellTaxFee, sellLiquidityFee, sellBurnFee).add(
            _addThreeUints(sellMarketingFee, sellCharityFee, sellStakingFee)
        );
        require(totalSellFee <= _maxTotalFee, "Total fee cannot exceed maximum");

        _purr = Purr(
            buyTaxFee,
            buyLiquidityFee,
            buyBurnFee,
            buyMarketingFee,
            buyCharityFee,
            buyStakingFee,
            sellTaxFee,
            sellLiquidityFee,
            sellBurnFee,
            sellMarketingFee,
            sellCharityFee,
            sellStakingFee
        );

        _isPurrEnabled = enabled;

        emit PurrUpdated(
            enabled, 
            buyTaxFee, 
            buyLiquidityFee,
            buyBurnFee,
            buyMarketingFee,
            buyCharityFee,
            buyStakingFee,
            sellTaxFee,
            sellLiquidityFee,
            sellBurnFee,
            sellMarketingFee,
            sellCharityFee,
            sellStakingFee
        );
    }

    function _addThreeUints(uint256 a, uint256 b, uint256 c) private pure returns (uint256) {
        return a.add(b).add(c);
    }
  
    function withdrawTokenToOwner(address tokenAddress, uint256 amount) external onlyOwner {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        require(balance >= amount, "Insufficient token balance");

        if (tokenAddress == address(this)) {
            uint256 tokensToSwap = _liquidityTokensToSwap.add(_marketingTokensToSwap).add(_charityTokensToSwap);
            uint256 remainingTokens = balance.sub(amount);

            // if removing more tokens than what is set aside to swap,
            // update the amount set aside while keeping proportions
            if (remainingTokens < tokensToSwap) {
                uint256 liquidityRate = _liquidityTokensToSwap.mul(10**(_feeDecimal + 2)).div(tokensToSwap);
                uint256 marketingRate = _marketingTokensToSwap.mul(10**(_feeDecimal + 2)).div(tokensToSwap);
                uint256 charityRate = _charityTokensToSwap.mul(10**(_feeDecimal + 2)).div(tokensToSwap);

                uint256 newLiquidityAmountToSwap = remainingTokens.mul(liquidityRate).div(10**(_feeDecimal + 2));
                uint256 newMarketingAmountToSwap = remainingTokens.mul(marketingRate).div(10**(_feeDecimal + 2));
                uint256 newCharityAmountToSwap = remainingTokens.mul(charityRate).div(10**(_feeDecimal + 2));

                _liquidityFeeTotal = _liquidityFeeTotal.sub(_liquidityTokensToSwap).add(newLiquidityAmountToSwap);
                _marketingFeeTotal = _marketingFeeTotal.sub(_marketingTokensToSwap).add(newMarketingAmountToSwap);
                _charityFeeTotal = _charityFeeTotal.sub(_charityTokensToSwap).add(newCharityAmountToSwap);

                _liquidityTokensToSwap = newLiquidityAmountToSwap;
                _marketingTokensToSwap = newMarketingAmountToSwap;
                _charityTokensToSwap = newCharityAmountToSwap;
            }
        }

        IERC20(tokenAddress).transfer(_msgSender(), amount);
    }

    function withdrawEthToOwner (uint256 _amount) external onlyOwner {
        payable(_msgSender()).transfer(_amount);
    }

    function initLp () external payable onlyOwner {
        require(isLpInitialized == false, "LP already initialized");
        uint256 contractTokenBalance = balanceOf(address(this));
        addLiquidity(contractTokenBalance, msg.value);
        _liquidityFee = 9000;
        isTaxActive = true;
        swapAndLiquifyEnabled = true;
        isLpInitialized = true;
    }

    receive() external payable {}
}