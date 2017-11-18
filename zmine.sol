pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */
contract Ownable {
  address public owner;  
  /** 
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }  
  /**
   * @dev Throws if called by any account other than the owner. 
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to. 
   */
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

/**
 * @title Authorizable
 * @dev The Authorizable contract has authorized addresses, and provides basic authorization control
 * functions, this simplifies the implementation of "multiple user permissions".
 */
contract Authorizable is Ownable {
  mapping(address => bool) public authorized;
  
  event AuthorizationSet(address indexed addressAuthorized, bool indexed authorization);

  /**
   * @dev The Authorizable constructor sets the first `authorized` of the contract to the sender
   * account.
   */ 
  function Authorizable() public {
	authorized[msg.sender] = true;
  }

  /**
   * @dev Throws if called by any account other than the authorized.
   */
  modifier onlyAuthorized() {
    require(authorized[msg.sender]);
    _;
  }

 /**
   * @dev Allows the current owner to set an authorization.
   * @param addressAuthorized The address to change authorization.
   */
  function setAuthorized(address addressAuthorized, bool authorization) onlyOwner public {
    require(authorized[addressAuthorized] != authorization);
    AuthorizationSet(addressAuthorized, authorization);
    authorized[addressAuthorized] = authorization;
  }
  
}

/**
 * @title WhiteList
 * @dev The WhiteList contract has whiteListed addresses, and provides basic whiteListStatus control
 * functions, this simplifies the implementation of "multiple user permissions".
 */
contract WhiteList is Authorizable {
  mapping(address => bool) whiteListed;
  
  event WhiteListSet(address addressWhiteListed, bool whiteListStatus);

  /**
   * @dev The WhiteList constructor sets the first `whiteListed` of the contract to the sender
   * account.
   */ 
  function WhiteList() public {
	  whiteListed[msg.sender] = true;
  }

  /**
   * @dev Throws if called by any account other than the whiteListed.
   */
  modifier onlyWhiteListed() {
    require(whiteListed[msg.sender]);
    _;
  }

  function isWhiteListed(address _address) public constant returns(bool) {
    return whiteListed[_address];
  }

 /**
   * @dev Allows the current owner to set an whiteListStatus.
   * @param addressWhiteListed The address to change whiteListStatus.
   */
  function setwhiteListed(address addressWhiteListed, bool whiteListStatus) onlyAuthorized public {
    require(whiteListed[addressWhiteListed] != whiteListStatus);
    WhiteListSet(addressWhiteListed, whiteListStatus);
    whiteListed[addressWhiteListed] = whiteListStatus;
  }
  
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract TreasureBox {
  // ERC20 basic token contract being held
  ZMINE token;
  // beneficiary of tokens after they are released
  address public beneficiary;
  // timestamp where token release is enabled
  uint public releaseTime;

  function TreasureBox(ZMINE _token, address _beneficiary, uint _releaseTime) public {
    // require(_releaseTime > now); // prevent error
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  function claim() external {
    // require(msg.sender == beneficiary); // any one can claim
    require(now >= releaseTime);

    uint amount = token.balanceOf(this);
    require(amount > 0);

    token.transfer(beneficiary, amount);
  }

  function avalible() public constant returns (bool) {
    return (now >= releaseTime);
  }

  function amount() public constant returns (uint256) {
    return token.balanceOf(this);
  }
}

contract AirDropToken is StandardToken, Ownable {
  mapping (address => bool) holders;
  address[] holdersList;

  mapping (address => bool) exchanger;
  mapping (address => address) airDropDestination;

  mapping (address => bool) treasureBox;

  event SetDestination(address _address, address _destition);
  event SetExchanger(address _address, bool _isExchanger);
  event AirDrop(address _holder, address _recipient, uint _value);

  function AirDropToken() public {
    holders[owner] = true;
    holdersList.length++;
    holdersList[holdersList.length-1] = owner;
  }

  function setTreasureBox(address _address, bool _status) public {
    if (treasureBox[_address] != _status) {treasureBox[_address] = _status;}
  }

  function setExchanger(address _address, bool _isExchanger) public {
    exchanger[_address] = _isExchanger;

    if (holders[_address] == false) {
      // push to holdersList
      holders[_address] = true;
      holdersList.length++;
      holdersList[holdersList.length-1] = _address;
    }

    SetExchanger(_address, _isExchanger);
  }

  function setAirDropDestination(address _destination) public {
    airDropDestination[msg.sender] = _destination;

    SetDestination(msg.sender, _destination);
  }

  function setAirDropDestinationAndApprove(address _destination, uint _value) public {
    allowed[msg.sender][_destination] = _value;
    airDropDestination[msg.sender] = _destination;
    
    Approval(msg.sender, _destination, _value);
    SetDestination(msg.sender, _destination);
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    // require(_value <= balances[msg.sender]);
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);

    if (holders[_to] == false) {
      // push to holdersList
      holders[_to] = true;
      holdersList.length++;
      holdersList[holdersList.length-1] = _to;
    }

    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);

    if (holders[_to] == false) {
      // push to holdersList
      holders[_to] = true;
      holdersList.length++;
      holdersList[holdersList.length-1] = _to;
    }

    return true;
  }

  function getHolders()public constant returns(address[]) {
    return holdersList;
  }

  function isExchanger(address _address) public constant returns (bool) {
    return exchanger[_address];
  }

  function getAirdropDestination(address _holder) public constant returns (address) {
    return airDropDestination[_holder];
  }

  function airDrop(uint _value) public onlyOwner {
    uint sumTotal = 0;
    address holder = 0x0;
    uint tokenHolding = 0;
    for (uint i = 0; i < holdersList.length; i++) {
      holder = holdersList[i];
      tokenHolding = balances[holder];
      if ((!treasureBox[holder] && tokenHolding >= 1000 ether && holder != owner) || exchanger[airDropDestination[holder]] || exchanger[holder]) {
        sumTotal = sumTotal.add(tokenHolding);
      }
    }

    for (uint j = 0; j < holdersList.length; j++) {
      holder = holdersList[j];
      tokenHolding = balances[holder];
      if ((!treasureBox[holder] && tokenHolding >= 1000 ether && holder != owner) || exchanger[airDropDestination[holder]] || exchanger[holder]) {
        uint tokens = _value.mul(tokenHolding).div(sumTotal);
        require(balances[msg.sender] >= tokens);
        if (exchanger[airDropDestination[holder]] || exchanger[holder]) {
          balances[airDropDestination[holder]] = balances[airDropDestination[holder]].add(tokens);
          balances[msg.sender] = balances[msg.sender].sub(tokens);
          AirDrop(holder, airDropDestination[holder], tokens);
        } else {
          balances[holder] = balances[holder].add(tokens);
          balances[msg.sender] = balances[msg.sender].sub(tokens);
          AirDrop(holder, holder, tokens);
        }
      }
    }
  }

}

/**
 * @title TemToken
 * @dev The main ZMINE token contract
 * 
 * ABI 
 * [{"constant":true,"inputs":[],"name":"mintingFinished","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"startTrading","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"mint","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"tradingStarted","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"finishMinting","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Mint","type":"event"},{"anonymous":false,"inputs":[],"name":"MintFinished","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]
 */
contract ZMINE is AirDropToken {
  string public name = "ZMINE Token";
  string public symbol = "ZMN";
  uint public decimals = 18;

  uint256 public totalSupply = 1000000000 ether; // 1,000,000,000 ^ 18

  function ZMINE() public {
    balances[owner] = totalSupply;
  }

  /**
   * burn token if token is not sold out after ico
   */
  function burn(uint _amount) public onlyOwner {
    require(balances[owner] >= _amount);
    balances[owner] = balances[owner] - _amount;
    totalSupply = totalSupply - _amount;
  }
}

contract RateContract is Authorizable {
  uint rate = 6000 ether;

  function updateRate (uint _rate) public onlyAuthorized {
    require(rate != _rate);
    rate = _rate;
  }

  function getRate () public constant returns (uint) {
    return rate;
  }
}

contract ICOSale is Ownable {
  using SafeMath for uint;

  event TokenSold(address _recipient, uint _value, uint _tokens, uint _rate);
  event IncreaseHaedCap(uint amount);

  ZMINE public token;

  WhiteList whitelistICO;
  WhiteList whitelistPRE;

  uint public hardCap = 400000000 ether;
  uint public remain = 400000000 ether;

  uint public startDate = 1515376800;
  uint public stopDate = 1517364000;

  uint public minTx = 1 ether;
  uint public maxTx = 100000 ether;

  RateContract rateContract;

  function ICOSale (ZMINE _token, RateContract _rateContract, WhiteList _whitelistPRE, WhiteList _whitelistICO) public {
    token = ZMINE(_token);
    rateContract = RateContract(_rateContract);
    whitelistPRE = WhiteList(_whitelistPRE);
    whitelistICO = WhiteList(_whitelistICO);
  }

  /**
   * increase hard cap if previous dont sold out
   */
  function increaseHardCap(uint amount) public onlyOwner {
    hardCap = hardCap + amount;
    remain = remain + amount;
    IncreaseHaedCap(amount);
  }

  function sale(address _recipient, uint _value) private {
    require(now > startDate && now < stopDate);
    require(whitelistPRE.isWhiteListed(_recipient) || (whitelistICO.isWhiteListed(_recipient)));
    require(_value >= minTx && _value <= maxTx && _value <= remain);
    uint rate = this.rate();
    uint tokens = rate.mul(_value).div(1 ether);

    remain = remain.sub(tokens);
    token.transferFrom(owner, _recipient, tokens);
    require(owner.send(_value));

    TokenSold(_recipient, _value, tokens, rate);
  }
  
  function rate() constant public returns (uint) {
    return rateContract.getRate();
  }

  function avalible () constant public returns (bool) {
    return (now > startDate && now < stopDate);
  }

  function isWhiteListed (address _address) constant public returns(bool) {
    return (whitelistPRE.isWhiteListed(_address) || (whitelistICO.isWhiteListed(_address)));
  }

  function() external payable {
    sale(msg.sender, msg.value);
  }
}

// This below no need to validate it private

contract PreSale is Ownable {
  using SafeMath for uint;

  event TokenSold(address _recipient, uint _value, uint _tokens, uint _rate);
  event TokenSold(address _recipient, uint _tokens);

  ZMINE public token;
  WhiteList whitelist;

  uint public hardCap = 300000000 ether;
  uint public remain = 300000000 ether;

  uint public startDate = 1512007200;
  uint public stopDate = 1514599200;

  uint public minTx = 100 ether;
  uint public maxTx = 100000 ether;

  RateContract rateContract;

  function PreSale (ZMINE _token, RateContract _rateContract, WhiteList _whitelist) public {
    token = ZMINE(_token);
    rateContract = RateContract(_rateContract);
    whitelist = WhiteList(_whitelist);
  }

  /**
   * tranfer token to presale investor who pay by fieast
   */
  function tranferFor(address _recipient, uint _amount) public {
    require(now > startDate && now < stopDate);
    require(_amount >= minTx && _amount <= maxTx && _amount <= remain);

    remain = remain.sub(_amount);
    token.transferFrom(owner, _recipient, _amount);

    TokenSold(_recipient, _amount);
  }

  function sale(address _recipient, uint _value) private {
    require(now > startDate && now < stopDate);
    require(whitelist.isWhiteListed(_recipient));
    require(_value >= minTx && _value <= maxTx && _value <= remain);
    uint rate = this.rate();
    uint tokens = rate.mul(_value).div(1 ether);

    remain = remain.sub(tokens);
    token.transferFrom(owner, _recipient, tokens);
    require(owner.send(_value));

    TokenSold(_recipient, _value, tokens, rate);
  }
  
  function rate() constant public returns (uint) {
    return rateContract.getRate();
  }

  function avalible () constant public returns (bool) {
    return (now > startDate && now < stopDate);
  }

  function isWhiteListed (address _address) constant public returns(bool) {
    return whitelist.isWhiteListed(_address);
  }

  function() external payable {
    sale(msg.sender, msg.value);
  }
}

contract FounderThreader is Ownable {
  using SafeMath for uint;

  event TokenTranferForFounder(address _recipient, uint _value, address box1, address box2);

  ZMINE public token;

  uint public hardCap = 300000000 ether;
  uint public remain = 300000000 ether;

  uint public minTx = 100 ether;

  mapping(address => bool) founder;

  function FounderThreader (ZMINE _token, address[] _founders) public {
    token = ZMINE(_token);
    
    for (uint i = 0; i < _founders.length; i++) {
      founder[_founders[i]] = true;
    }
  }

  function tranferFor(address _recipient, uint _value) public onlyOwner {
    require(_value >= minTx && _value <= remain);
    require(founder[_recipient]);

    TreasureBox box1 = new TreasureBox(token, _recipient, 1531015200); // can open 2018-07-08 09+07:00
    TreasureBox box2 = new TreasureBox(token, _recipient, 1546912800); // can open 2019-01-08 09+07:00

    token.setTreasureBox(box1, true);
    token.setTreasureBox(box2, true);

    token.transferFrom(owner, _recipient, _value.mul(33).div(100)); // 33 % for now
    token.transferFrom(owner, box1, _value.mul(33).div(100)); // 33 % for box1
    token.transferFrom(owner, box2, _value.mul(34).div(100)); // 34 % for box2

    remain = remain.sub(_value);

    TokenTranferForFounder(_recipient, _value, box1, box2);
  }
}
