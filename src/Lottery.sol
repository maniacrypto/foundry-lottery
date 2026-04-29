// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.20;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";


error Lottery__NotEnoughFundToEnterLottery();
error Lottery__WinnerTimeRemaining(uint256 remaining);
error Lottery__NumberReqTimeRemaining(uint256 remaining);
error Lottery__FullFillTimeRemaining(uint256 remaining);
error Lottery__CurrentStateNotOpen();
error Lottery__RequestIdsNotMatched(uint256 req,uint256 _req);
error Lottery__FailedToSendFunds(address wiiner);
error Lottery__WinnerLotteryIsOpen();
error Lottery__NumberReqEmptyContest();
error Lottery__NumberReqStateError();
error Lottery__NumberReqNoBalance();
error  Lottery__EnterLotteryClosed(uint256 remaining);
error Lottery__FulfillStateError();
error PerformUpKeep_Error(uint256 balance, uint256 length, uint256 currentState,uint256 remaining);
error t_PerformUpKeep_Error(uint256 currentState ,uint256 startTime);
error Lottery__setTime_ErrorNotOwner(address sender,address owner_addres);
error  Lottery__ModifierErrorNotOwner(address sender,address Owner);
error Lottery__ModifierOnlyVrfAddress(address sender);






contract Lottery is VRFConsumerBaseV2Plus , AutomationCompatibleInterface {
    //event

     event CheckUp(bool key,address add); 
     event keeperData(address add);
     event performkeyIfTrue(bool length,bool timePassed,address sender);
     event performkeyElseBefore(uint256 startTime,address sender);
     event performkeyElseAfter(uint256 startTime,address sender);


    //enum 
    enum State {
        OPEN,
        CLOSE,
        CALCULATING
    }

    //constant And immutable
    uint256 private immutable fees = 1000000000000000;
    //time of lottery in seconds
    uint256 private immutable interval;
    bytes32 private immutable keyHash;
    uint256 private immutable s_subscriptionId;
    uint16 private immutable requestConfirmations;
    uint32 public  callbackGasLimit=300000;
    uint32 private immutable numWords;
    bool private immutable extraArgs;
    address public immutable Owner;
  
    



    //Storage Variables
    address[] public users;
    uint256[] public s_requests;
    State public currentState;
  

    

    //variables

    address public result;
    uint256 public word;
    uint256 private request_id;
    uint256 private startTime;
    address forwarded_address;


    
    //t variable
    // bool[] public t_result;
    // bool[] public t_perform;
 


    

    //constructor
    constructor(
        address _vrfContract,
        bytes32 _keyhash,
        uint256 _subId,
        uint256 _interval,
        uint16 _requestConfirmations,
        uint32 _callbackGasLimit,
        uint32 _numWords,
        bool _extraArgs
        

    ) VRFConsumerBaseV2Plus(_vrfContract) {
        keyHash = _keyhash;
        s_subscriptionId = _subId;
        currentState=State.OPEN;
        requestConfirmations = _requestConfirmations;
        callbackGasLimit = _callbackGasLimit;
        numWords = _numWords;
        extraArgs = _extraArgs;
        interval = _interval;
        startTime=block.timestamp;
        Owner=address(msg.sender);

    }


    //Enter in lottery with some
    function enter() external payable {

        if ((block.timestamp - startTime) > interval) {
            revert Lottery__EnterLotteryClosed((block.timestamp - startTime));
        }

        
        if(currentState != State.OPEN)
        {
          revert Lottery__CurrentStateNotOpen();

        }

        if (msg.value < fees) {
            revert Lottery__NotEnoughFundToEnterLottery();
        }

        users.push(msg.sender);
    }
 
  function checkUpkeep(bytes memory /* checkData */) public  override returns (bool upkeepNeeded, bytes memory /*performData*/) {
   bool state = (currentState != State.CALCULATING);
    bool timePassed = ((block.timestamp - startTime) >= interval);
    // bool length = (users.length > 0);
    // bool hasBalance = address(this).balance > 0;
    // t_result.push(state);
    // t_result.push(timePassed);
    // t_result.push(hasBalance);
    upkeepNeeded = (state && timePassed);
    emit CheckUp(upkeepNeeded, msg.sender); // <-- Move here
    
    return (upkeepNeeded, "");
}
 
//   function t_checkUpkeep(/*bytes memory /* checkData */) public   returns (bool upkeepNeeded, bytes memory /*performData*/) {
//     bool state = (currentState != State.CALCULATING);
//     bool timePassed = ((block.timestamp - startTime) >= interval);
//     // bool length = (users.length > 0);
//     // bool hasBalance = address(this).balance > 0;
//     // t_result.push(state);
//     // t_result.push(timePassed);
//     // t_result.push(hasBalance);
//     upkeepNeeded = (state && timePassed);
//     emit CheckUp(upkeepNeeded, msg.sender); // <-- Move here
    
//     return (upkeepNeeded, "");
// }

//  function t_performUpkeep() external  {
         
//          (bool upkeepNeeded,) = t_checkUpkeep();
//         // require(upkeepNeeded, "Upkeep not needed");
//         if (!upkeepNeeded) {
//             revert();
//             //revert t_PerformUpKeep_Error(uint256(currentState),(block.timestamp - startTime));
//             //revert PerformUpKeep_Error(address(this).balance, users.length, uint256(currentState),(block.timestamp - startTime) );
           
//         }

//         // emit keeperData(msg.sender);


//          bool length = (users.length > 0);
//          bool timePassed = ((block.timestamp - startTime) >= interval);
//          t_perform.push(length);
//          t_perform.push(timePassed);
         





        
//         if(length && timePassed){

//             emit performkeyIfTrue(length,timePassed,msg.sender);


   

        
//         // uint256 requestId = s_vrfCoordinator.requestRandomWords(
//         //     VRFV2PlusClient.RandomWordsRequest({
//         //         keyHash: keyHash,
//         //         subId: s_subscriptionId,
//         //         requestConfirmations: requestConfirmations,
//         //         callbackGasLimit: callbackGasLimit,
//         //         numWords: numWords,
//         //         extraArgs: VRFV2PlusClient._argsToBytes(
//         //             VRFV2PlusClient.ExtraArgsV1({nativePayment: extraArgs})
//         //         )
//         //     })
//         // );
  
//         request_id=123;
//         currentState=State.CLOSE;
//         }else{
//             emit performkeyElseBefore(startTime,msg.sender);
//             startTime=block.timestamp;
//              emit performkeyElseAfter(startTime,msg.sender);
//         }
        
     


   
        
//   }
       
  
    // function setGasLimit(uint32 gas) public {
    //   callbackGasLimit=gas;
    // }



//getter


 function performUpkeep(bytes calldata /* performData */) external override {
         
         (bool upkeepNeeded,) = checkUpkeep("");
        // require(upkeepNeeded, "Upkeep not needed");
        if (!upkeepNeeded) {
            revert PerformUpKeep_Error(address(this).balance, users.length, uint256(currentState),(block.timestamp - startTime) );
           
        }

        // emit keeperData(msg.sender);


         bool length = (users.length > 0);
         bool timePassed = ((block.timestamp - startTime) >= interval);




        
        if(length && timePassed){

            emit performkeyIfTrue(length,timePassed,msg.sender);

   

        
        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: extraArgs})
                )
            })
        );
  
        request_id=requestId;
        currentState=State.CLOSE;
        }else{
            emit performkeyElseBefore(startTime,msg.sender);
            startTime=block.timestamp;
            emit performkeyElseAfter(startTime,msg.sender);
        }
        
     


   
        
  }


    // function requestNumber() external {
    //  if ((block.timestamp - startTime) < interval) {
    //         revert Lottery__NumberReqTimeRemaining((block.timestamp - startTime));
    //     }

    //    if (users.length==0) {
    //         revert Lottery__NumberReqEmptyContest();
    //     }

    //     if(currentState!=State.OPEN){
    //         revert Lottery__NumberReqStateError();
    //     }

   
       
    //    if(address(this).balance == 0 ){
    //     revert Lottery__NumberReqNoBalance();
    //    }   


        
    //     uint256 requestId = s_vrfCoordinator.requestRandomWords(
    //         VRFV2PlusClient.RandomWordsRequest({
    //             keyHash: keyHash,
    //             subId: s_subscriptionId,
    //             requestConfirmations: requestConfirmations,
    //             callbackGasLimit: callbackGasLimit,
    //             numWords: numWords,
    //             extraArgs: VRFV2PlusClient._argsToBytes(
    //                 VRFV2PlusClient.ExtraArgsV1({nativePayment: extraArgs})
    //             )
    //         })
    //     );

    //     currentState=State.CLOSE;
    //     request_id=requestId;
        
        
        
    // }




    function fulfillRandomWords(uint256 _requestId,uint256[] calldata _randomWords) internal override {
        

        if(msg.sender != address(s_vrfCoordinator)){
            revert Lottery__ModifierOnlyVrfAddress(msg.sender);
        }  

         if (currentState != State.CLOSE) {
         revert Lottery__FulfillStateError();
        }
         
   

        

         if(request_id!=_requestId){
          revert Lottery__RequestIdsNotMatched(request_id,_requestId);
         }

         

       currentState=State.CALCULATING;
       
    //    word = _randomWords[0];
       uint256 number = _randomWords[0] % users.length;
       result = users[number];
       address winner=result;
       request_id=0; 
       result = address(0);
       users = new address[](0);
       startTime=block.timestamp;
       currentState=State.OPEN;
       


        (bool success,)=payable(winner).call{value: address(this).balance}("");
        if(!success){
         revert Lottery__FailedToSendFunds(winner);
        }
         
    }







      function requestNumber1() external baseWallet {



      if ((block.timestamp - startTime) < interval) {
            revert Lottery__NumberReqTimeRemaining((block.timestamp - startTime));
        }

       if (users.length==0) {
            revert Lottery__NumberReqEmptyContest();
        }

        if(currentState==State.CALCULATING){
            revert Lottery__NumberReqStateError();
        }

   
       
       if(address(this).balance == 0 ){
        revert Lottery__NumberReqNoBalance();
       }   


        
        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: extraArgs})
                )
            })
        );
  
        request_id=requestId;
        currentState=State.CLOSE;
        
   
  }

     function fulfillRandomWords1 (
        uint256 _requestId,
        uint256[] calldata _randomWords
    ) public baseWallet {

   

        if (currentState != State.CLOSE) {
         revert Lottery__FulfillStateError();
        }
         
        //  if ((block.timestamp - startTime) < interval) {
        //     revert Lottery__FullFillTimeRemaining((block.timestamp - startTime));
        // }

        

         if(request_id!=_requestId){
          revert Lottery__RequestIdsNotMatched(request_id,_requestId);
         }

         

       currentState=State.CALCULATING;
       
    //    word = _randomWords[0];
       uint256 number = _randomWords[0] % users.length;
       result = users[number];
       address winner=result;
       request_id=0; 
       result = address(0);
       users = new address[](0);
       startTime=block.timestamp;
       currentState=State.OPEN;
       


        (bool success,)=payable(winner).call{value: address(this).balance}("");
        if(!success){
         revert Lottery__FailedToSendFunds(winner);
        }
         
   
    }
       function setStartTime() public {
         if(msg.sender!=Owner){
            revert Lottery__setTime_ErrorNotOwner(msg.sender,Owner);
         }
         //setting time to restart lottery
         startTime = block.timestamp;
          
    }
    function setForwardedAddress(address _forwarded_address) public baseWallet{
        forwarded_address=_forwarded_address;
    }

    modifier  onlyVfrAddress{
        if(msg.sender != address(s_vrfCoordinator)){
            revert Lottery__ModifierOnlyVrfAddress(msg.sender);
        }
        _;
    }

    function getTime() public view returns(uint256) {
            
    return block.timestamp - startTime;


    }


  




    function getInterval() public view returns(uint256) {
        return interval;
    }

    function getStartTime() public view returns(uint256) {
        return startTime;
    }
 
    function getbalance() public view returns(uint256){
        return address(this).balance;
    }


  modifier baseWallet{
      if(msg.sender!=Owner){
        revert Lottery__ModifierErrorNotOwner(msg.sender,Owner);
      }
      _;

  }

 

   


    }