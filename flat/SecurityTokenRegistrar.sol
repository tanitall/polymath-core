pragma solidity ^0.4.18;

interface ISTRegistrar {

   /** 
    * @dev Creates a new Security Token and saves it to the registry
    * @param _name Name of the security token
    * @param _ticker Ticker name of the security
    * @param _totalSupply Total amount of tokens being created
    * @param _owner Ethereum public key address of the security token owner
    * @param _host The host of the security token wizard
    * @param _fee Fee being requested by the wizard host
    * @param _type Type of security being tokenized
    * @param _maxPoly Amount of POLY being raised
    * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
    * @param _quorum Percent of initial investors required to freeze POLY raise 
    */
    function createSecurityToken (
        string _name,
        string _ticker,
        uint256 _totalSupply,
        address _owner,
        address _host,
        uint256 _fee,
        uint8 _type,
        uint256 _maxPoly,
        uint256 _lockupPeriod,
        uint8 _quorum
    ) external;
}

/// @title Math operations with safety checks
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

/// ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
interface IERC20 {
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/*
 POLY token faucet is only used on testnet for testing purposes
 !!!! NOT INTENDED TO BE USED ON MAINNET !!!
*/




contract PolyToken is IERC20 {

    using SafeMath for uint256;
    uint256 public totalSupply = 1000000;
    string public name = "Polymath Network";
    uint8 public decimals = 18;
    string public symbol = "POLY";

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /* Token faucet - Not part of the ERC20 standard */
    function getTokens(uint256 _amount, address _recipient) public returns (bool) {
        balances[_recipient] += _amount;
        totalSupply += _amount;
        return true;
    }

    /**
     * @dev send `_value` token to `_to` from `msg.sender`
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not 
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /** 
     * @dev send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not 
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
     * @dev `balanceOf` function to get the balance of token holders
     * @param _owner The address from which the balance will be retrieved
     * @return The balance 
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /** 
     * @dev `msg.sender` approves `_spender` to spend `_value` tokens
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not 
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /** 
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent 
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

interface ICustomers {

  /** 
   * @dev Allow new provider applications
   * @param _providerAddress The provider's public key address
   * @param _name The provider's name
   * @param _details A SHA256 hash of the new providers details
   * @param _fee The fee charged for customer verification 
   */
  function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success);

  /**
   * @dev Change a providers fee
   * @param _newFee The new fee of the provider 
   */
  function changeFee(uint256 _newFee) public returns (bool success);

  /** 
   * @dev Verify an investor
   * @param _customer The customer's public key address
   * @param _jurisdiction The jurisdiction code of the customer
   * @param _role The type of customer - investor:1, delegate:2, issuer:3, marketmaker:4, etc.
   * @param _accredited Whether the customer is accredited or not (only applied to investors)
   * @param _expires The time the verification expires 
   */
  function verifyCustomer(
    address _customer,
    bytes32 _jurisdiction,
    uint8 _role,
    bool _accredited,
    uint256 _expires
  ) public returns (bool success);

   ///////////////////
    /// GET Functions
    //////////////////

  /**
    * @dev Get customer attestation data by KYC provider and customer ethereum address
    * @param _provider Address of the KYC provider.
    * @param _customer Address of the customer ethereum address
    */
  function getCustomer(address _provider, address _customer) public constant returns (
    bytes32,
    bool,
    uint8,
    bool,
    uint256
  );

  /**
   * Get provider details and fee by ethereum address
   * @param _providerAddress Address of the KYC provider
   */
  function getProvider(address _providerAddress) public constant returns (
    string name,
    uint256 joined,
    bytes32 details,
    uint256 fee
  );
}

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/

interface ICompliance {

    /**
     * @dev `createTemplate` is a simple function to create a new compliance template
     * @param _offeringType The name of the security being issued
     * @param _issuerJurisdiction The jurisdiction id of the issuer
     * @param _accredited Accreditation status required for investors
     * @param _KYC KYC provider used by the template
     * @param _details Details of the offering requirements
     * @param _expires Timestamp of when the template will expire
     * @param _fee Amount of POLY to use the template (held in escrow until issuance)
     * @param _quorum Minimum percent of shareholders which need to vote to freeze
     * @param _vestingPeriod Length of time to vest funds 
     */
    function createTemplate(
        string _offeringType,
        bytes32 _issuerJurisdiction,
        bool _accredited,
        address _KYC,
        bytes32 _details,
        uint256 _expires,
        uint256 _fee,
        uint8 _quorum,
        uint256 _vestingPeriod
    ) public;

