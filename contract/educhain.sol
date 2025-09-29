// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title EduChain
 * @dev A decentralized platform for issuing and verifying educational credentials
 */
contract Project {
    
    // Struct to store credential information
    struct Credential {
        uint256 id;
        string studentName;
        string courseName;
        string institutionName;
        uint256 issueDate;
        address issuer;
        bool isValid;
    }
    
    // Mapping from credential ID to Credential
    mapping(uint256 => Credential) public credentials;
    
    // Mapping from institution address to authorized status
    mapping(address => bool) public authorizedInstitutions;
    
    // Counter for credential IDs
    uint256 public credentialCounter;
    
    // Contract owner
    address public owner;
    
    // Events
    event CredentialIssued(
        uint256 indexed credentialId,
        string studentName,
        string courseName,
        address indexed issuer
    );
    
    event InstitutionAuthorized(address indexed institution);
    event InstitutionRevoked(address indexed institution);
    event CredentialRevoked(uint256 indexed credentialId);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyAuthorized() {
        require(
            authorizedInstitutions[msg.sender],
            "Only authorized institutions can issue credentials"
        );
        _;
    }
    
    constructor() {
        owner = msg.sender;
        credentialCounter = 0;
    }
    
    /**
     * @dev Core Function 1: Issue a new educational credential
     * @param _studentName Name of the student
     * @param _courseName Name of the course
     * @param _institutionName Name of the institution
     */
    function issueCredential(
        string memory _studentName,
        string memory _courseName,
        string memory _institutionName
    ) public onlyAuthorized returns (uint256) {
        credentialCounter++;
        
        credentials[credentialCounter] = Credential({
            id: credentialCounter,
            studentName: _studentName,
            courseName: _courseName,
            institutionName: _institutionName,
            issueDate: block.timestamp,
            issuer: msg.sender,
            isValid: true
        });
        
        emit CredentialIssued(
            credentialCounter,
            _studentName,
            _courseName,
            msg.sender
        );
        
        return credentialCounter;
    }
    
    /**
     * @dev Core Function 2: Verify a credential's authenticity
     * @param _credentialId ID of the credential to verify
     */
    function verifyCredential(uint256 _credentialId)
        public
        view
        returns (
            bool isValid,
            string memory studentName,
            string memory courseName,
            string memory institutionName,
            uint256 issueDate
        )
    {
        require(_credentialId > 0 && _credentialId <= credentialCounter, "Invalid credential ID");
        
        Credential memory cred = credentials[_credentialId];
        
        return (
            cred.isValid,
            cred.studentName,
            cred.courseName,
            cred.institutionName,
            cred.issueDate
        );
    }
    
    /**
     * @dev Core Function 3: Authorize an institution to issue credentials
     * @param _institution Address of the institution
     */
    function authorizeInstitution(address _institution) public onlyOwner {
        require(_institution != address(0), "Invalid institution address");
        require(!authorizedInstitutions[_institution], "Institution already authorized");
        
        authorizedInstitutions[_institution] = true;
        emit InstitutionAuthorized(_institution);
    }
    
    /**
     * @dev Revoke an institution's authorization
     * @param _institution Address of the institution
     */
    function revokeInstitutionAuthorization(address _institution) public onlyOwner {
        require(authorizedInstitutions[_institution], "Institution not authorized");
        
        authorizedInstitutions[_institution] = false;
        emit InstitutionRevoked(_institution);
    }
    
    /**
     * @dev Revoke a specific credential
     * @param _credentialId ID of the credential to revoke
     */
    function revokeCredential(uint256 _credentialId) public onlyAuthorized {
        require(_credentialId > 0 && _credentialId <= credentialCounter, "Invalid credential ID");
        require(
            credentials[_credentialId].issuer == msg.sender,
            "Only the issuing institution can revoke this credential"
        );
        require(credentials[_credentialId].isValid, "Credential already revoked");
        
        credentials[_credentialId].isValid = false;
        emit CredentialRevoked(_credentialId);
    }
    
    /**
     * @dev Get total number of credentials issued
     */
    function getTotalCredentials() public view returns (uint256) {
        return credentialCounter;
    }
    
    /**
     * @dev Check if an institution is authorized
     * @param _institution Address of the institution
     */
    function isInstitutionAuthorized(address _institution) public view returns (bool) {
        return authorizedInstitutions[_institution];
    }
}
