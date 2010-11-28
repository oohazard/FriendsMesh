package agkanaatha.p2p.meshes
{
	import agkanaatha.socialnetwork.Friend;

	public class FriendsMesh
	{
		private var _rendezVousService : RendezVousService;
		
		private var _fullMesh : FullMesh;
		
		private var _appUserId : String;
		
		public var dataReceived : Signal;
		
		private var _friends : Vector.<Friend>;
		
		// assume the rendez vous service is already initialized and connected
		public function FriendsMesh(rendezVousService : RendezVousService, appUserId : String)
		{
			dataReceived = new Signal(String, String, Object);
			_appUserId = appUserId;
			_rendezVousService = rendezVousService;
			_friends = new Vector.<Friend>;
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
			PetsCirrusService.activatePlayer(_appUserId, _rendezVousService.myPeerId);
			PetsCirrusService.getActiveFriends(_appUserId, onFriendsListUpdated);			
		}
		
		private function onFriendsListUpdated(result : Array) : void
		{
			_fullMesh.update(result); // list of peer Ids
		}
		
		public function onReceive(peerId : String, message : Object) : void
		{
			// add appUserId ?
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
	}
}