   /**
     * @dev Propose a bid for a security token issuance
     * @param _securityToken The security token being bid on
     * @param _template The unique template address
     * @return bool success 
     */
    function proposeTemplate(
        address _securityToken,
        address _template
    ) public returns (bool success);

    /**
     * @dev Propose a Security Token Offering Contract for an issuance
     * @param _securityToken The security token being bid on
     * @param _stoContract The security token offering contract address
     * @return bool success 
     */
    function proposeOfferingContract(
        address _securityToken,
        address _stoContract
    ) public returns (bool success);

    /**
     * @dev Cancel a Template proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _templateProposalIndex The template proposal array index
     * @return bool success 
     */
    function cancelTemplateProposal(
        address _securityToken,
        uint256 _templateProposalIndex
    ) public returns (bool success);

    /**
     * @dev Set the STO contract by the issuer.
     * @param _STOAddress address of the STO contract deployed over the network.
     * @param _fee fee to be paid in poly to use that contract
     * @param _vestingPeriod no. of days investor binded to hold the Security token
     * @param _quorum Minimum percent of shareholders which need to vote to freeze
     */
    function setSTO (
        address _STOAddress,
        uint256 _fee,
        uint256 _vestingPeriod,
        uint8 _quorum
    ) public returns (bool success);

    /**
     * @dev Cancel a STO contract proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _offeringProposalIndex The offering proposal array index
     * @return bool success 
     */
    function cancelOfferingProposal(
        address _securityToken,
        uint256 _offeringProposalIndex
    ) public returns (bool success);

    /**
     * @dev `updateTemplateReputation` is a constant function that updates the
       history of a security token template usage to keep track of previous uses
     * @param _template The unique template id
     * @param _templateIndex The array index of the template proposal 
     */
    function updateTemplateReputation (address _template, uint8 _templateIndex) external returns (bool success);

    /**
     * @dev `updateOfferingReputation` is a constant function that updates the
       history of a security token offering contract to keep track of previous uses
     * @param _stoContract The smart contract address of the STO contract
     * @param _offeringProposalIndex The array index of the security token offering proposal 
     */
    function updateOfferingReputation (address _stoContract, uint8 _offeringProposalIndex) external returns (bool success);

    /**
     * @dev Get template details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _templateIndex The array index of the template being checked
     * @return Template struct 
     */
    function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) view public returns (
        address template
    );

    /** 
     * @dev Get security token offering smart contract details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _offeringProposalIndex The array index of the STO contract being checked
     * @return Contract struct 
     */
    function getOfferingByProposal(address _securityTokenAddress, uint8 _offeringProposalIndex) view public returns (
        address stoContract,
        address auditor,
        uint256 vestingPeriod,
        uint8 quorum,
        uint256 fee
    );
}

interface ITemplate {

  /** 
   * @dev `addJurisdiction` allows the adding of new jurisdictions to a template
   * @param _allowedJurisdictions An array of jurisdictions
   * @param _allowed An array of whether the jurisdiction is allowed to purchase the security or not 
   */
  function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public;

  /**
   * @dev `addRole` allows the adding of new roles to be added to whitelist
   * @param _allowedRoles User roles that can purchase the security 
   */
  function addRoles(uint8[] _allowedRoles) public;

  /** 
   * @notice `updateDetails`
   * @param _details details of the template need to change
   * @return allowed boolean variable
   */
  function updateDetails(bytes32 _details) public returns (bool allowed);

  /** 
   * @dev `finalizeTemplate` is used to finalize template.full compliance process/requirements 
   * @return success
   */
  function finalizeTemplate() public returns (bool success);

  /**
   * @dev `checkTemplateRequirements` is a constant function that checks if templates requirements are met
   * @param _jurisdiction The ISO-3166 code of the investors jurisdiction
   * @param _accredited Whether the investor is accredited or not
   * @param _role role of the user
   * @return allowed boolean variable
   */
  function checkTemplateRequirements(
      bytes32 _jurisdiction,
      bool _accredited,
      uint8 _role
  ) public constant returns (bool allowed);

  /**
   * @dev getTemplateDetails is a constant function that gets template details
   * @return bytes32 details, bool finalized 
   */
  function getTemplateDetails() view public returns (bytes32, bool);

  /**
   * @dev `getUsageFees` is a function to get all the details on template usage fees
   * @return uint256 fee, uint8 quorum, uint256 vestingPeriod, address owner, address KYC
   */
  function getUsageDetails() view public returns (uint256, uint8, uint256, address, address);
}

