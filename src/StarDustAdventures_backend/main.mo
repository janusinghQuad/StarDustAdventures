import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Constants "constants";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Types "types";
actor {
 
  // this map contains list of users
  let userMap=TrieMap.TrieMap<Principal,Types.User>(Principal.equal,Principal.hash); 

  // referral map, contains list of people referred by user
  let friendMap=TrieMap.TrieMap<Principal,[(Principal,Text)]>(Principal.equal,Principal.hash); 

  // Registering new users
  public shared({caller}) func createUser(user:Types.User,refBy:?Principal):async Result.Result<Types.User,Text>{
    try{
      let oldUser=userMap.get(caller);
      
      if(oldUser!=null){
        return #err(Constants.ERRORS.useralreadyExists # Principal.toText(caller));
      };

      let newUser:Types.User={
        id=caller;
        name=user.name;
        points=0;
        clickLimitHour=1000;
        prizePerHour=300;
        status=#active;
      };

      switch(refBy){
        case(null){
          userMap.put(caller,newUser);
          return #ok(newUser);
        };
        case(?val){
          let addFriendResponse=await addFriend(val,newUser);
          switch(addFriendResponse){
            case(#ok){
              return #ok(newUser)
            };
            case(#err(error)){
              return #err(error);
            }
          }
        }
      };

      return #ok(newUser)
    }catch(err){
      return #err(Error.message(err));
    }
  };

  // Update user meant to be called by user himself (if needed)
  public shared({caller}) func updateUser(user:Types.User):async Result.Result<Types.User,Text>{
    try{
      let oldUser=userMap.get(caller);
      
      switch(oldUser) {
        case(null) { 
          return #err(Constants.ERRORS.userNotFound)
        };
        case(?val) {

          if(caller!=val.id){
            return #err(Constants.ERRORS.cannotUpdateOtherUser)
          };

          let updatedUser:Types.User={
            id=caller;
            name=user.name;
            points=val.points;
            clickLimitHour=val.clickLimitHour;
            prizePerHour=val.prizePerHour;
            status=user.status;
          };
          ignore userMap.replace(caller,updatedUser);
          return #ok(updatedUser)
        };
      };
    }catch(err){
      return #err(Error.message(err));
    }
  };

  // Disables the user, can be used as 'delete user'
  public shared({caller}) func disableUser():async Result.Result<Text,Text>{
    try{
      let oldUser=userMap.get(caller);
      
      switch(oldUser) {
        case(null) { 
          return #err(Constants.ERRORS.userNotFound)
        };
        case(?val){

          if(caller!=val.id){
            return #err(Constants.ERRORS.cannotUpdateOtherUser)
          };

          let user:Types.User={
            id=caller;
            name=val.name;
            points=val.points;
            clickLimitHour=val.clickLimitHour;
            prizePerHour=val.prizePerHour;
            status=#disabled;
          };

          ignore userMap.replace(caller,user);
          return #ok(Constants.RESPONSES.disabledUser);
        }
      }
    }catch(err){
      return #err(Error.message(err));
    }
  };


  // returns the list of friends of the caller
  public shared query({caller}) func getUserFriends():async Result.Result<?[(Principal,Text)],Text>{
    try{
       let oldUser=userMap.get(caller);
        switch(oldUser) {
          case(null) { return #err(Constants.ERRORS.userNotFound) };
          case(_) {
            let friendList=friendMap.get(caller);
            return #ok(friendList)
          }
        };
    }catch(err){
      return #err(Error.message(err));
    }
  };

    // internal function, adds new points. will be used in future improvements
  func addPointsToUser(id:Principal,points:Nat):async Result.Result<(),Text>{
    try{
      let oldUser=userMap.get(id);
      switch(oldUser) {
        case(null) { return #err(Constants.ERRORS.userNotFound) };
        case(?val) {
          let user:Types.User={
            id=id;
            name=val.name;
            points=val.points + points;
            clickLimitHour=val.clickLimitHour;
            prizePerHour=val.prizePerHour;
            status=val.status;
          };

          ignore userMap.replace(id,user);
          return #ok();
        };
      };
    }catch(err){
      return #err(Error.message(err));
    }
  };

  // adding new friends in referral map
  func addFriend(user:Principal,friend:Types.User):async Result.Result<(),Text>{
    try{
        let oldUser=userMap.get(user);

        if(oldUser==null){
          return #err(Constants.ERRORS.invalidReferral);
        };

        let oldFriendList=friendMap.get(user);
        switch(oldFriendList){
          case(null){
            friendMap.put(user,[(friend.id,friend.name)]);
            return #ok(())
          };
          case(?list){
            let newList:Buffer.Buffer<(Principal,Text)> = Buffer.fromArray(list);
            newList.add((friend.id,friend.name));
            ignore friendMap.replace(user,Buffer.toArray(newList));
            return #ok(());
          }
        }
    }catch(err){
       return #err(Error.message(err));
    }

  };
  
  public shared query({caller}) func whoami():async Text{
    return Principal.toText(caller);
  };
};
