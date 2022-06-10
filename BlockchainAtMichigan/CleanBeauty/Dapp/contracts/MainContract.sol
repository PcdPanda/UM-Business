// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 < 0.9.0;
import "./SafeMath.sol";

contract MainContract{
    // Variables for the token
    using SafeMath for uint256;
    string public constant tokenName = "CleanBeautyToken";
    string public constant symbol = "CBT";
    uint8 public constant decimals = 18;
    uint256 _totalSupply = 100;
    mapping(address => uint256) _balances;
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Variables for the medicines
    uint256 public _medicineId;
    mapping (uint256 => address) _producers; // Store the medicine producer
    mapping (uint256 => string) _medicines; // Store the medicine name
    mapping (uint256 => uint256) _medicineUsage; // Store if the medicine have been used
    event Production(address indexed producer, uint256 indexed medicineId, string indexed name);

    // Variables for the surgeries
    enum State {PENDING, PROPOSED, SCHEDULED, CONFIRMED, EXECUTED, REVIEWED, CLOSED}
    uint256 public _surgeryId; // A ascending number showing how many surgeries have been performed
    

    event SurgeryUpdate(uint256 indexed surgeryId, address patient, address surgeon, State updatedState);
    event AccessUpdate(uint256 indexed surgeryId, address receiver);

    struct Surgery{
        State surgeryState; // States of the surgery
        address surgeon;
        address patient;
        uint256 payment; // how much the surgery cost
        uint256 medicineId;
        string information; // Other information for the surgery
        string review; // Patient Review for the surgery
    }
    
    mapping (uint256 => Surgery) _surgeries; // all past and valid surgeries
    mapping (address => mapping(uint256 => bool)) _surgeryAccess; // Keep all accessible surgeries for one user 

    // Methods for the tokens
    constructor() { 
        _balances[msg.sender] = _totalSupply;
        _surgeryId = 1;
        _medicineId = 1;
    }

    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address owner_) public view returns (uint256) {
        return _balances[owner_];
    }

    function transfer(address receiver, uint256 numTokens) public returns (bool) {
        require(numTokens <= _balances[msg.sender]);
        _balances[msg.sender] = _balances[msg.sender].sub(numTokens);
        _balances[receiver] = _balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    } 

    // Method for producers
    function importMedicine(string memory name) public returns (uint256){
        _producers[_medicineId] = msg.sender;
        _medicines[_medicineId] = name;
        emit Production(msg.sender, _medicineId++, name);
        return _medicineId - 1;
    }

    // Method for check medicine info
    function viewMedicine(uint256 medicineId) public view returns (address, string memory, uint256){
        require(medicineId<_medicineId);
        return (_producers[medicineId], _medicines[medicineId], _medicineUsage[medicineId]);
    }

    // Method for access
    function grantAccess(uint256 surgeryId, address receiver) public { // The patient can grant access to other receiver, so that the doctor can view the details of previous surgeries. But he's only authorized after the surgery is closed
        Surgery storage surgery = _surgeries[surgeryId];
        require(msg.sender==surgery.patient&&surgery.surgeryState==State.CLOSED);
        _surgeryAccess[receiver][surgeryId] = true;
        emit AccessUpdate(surgeryId, receiver);
    }

    function propose(address surgeon, uint payment) public returns (uint256){ // Patient can propose a surgery with a doctor
        require(_balances[msg.sender]>=payment);
        Surgery memory surgery = Surgery(State.PROPOSED, surgeon, msg.sender, payment, 0, "", ""); // The patient can propose an offer about a surgery
        _surgeries[_surgeryId] = surgery;
        _surgeryAccess[msg.sender][_surgeryId]=true;
        _surgeryAccess[surgeon][_surgeryId]=true;
        emit SurgeryUpdate(_surgeryId++, msg.sender, surgeon, State.PROPOSED); // The app should receive a event about a proposed has been set up
        return _surgeryId - 1;
    }

    function schedule(uint256 surgeryId, uint payment, uint256 medicineId, string memory information) public{ // The surgeon can keep updating the surgey plan and change the information/charge about the surgery
        Surgery storage surgery = _surgeries[surgeryId];
        require(msg.sender==surgery.surgeon&&(surgery.surgeryState==State.PROPOSED||surgery.surgeryState==State.SCHEDULED)&&medicineId<_medicineId&&_medicineUsage[medicineId]==0);
        surgery.medicineId = medicineId;
        surgery.information = information;
        surgery.payment = payment;
        surgery.surgeryState = State.SCHEDULED;
        emit SurgeryUpdate(_surgeryId, surgery.patient, msg.sender, State.SCHEDULED);
    }

    function deposit(uint256 surgeryId) public{ // When the surgery is scheduled by the doctor, the user confirm it by depositing the tokens
        Surgery storage surgery = _surgeries[surgeryId];
        // If the patient is happy with doctor's idea and payment, he can proceed the surgery by depositing the payment
        require(_balances[msg.sender]>=surgery.payment&&msg.sender==surgery.patient&&surgery.surgeryState==State.SCHEDULED); 
        _balances[msg.sender] -= surgery.payment;
        surgery.surgeryState = State.CONFIRMED;
        emit SurgeryUpdate(_surgeryId, msg.sender, surgery.surgeon, State.CONFIRMED);
    }

    function execution(uint256 surgeryId, string memory information)public {
        Surgery storage surgery = _surgeries[surgeryId];
        // After the confirmation, the doctor execute the surgery and upload related information to the blockchain
        require(msg.sender==surgery.surgeon&&surgery.surgeryState==State.CONFIRMED);
        surgery.information = information;
        surgery.surgeryState = State.EXECUTED;
        _medicineUsage[surgery.medicineId] = surgeryId;
        emit SurgeryUpdate(_surgeryId, surgery.patient, msg.sender, State.EXECUTED);
    }

    function writeReview(uint surgeryId, string memory review)public{
        Surgery storage surgery = _surgeries[surgeryId];
        // After the execution, the patient can keep updating until the surgery is REVIEWED
        require(msg.sender==surgery.patient&&(surgery.surgeryState==State.EXECUTED||surgery.surgeryState==State.REVIEWED));
        surgery.review = review;
        surgery.surgeryState = State.REVIEWED;
        emit SurgeryUpdate(_surgeryId, msg.sender, surgery.surgeon, State.REVIEWED);
    }

    function complete(uint surgeryId)public{
        Surgery storage surgery = _surgeries[surgeryId];
        // Once the doctor thinks the surgery is fair enough, he can close it (meaning it's valid) and take the deposit
        require(msg.sender==surgery.surgeon&&surgery.surgeryState==State.REVIEWED);
        surgery.surgeryState = State.CLOSED;
        _balances[msg.sender] += surgery.payment;
        emit SurgeryUpdate(_surgeryId, surgery.patient, msg.sender, State.CLOSED);
    }

    // Method to review the previous surgeries
    function viewSurgeryDetail(uint256 surgeryId)view public returns(Surgery memory){ // View the detailed information for one surgery
        require(_surgeryAccess[msg.sender][surgeryId]==true);
        return _surgeries[surgeryId];
    }

    function viewSurgery(uint256 surgeryId)view public returns (uint256, uint256, string memory, string memory){ // View the public information for surgery
        Surgery memory surgery = _surgeries[surgeryId];
        require(surgery.surgeryState==State.CLOSED);
        return (surgery.payment, surgery.medicineId, surgery.information, surgery.review);
    }

    function viewSurgeon(address surgeon)view public returns (uint256[] memory){ // View all the previous surgery with one surgeon
        
        uint i = 0;
        for(uint256 surgeryId=0;surgeryId<=_surgeryId;surgeryId++){
            Surgery memory surgery =  _surgeries[surgeryId];
            if(surgery.surgeon==surgeon&&surgery.surgeryState==State.CLOSED)i++;
        }
        uint256[] memory surgeries = new uint256[](i);
        i = 0;
        for(uint256 surgeryId=1;surgeryId<=_surgeryId;surgeryId++){
            Surgery memory surgery =  _surgeries[surgeryId];
            if(surgery.surgeon==surgeon&&surgery.surgeryState==State.CLOSED)surgeries[i++] = surgeryId;
        }
        return surgeries;
    }
}