interface ISTO {

    /** 
     * @dev Initializes the STO with certain params
     * @param _tokenAddress The Security Token address
     * @param _startTime Given in UNIX time this is the time that the offering will begin
     * @param _endTime Given in UNIX time this is the time that the offering will end 
     */
    function securityTokenOffering(
        address _tokenAddress,
        uint256 _startTime,
        uint256 _endTime
    ) external;

}

/**
 * @title SecurityToken 
 * @dev Contract (A Blueprint) that contains the functionalities of the security token
 */

contract SecurityToken is IERC20 {

    using SafeMath for uint256;

    uint256 public version = 1;

    IERC20 public POLY;                                               // Instance of the POLY token contract

    ICompliance public PolyCompliance;                                // Instance of the Compliance contract

    ITemplate public Template;                                        // Instance of the Template contract

    ICustomers public PolyCustomers;                                  // Instance of the Customers contract

    // ERC20 Fields
    string public name;                                               // Name of the security token
    uint8 public decimals;                                            // Decimals for the security token it should be 0 as standard   
    string public symbol;                                             // Symbol of the security token 
    address public owner;                                             // Address of the owner of the security token   
    uint256 public totalSupply;                                       // Total number of security token generated 
    mapping(address => mapping(address => uint256)) allowed;          // Mapping as same as in ERC20 token
    mapping(address => uint256) balances;                             // Array used to store the balances of the security token holders

    // Template
    address public delegate;                                          // Address who create the template
    bytes32 public complianceProof;                                   //   
    address public KYC;                                               // Address of the KYC provider which aloowed the roles and jurisdictions in the template        

    // Security token shareholders
    struct Shareholder {                                              // Structure that contains the data of the shareholders 
        address verifier;                                             // verifier - address of the KYC oracle
        bool allowed;                                                 // allowed - whether the shareholder is allowed to transfer or recieve the security token
        uint8 role;                                                   // role - role of the shareholder {1,2,3,4}   
    }
    mapping(address => Shareholder) public shareholders;              // Mapping that holds the data of the shareholder corresponding to investor address

    // STO address
    address public STO;                                               // Address of the security token offering contract
    uint256 public maxPoly;                                           // Maximum amount of POLY will be invested in offering contract

    // The start and end time of the STO
    uint256 public startSTO;                                          // Timestamp when Security Token Offering will be start 
    uint256 public endSTO;                                            // Timestamp when Security Token Offering contract will ends

    // POLY allocations
    struct Allocation {                                               // Structure that contains the allocation of the POLY for stakeholders 
        uint256 amount;                                               // stakeholders - delegate, issuer(owner), auditor    
        uint256 vestingPeriod;
        uint8 quorum;
        uint256 yayVotes;
        uint256 yayPercent;
        bool frozen;
    }
    mapping(address => mapping(address => bool)) voted;               // Voting mapping
    mapping(address => Allocation) allocations;                       // Mapping that contains the data of allocation corresponding to stakeholder address
                                                                        

	// Security Token Offering statistics
    mapping(address => uint256) contributedToSTO;
	uint256 public tokensIssuedBySTO = 0;                             // Flag variable to track the security token issued by the offering contract

    // Notifications
    event LogTemplateSet(address indexed _delegateAddress, address _template, address indexed _KYC);
    event LogUpdatedComplianceProof(bytes32 merkleRoot, bytes32 _complianceProofHash);
    event LogSetSTOContract(address _STO, address indexed _STOtemplate, address indexed _auditor, uint256 _startTime, uint256 _endTime);
    event LogNewWhitelistedAddress(address _KYC, address _shareholder, uint8 _role);
    event LogVoteToFreeze(address _recipient, uint256 _yayPercent, uint8 _quorum, bool _frozen);
    event LogTokenIssued(address indexed _contributor, uint256 _stAmount, uint256 _polyContributed, uint256 _timestamp);

    //Modifiers
    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }

    modifier onlyDelegate() {
        require (msg.sender == delegate);
        _;
    }

    modifier onlyOwnerOrDelegate() {
        require (msg.sender == delegate || msg.sender == owner);
        _;
    }

    modifier onlySTO() {
        require (msg.sender == address(STO));
        _;
    }

    modifier onlyShareholder() {
        require (shareholders[msg.sender].allowed);
        _;
    }

    /** 
     * @dev Set default security token parameters
     * @param _name Name of the security token
     * @param _ticker Ticker name of the security
     * @param _totalSupply Total amount of tokens being created
     * @param _owner Ethereum address of the security token owner
     * @param _maxPoly Amount of POLY being raised
     * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
     * @param _quorum Percent of initial investors required to freeze POLY raise
     * @param _polyTokenAddress Ethereum address of the POLY token contract
     * @param _polyCustomersAddress Ethereum address of the PolyCustomers contract
     * @param _polyComplianceAddress Ethereum address of the PolyCompliance contract 
     */
    function SecurityToken(
        string _name,
        string _ticker,
        uint256 _totalSupply,
        address _owner,
        uint256 _maxPoly,
        uint256 _lockupPeriod,
        uint8 _quorum,
        address _polyTokenAddress,
        address _polyCustomersAddress,
        address _polyComplianceAddress
    ) public
    {
        decimals = 0;
        name = _name;
        symbol = _ticker;
        owner = _owner;
        maxPoly = _maxPoly;
        totalSupply = _totalSupply;
        balances[_owner] = _totalSupply;
        POLY = IERC20(_polyTokenAddress);
        PolyCustomers = ICustomers(_polyCustomersAddress);
        PolyCompliance = ICompliance(_polyComplianceAddress);
        allocations[owner] = Allocation(0, _lockupPeriod, _quorum, 0, 0, false);
    }

    /**
     * @dev `selectTemplate` Select a proposed template for the issuance
     * @param _templateIndex Array index of the delegates proposed template
     * @return bool success 
     */
    function selectTemplate(uint8 _templateIndex) public onlyOwner returns (bool success) {
        address _template = PolyCompliance.getTemplateByProposal(this, _templateIndex);
        require(_template != address(0));
        Template = ITemplate(_template);
        var (_fee, _quorum, _vestingPeriod, _delegate, _KYC) = Template.getUsageDetails();
        require(POLY.balanceOf(this) >= _fee);
        allocations[_delegate] = Allocation(_fee, _vestingPeriod, _quorum, 0, 0, false);
        delegate = _delegate;
        KYC = _KYC;
        PolyCompliance.updateTemplateReputation(_template, _templateIndex);
        LogTemplateSet(_delegate, _template, _KYC);
        return true;
    }

    /**
     * @dev Update compliance proof hash for the issuance
     * @param _newMerkleRoot New merkle root hash of the compliance Proofs
     * @param _complianceProof Compliance Proof hash
     * @return bool success 
     */
    function updateComplianceProof(
        bytes32 _newMerkleRoot,
        bytes32 _complianceProof
    ) public onlyOwnerOrDelegate returns (bool success)
    {
        complianceProof = _newMerkleRoot;
        LogUpdatedComplianceProof(_newMerkleRoot, _complianceProof);
        return true;
    }

    /** 
     * @dev `selectOfferingProposal` Select an security token offering proposal for the issuance
     * @param _offeringProposalIndex Array index of the STO proposal
     * @param _startTime Start of issuance period
     * @param _endTime End of issuance period
     * @return bool success 
     */
    function selectOfferingProposal (
        uint8 _offeringProposalIndex,
        uint256 _startTime,
        uint256 _endTime
    ) public onlyDelegate returns (bool success)
    {
        var (_stoContract, _auditor, _vestingPeriod, _quorum, _fee) = PolyCompliance.getOfferingByProposal(this, _offeringProposalIndex);
        require(_stoContract != address(0));
        require(complianceProof != 0x0);
        require(delegate != address(0));
        require(_startTime > now && _endTime > _startTime);
        require(POLY.balanceOf(this) >= allocations[delegate].amount + _fee);
        allocations[_auditor] = Allocation(_fee, _vestingPeriod, _quorum, 0, 0, false);
        STO = ISTO(_stoContract);
        shareholders[address(STO)] = Shareholder(this, true, 5);
        startSTO = _startTime;
        endSTO = _endTime;
        PolyCompliance.updateOfferingReputation(_stoContract, _offeringProposalIndex);
        LogSetSTOContract(STO, _stoContract, _auditor, _startTime, _endTime);
        return true;
    }

    /**
     * @dev Add a verified address to the Security Token whitelist
     * @param _whitelistAddress Address attempting to join ST whitelist
     * @return bool success
     */
    function addToWhitelist(address _whitelistAddress) public returns (bool success) {
        require(KYC == msg.sender || owner == msg.sender);
        var (jurisdiction, accredited, role, verified, expires) = PolyCustomers.getCustomer(KYC, _whitelistAddress);
        require(verified && expires > now);
        require(Template.checkTemplateRequirements(jurisdiction, accredited, role));
        shareholders[_whitelistAddress] = Shareholder(msg.sender, true, role);
        LogNewWhitelistedAddress(msg.sender, _whitelistAddress, role);
        return true;
    }

    /**
     * @dev Allow POLY allocations to be withdrawn by owner, delegate, and the STO auditor at appropriate times
     * @return bool success 
     */
    function withdrawPoly() public returns (bool success) {
  	   if (delegate == address(0)) {
          return POLY.transfer(owner, POLY.balanceOf(this));
        } 
        require(now > endSTO + allocations[msg.sender].vestingPeriod);
        require(allocations[msg.sender].frozen == false);
        require(allocations[msg.sender].amount > 0);
        require(POLY.transfer(msg.sender, allocations[msg.sender].amount));
        allocations[msg.sender].amount = 0;
        return true;
    }

    /**
     * @dev Vote to freeze the fee of a certain network participant
     * @param _recipient The fee recipient being protested
     * @return bool success
     */
    function voteToFreeze(address _recipient) public onlyShareholder returns (bool success) {
        require(delegate != address(0));
        require(now > endSTO);
        require(now < endSTO + allocations[_recipient].vestingPeriod);
        require(voted[msg.sender][_recipient] == false);
        voted[msg.sender][_recipient] == true;
        allocations[_recipient].yayVotes = allocations[_recipient].yayVotes + contributedToSTO[msg.sender];
        allocations[_recipient].yayPercent = allocations[_recipient].yayVotes.mul(100).div(tokensIssuedBySTO);
        if (allocations[_recipient].yayPercent >= allocations[_recipient].quorum) {
          allocations[_recipient].frozen = true;
        }
        LogVoteToFreeze(_recipient, allocations[_recipient].yayPercent, allocations[_recipient].quorum, allocations[_recipient].frozen);
        return true;
    }

	/**
     * @dev `issueSecurityTokens` is used by the STO to keep track of STO investors
     * @param _contributor The address of the person whose contributing
     * @param _amountOfSecurityTokens The amount of ST to pay out.
     * @param _polyContributed The amount of POLY paid for the security tokens. 
     */
    function issueSecurityTokens(address _contributor, uint256 _amountOfSecurityTokens, uint256 _polyContributed) public onlySTO returns (bool success) {
        require(shareholders[_contributor].allowed);
        require(now >= startSTO && now <= endSTO);
        require(POLY.transferFrom(_contributor, this, _polyContributed));
        require(tokensIssuedBySTO.add(_amountOfSecurityTokens) <= totalSupply);
        require(maxPoly >= allocations[owner].amount.add(_polyContributed));
        balances[owner] = balances[owner].sub(_amountOfSecurityTokens);
        balances[_contributor] = balances[_contributor].add(_amountOfSecurityTokens);
        tokensIssuedBySTO = tokensIssuedBySTO.add(_amountOfSecurityTokens);
        contributedToSTO[_contributor] = contributedToSTO[_contributor].add(_amountOfSecurityTokens);
        allocations[owner].amount = allocations[owner].amount.add(_polyContributed);
        LogTokenIssued(_contributor, _amountOfSecurityTokens, _polyContributed, now);
        return true;
    }

    // Get token details
    function getTokenDetails() view public returns (address, address, bytes32, address, address) {
        return (Template, delegate, complianceProof, STO, KYC);
    }

