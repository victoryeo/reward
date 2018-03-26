pragma solidity ^0.4.17;

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Reward is ERC20Interface, SafeMath {

  string public symbol;
  string public symbolname;
  uint8 public decimals;
  uint public _totalSupply;
  address public  manager;
  uint constant RANGE = 5;

  struct employeeReferralData {
    address employeeID;
    string name;
    string addr;
    uint phone;
    uint custID;
    uint status;
    uint time;
  }

  struct fulfilledData {
    address employeeID;
    uint custID;
    uint status;
    uint time;
  }

  uint public nextReferral;
  uint public nextFulfilled;
  mapping(uint => employeeReferralData) public referrals;
  mapping(uint => fulfilledData) public fulfilleds;
  mapping(address => uint) public balances;
  mapping(address => mapping(address => uint)) allowed;

  function Reward() public {
    symbol = "TNB";
    symbolname = "TNB Rewards Token";
    decimals = 18;
    _totalSupply = 100000000000000000000000000;
    manager = msg.sender;
    balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender , _totalSupply);
  }

  function order_start(address employeeID, string name, string addr, uint phone,
      uint time) public  {
    referrals[nextReferral].employeeID = employeeID;
    referrals[nextReferral].name = name;
    referrals[nextReferral].addr = addr;
    referrals[nextReferral].phone = phone;
    referrals[nextReferral].custID = random(name, addr, phone);
    referrals[nextReferral].status = 0;
    referrals[nextReferral].time = time;
    nextReferral++;
  }

  function fulfill_start(uint referralID, uint time) public {

    referrals[referralID].status = 1;
    //remove_referral_item(referralID);
    add_fulfilled_item(referrals[referralID].employeeID, referrals[referralID].custID, time);

    token_create(referrals[referralID].employeeID);
  }

  function random(string name, string addr, uint phone) private pure
      returns (uint) {
    return uint(keccak256(name, addr, phone));
  }

  //function remove_referral_item(uint index) private {
  //  delete referrals[index];
  //  nextReferral--;
  //}

  function add_fulfilled_item(address employeeID, uint custID, uint time) private {
    fulfilleds[nextFulfilled].employeeID = employeeID;
    fulfilleds[nextFulfilled].custID = custID;
    fulfilleds[nextFulfilled].status = 1;
    fulfilleds[nextFulfilled].time = time;
    nextFulfilled++;
  }

  modifier checking(uint start) {
    require ((start + RANGE) < nextFulfilled);
    _;
  }

  function return_custID(uint start) public view
      returns (uint[RANGE]) {

    uint[RANGE] memory datas ;

    for (uint i = 0; i < RANGE ; i++) {
      datas[i] = referrals[start + i].custID;
    }
    return datas;
  }

  function return_status(uint start) public view
      returns (uint[RANGE]) {

    uint[RANGE] memory datas ;

    for (uint i = 0; i < RANGE ; i++) {
      datas[i] = referrals[start + i].status;
    }
    return datas;
  }

  //added by Gan
  function return_referral_status(address employeeID) public view returns (uint8[2]) {
    uint8 submitted = 0;
    uint8 fulfilled = 0;

    for  (uint i = 0; i < nextReferral; i++) {
        if (referrals[i].employeeID == employeeID) {
            submitted++;
            if (referrals[i].status == 1) {
                fulfilled++;
            }
        }
    }

    return [submitted, fulfilled];
  }

  function token_create(address employeeID) public {

    //tokens[employeeID]++;
    transfer(employeeID, 1);
  }

  function token_redeem(address employeeID, uint amount) public  {
    //tokens[employeeID] = tokens[employeeID] - amount ;

    approve(employeeID, amount);
    transferFrom(employeeID, manager, amount);
  }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[manager][from] = safeSub(allowed[manager][from], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[manager][spender] = tokens;
        emit Approval(manager, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account. The spender contract function
    // receiveApproval(...) is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }
}
