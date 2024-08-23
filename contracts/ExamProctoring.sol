// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ExamProctoring {

    // Struct to store exam details
    struct Exam {
        string subject;
        uint256 startTime;
        uint256 duration; // in seconds
        address instructor;
        bool isActive;
        string examHash; // Hash of the exam content
    }

    // Struct to store student exam records
    struct StudentExam {
        bool hasStarted;
        bool hasSubmitted;
        string submissionHash; // Hash of the submitted exam content
    }

    // Mapping to store exams by their ID
    mapping(uint256 => Exam) public exams;
    // Mapping to store student exam records by exam ID and student address
    mapping(uint256 => mapping(address => StudentExam)) public studentExams;

    // Event to log when a new exam is created
    event ExamCreated(uint256 indexed examId, string subject, uint256 startTime, uint256 duration, address instructor);
    // Event to log when a student submits an exam
    event ExamSubmitted(uint256 indexed examId, address student);

    // Modifier to check if the exam is active
    modifier onlyActiveExam(uint256 examId) {
        require(exams[examId].isActive, "Exam is not active");
        require(block.timestamp >= exams[examId].startTime, "Exam has not started yet");
        require(block.timestamp <= exams[examId].startTime + exams[examId].duration, "Exam has ended");
        _;
    }

    // Function to create a new exam
    function createExam(uint256 examId, string memory subject, uint256 startTime, uint256 duration, string memory examHash) public {
        require(exams[examId].instructor == address(0), "Exam ID already exists");

        exams[examId] = Exam({
            subject: subject,
            startTime: startTime,
            duration: duration,
            instructor: msg.sender,
            isActive: true,
            examHash: examHash
        });

        emit ExamCreated(examId, subject, startTime, duration, msg.sender);
    }

    // Function to start the exam (can be extended to handle exam-specific logic)
    function startExam(uint256 examId) public {
        require(msg.sender == exams[examId].instructor, "Only instructor can start the exam");
        require(exams[examId].isActive, "Exam is not active");

        exams[examId].startTime = block.timestamp; // Update start time to current time
    }

    // Function for students to submit their exam
    function submitExam(uint256 examId, string memory submissionHash) public onlyActiveExam(examId) {
        require(!studentExams[examId][msg.sender].hasSubmitted, "Exam already submitted");

        studentExams[examId][msg.sender] = StudentExam({
            hasStarted: true,
            hasSubmitted: true,
            submissionHash: submissionHash
        });

        emit ExamSubmitted(examId, msg.sender);
    }

    // Function to end the exam (can be extended to handle exam-specific logic)
    function endExam(uint256 examId) public {
        require(msg.sender == exams[examId].instructor, "Only instructor can end the exam");
        exams[examId].isActive = false;
    }
}

