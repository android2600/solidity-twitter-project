// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Twitter {
    // ----- START OF DO-NOT-EDIT ----- //
    struct Tweet {
        uint tweetId;
        address author;
        string content;
        uint createdAt;
    }

    struct Message {
        uint messageId;
        string content;
        address from;
        address to;
    }

    struct User {
        address wallet;
        string name;
        uint[] userTweets;
        address[] following;
        address[] followers;
        mapping(address => Message[]) conversations;
    }

    mapping(address => User) public users;
    mapping(uint => Tweet) public tweets;

    uint256 public nextTweetId;
    uint256 public nextMessageId;
    // ----- END OF DO-NOT-EDIT ----- //

    // ----- START OF QUEST 1 ----- //
    function registerAccount(string calldata _name) external {
        bytes memory tempEmptyStringTest = bytes(_name); // Uses memory
        require(tempEmptyStringTest.length>0, "Name cannot be an empty string");
        User storage user=users[msg.sender]; // Different behaviour when changing initialization statement
        user.wallet=msg.sender;
        user.name=_name;
    }


    function postTweet(string calldata _content) external accountExists(msg.sender) {     
        tweets[nextTweetId].tweetId=nextTweetId;
        tweets[nextTweetId].author=msg.sender;
        tweets[nextTweetId].content=_content;
        tweets[nextTweetId].createdAt=block.timestamp;
        users[msg.sender].userTweets.push(nextTweetId);
        nextTweetId=nextTweetId+1;
    }

    function readTweets(address _user) view external accountExists(msg.sender) returns(Tweet[] memory) {
        uint[] memory userTweetIds=users[_user].userTweets;
        Tweet[] memory userTweet = new Tweet[](userTweetIds.length);
        for(uint i=0;i<userTweetIds.length;i++)
        {
            userTweet[i]=(tweets[userTweetIds[i]]);
        }
        return userTweet;
    }

    modifier accountExists(address _user) {
        bytes memory test=bytes(users[_user].name);
        require(test.length>0,"This wallet does not belong to any account.");
        _;
    }

    // ----- END OF QUEST 1 ----- //

    // ----- START OF QUEST 2 ----- //
    function followUser(address _user) external {
        users[msg.sender].following.push(_user);
        users[_user].followers.push(msg.sender);
    }

    function getFollowing() external view returns(address[] memory)  {
        return users[msg.sender].following;
    }

    function getFollowers() external view returns(address[] memory) {
        return users[msg.sender].followers;
    }

    function getTweetFeed() view external returns(Tweet[] memory) {
        Tweet[] memory arr=new Tweet[](nextTweetId);
        for(uint i=0;i<nextTweetId;i++){
            arr[i]=tweets[i];
        }
        return arr;
    }

    function sendMessage(address _recipient, string calldata _content) external {
        Message memory message;
        message.messageId=nextMessageId;
        message.content=_content;
        message.from=msg.sender;
        message.to=_recipient;
        users[msg.sender].conversations[_recipient].push(message);
        users[_recipient].conversations[msg.sender].push(message);
        nextMessageId+=1;
    }

    function getConversationWithUser(address _user) external view returns(Message[] memory) {
        return users[msg.sender].conversations[_user];
    }
    // ----- END OF QUEST 2 ----- //
}