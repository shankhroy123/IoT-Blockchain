// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SolarGridSupplyChain {

    struct DataRecord {
        uint timestamp;
        string componentID;
        string status; // e.g., "Delivered", "In Operation", "Maintenance Required"
        uint energyOutput; // Example data from the solar grid
        address recorder; // Address of the entity that recorded the data
        string recordID; // Unique identifier for record integrity
        bool flaggedAnomaly; // Flag to indicate suspicious activity
    }

    DataRecord[] public records;

    // Define roles with separate permissions
    address public admin;
    mapping(address => bool) public maintenanceRoles;
    mapping(address => bool) public monitoringRoles;

    // Events
    event NewRecordAdded(uint timestamp, string componentID, string status, uint energyOutput, address recorder, string recordID, bool flaggedAnomaly);
    event AnomalyDetected(uint timestamp, string componentID, uint energyOutput, string message);

    constructor() {
        admin = msg.sender;
    }

    // Modifier to restrict actions to the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action.");
        _;
    }

    // Modifier to restrict actions to maintenance role
    modifier onlyMaintenance() {
        require(maintenanceRoles[msg.sender], "Only maintenance can perform this action.");
        _;
    }

    // Modifier to restrict actions to monitoring role
    modifier onlyMonitoring() {
        require(monitoringRoles[msg.sender], "Only monitoring can perform this action.");
        _;
    }

    // Admin assigns maintenance or monitoring roles
    function assignRole(address _user, bool isMaintenance) public onlyAdmin {
        if (isMaintenance) {
            maintenanceRoles[_user] = true;
        } else {
            monitoringRoles[_user] = true;
        }
    }

    // Add a record with an anomaly check
    function addRecord(
        string memory _componentID, 
        string memory _status, 
        uint _energyOutput, 
        string memory _recordID
    ) public onlyMaintenance {
        bool anomaly = false;
        if (_energyOutput > 10000) { // Example threshold for anomaly detection
            anomaly = true;
            emit AnomalyDetected(block.timestamp, _componentID, _energyOutput, "Anomalous energy output detected");
        }
        
        DataRecord memory newRecord = DataRecord({
            timestamp: block.timestamp,
            componentID: _componentID,
            status: _status,
            energyOutput: _energyOutput,
            recorder: msg.sender,
            recordID: _recordID,
            flaggedAnomaly: anomaly
        });

        records.push(newRecord);
        emit NewRecordAdded(block.timestamp, _componentID, _status, _energyOutput, msg.sender, _recordID, anomaly);
    }

    // Retrieve a specific record
    function getRecord(uint _index) public view onlyMonitoring returns (uint, string memory, string memory, uint, address, string memory, bool) {
        require(_index < records.length, "Record does not exist");
        DataRecord memory record = records[_index];
        return (record.timestamp, record.componentID, record.status, record.energyOutput, record.recorder, record.recordID, record.flaggedAnomaly);
    }

    // Total records count
    function getTotalRecords() public view returns (uint) {
        return records.length;
    }
}
