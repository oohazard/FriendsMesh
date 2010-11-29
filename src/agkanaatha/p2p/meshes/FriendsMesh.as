package agkanaatha.p2p.meshes
{
	import agkanaatha.p2p.rendezvous.RendezVousService;
	import agkanaatha.socialnetwork.Friend;
	import agkanaatha.socialnetwork.PetsCirrusService;
	
	import flash.utils.setInterval;
	
	import org.osflash.signals.Signal;

	public class FriendsMesh
	{	
		private var _fullMesh : FullMesh;
		
		private var _appUserId : String;
		
		public var dataReceived : Signal;
		
		private var _friends : Vector.<Friend>;
		
		private var _myPeerId : String;
		
		// assume the rendez vous service is already initialized and connected
		public function FriendsMesh(rendezVousService : RendezVousService, appUserId : String)
		{
			dataReceived = new Signal(String, Object);
			_appUserId = appUserId;
			_friends = new Vector.<Friend>;
			_fullMesh = new FullMesh(rendezVousService);
			_myPeerId = rendezVousService.myPeerId;
		}
		
		public function initialize() : void
		{
			_fullMesh.initialize();
			_fullMesh.dataReceived.add(onReceive);
			
			updateFriends();			
			setInterval(updateFriends, 9000);
		}
		
		private function updateFriends() : void
		{
			PetsCirrusService.activatePlayer(_appUserId, _myPeerId);
			PetsCirrusService.getActiveFriends(_appUserId, onFriendsListUpdated);			
		}
		
		private function onFriendsListUpdated(result : Array) : void
		{
			_friends = new Vector.<Friend>; // for now simply reset
			var peerIds : Vector.<String> = new Vector.<String>;
			for each (var friendArray : Array in result) 
			{
				peerIds.push(friendArray[1]);
				var friend : Friend = new Friend(friendArray[0], friendArray[1]);
				_friends.push(friend);
			}
			
			_fullMesh.update(peerIds); // list of peer Ids
		}
		
		public function onReceive(peerId : String, message : Object) : void
		{
			// add appUserId ? from peerIds?
			dataReceived.dispatch(peerId, message);
		}

		public function broadcast(message : Object) : void
		{
			_fullMesh.broadcast(message);
		}
		
		public function getAppUserId(peerId : String) : String
		{
			for each (var friend : Friend in _friends)
			{
				if (friend.peerId == peerId)
				{
					return friend.appUserId;
				}
			}
			return null;
		}
		
		public function send(appUserId : String, message : Object) : void
		{
			var peerId : String = getPeerId(appUserId);
			if (peerId)
			{
				_fullMesh.send(peerId, message);	
			}
			
		}
		
		public function getPeerId(appUserId : String) : String
		{
			for each (var friend : Friend in _friends)
			{
				if (friend.appUserId == appUserId)
				{
					return friend.peerId;
				}
			}
			return null;
		}
	}
}