/////////////////////////////////////////////// Customized ERC20 Functions //////////////////////////////////////////////////////////// 

    /**
     * @dev Trasfer tokens from one address to another
     * @param _to Ethereum public address to transfer tokens to
     * @param _value Amount of tokens to send
     * @return bool success 
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (shareholders[_to].allowed && balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /** 
     * @dev Allows contracts to transfer tokens on behalf of token holders
     * @param _from Address to transfer tokens from
     * @param _to Address to send tokens to
     * @param _value Number of tokens to transfer
     * @return bool success 
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (shareholders[_to].allowed && shareholders[msg.sender].allowed && balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            uint256 _allowance = allowed[_from][msg.sender];
            balances[_from] = balances[_from].sub(_value);
            allowed[_from][msg.sender] = _allowance.sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev `balanceOf` used to get the balance of shareholders
     * @param _owner The address from which the balance will be retrieved
     * @return The balance 
     */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    /** 
     * @dev Approve transfer of tokens manually
     * @param _spender Address to approve transfer to
     * @param _value Amount of tokens to approve for transfer
     * @return bool success 
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (shareholders[_spender].allowed) {
            require(_value != 0);
            allowed[msg.sender][_spender] = _value;
            Approval(msg.sender, _spender, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Use to get the allowance provided to the spender
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent 
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

/*
  The Polymath Security Token Registrar provides a way to lookup security token details
  from a single place and allows wizard creators to earn POLY fees by uploading to the
  registrar.
*/





