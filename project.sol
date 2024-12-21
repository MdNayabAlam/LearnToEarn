// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarn {

    address public owner;
    
    // Structure for a learner
    struct Learner {
        uint256 totalEarnings;
        uint256 videosWatched;
    }

    // Structure for a content creator
    struct Creator {
        uint256 totalEarnings;
        uint256 videosCreated;
    }

    // Mapping of users (learners) and creators by their address
    mapping(address => Learner) public learners;
    mapping(address => Creator) public creators;
    
    // Video structure to hold video details
    struct Video {
        uint256 videoId;
        string title;
        address creator;
        uint256 views;
        uint256 earningsPerView;
    }

    // List of videos available for viewing
    Video[] public videos;

    // Event emitted when a learner watches a video
    event VideoWatched(address indexed learner, uint256 videoId, uint256 earnings);

    // Event emitted when a creator uploads a new video
    event VideoUploaded(address indexed creator, uint256 videoId, string title);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier videoExists(uint256 _videoId) {
        require(_videoId < videos.length, "Video does not exist");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to upload a video
    function uploadVideo(string memory _title, uint256 _earningsPerView) external {
        uint256 videoId = videos.length;
        videos.push(Video({
            videoId: videoId,
            title: _title,
            creator: msg.sender,
            views: 0,
            earningsPerView: _earningsPerView
        }));
        
        emit VideoUploaded(msg.sender, videoId, _title);
    }

    // Function to watch a video and earn rewards
    function watchVideo(uint256 _videoId) external videoExists(_videoId) {
        Video storage video = videos[_videoId];
        
        // Update the views and earnings for the video and the creator
        video.views += 1;
        creators[video.creator].totalEarnings += video.earningsPerView;
        
        // Update the learner's earnings
        learners[msg.sender].totalEarnings += video.earningsPerView;
        learners[msg.sender].videosWatched += 1;
        
        // Emit an event that the learner watched the video
        emit VideoWatched(msg.sender, _videoId, video.earningsPerView);
    }

    // Function to get a learner's total earnings
    function getLearnerEarnings() external view returns (uint256) {
        return learners[msg.sender].totalEarnings;
    }

    // Function to get a creator's total earnings
    function getCreatorEarnings() external view returns (uint256) {
        return creators[msg.sender].totalEarnings;
    }

    // Function to get a learner's total watched videos
    function getLearnerVideosWatched() external view returns (uint256) {
        return learners[msg.sender].videosWatched;
    }

    // Function to get video details by video ID
    function getVideoDetails(uint256 _videoId) external view returns (string memory, address, uint256, uint256) {
        Video memory video = videos[_videoId];
        return (video.title, video.creator, video.views, video.earningsPerView);
    }

    // Function to withdraw contract balance (only for owner)
    function withdraw(uint256 amount) external onlyOwner {
        payable(owner).transfer(amount);
    }

    // Receive function to accept Ether payments
    receive() external payable {}
}