/**
 * @title SecurityTokenRegistrar
 * @dev Contract use to register the security token on Polymath platform
 */

contract SecurityTokenRegistrar is ISTRegistrar {

    address public polyTokenAddress;                                // Address of POLY token 
    address public polyCustomersAddress;                            // Address of the polymath-core Customers contract address
    address public polyComplianceAddress;                           // Address of the polymath-core Compliance contract address

    // Security Token
    struct SecurityTokenData {                                      // A structure that contains the specific info of each ST
      uint256 totalSupply;                                          // created ever using the Polymath platform
      address owner;
      string ticker;
      uint8 securityType;
    }
    mapping(address => SecurityTokenData) securityTokens;           // Array contains the details of security token corresponds to security token address
    mapping(string => address) tickers;                             // Mapping of ticker name to Security Token

    event LogNewSecurityToken(string ticker, address securityTokenAddress, address owner, address host, uint256 fee, uint8 _type);

    /**
     * @dev Constructor use to set the essentials addresses to facilitate
     * the creation of the security token
     */
    function SecurityTokenRegistrar(
      address _polyTokenAddress,
      address _polyCustomersAddress,
      address _polyComplianceAddress
    ) public
    {
      polyTokenAddress = _polyTokenAddress;
      polyCustomersAddress = _polyCustomersAddress;
      polyComplianceAddress = _polyComplianceAddress;
    }

    /** 
     * @dev Creates a new Security Token and saves it to the registry
     * @param _name Name of the security token
     * @param _ticker Ticker name of the security
     * @param _totalSupply Total amount of tokens being created
     * @param _owner Ethereum public key address of the security token owner
     * @param _host The host of the security token wizard
     * @param _fee Fee being requested by the wizard host
     * @param _type Type of security being tokenized
     * @param _maxPoly Amount of POLY being raised
     * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
     * @param _quorum Percent of initial investors required to freeze POLY raise 
     */
    function createSecurityToken (
      string _name,
      string _ticker,
      uint256 _totalSupply,
      address _owner,
      address _host,
      uint256 _fee,
      uint8 _type,
      uint256 _maxPoly,
      uint256 _lockupPeriod,
      uint8 _quorum
    ) external
    {
      require(_totalSupply > 0 && _maxPoly > 0 && _fee > 0);
      require(tickers[_ticker] == 0x0);
      require(_lockupPeriod >= now);
      require(_owner != address(0) && _host != address(0));
      require(bytes(_name).length > 0 && bytes(_ticker).length > 0);
      PolyToken POLY = PolyToken(polyTokenAddress);
      POLY.transferFrom(msg.sender, _host, _fee);
      address newSecurityTokenAddress = new SecurityToken(
        _name,
        _ticker,
        _totalSupply,
        _owner,
        _maxPoly,
        _lockupPeriod,
        _quorum,
        polyTokenAddress,
        polyCustomersAddress,
        polyComplianceAddress
      );
      tickers[_ticker] = newSecurityTokenAddress;
      securityTokens[newSecurityTokenAddress] = SecurityTokenData(
        _totalSupply,
        _owner,
        _ticker,
        _type
      );
      LogNewSecurityToken(_ticker, newSecurityTokenAddress, _owner, _host, _fee, _type);
    }

    /**
     * @dev Get security token address by ticker name
     * @param _ticker Symbol of the Scurity token
     * @return address _ticker
     */
    function getSecurityTokenAddress(string _ticker) public constant returns (address) {
      return tickers[_ticker];
    }

    /**
     * @dev Get Security token details by its ethereum address
     * @param _STAddress Security token address
     */
    function getSecurityTokenData(address _STAddress) public constant returns (
      uint256 totalSupply,
      address owner,
      string ticker,
      uint8 securityType
    ) {
      return (
        securityTokens[_STAddress].totalSupply,
        securityTokens[_STAddress].owner,
        securityTokens[_STAddress].ticker,
        securityTokens[_STAddress].securityType
      );
    }

}