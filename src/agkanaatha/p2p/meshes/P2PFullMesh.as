package agkanaatha.p2p.meshes
{
	import agkanaatha.p2p.rendezvous.RendezVousService;
	import agkanaatha.socialnetwork.PetsCirrusService;
	import agkanaatha.utils.StringUtils;
	import agkanaatha.utils.Utils;
	
	import flash.net.NetStream;
	import flash.utils.setInterval;
	
	import org.osflash.signals.Signal;

	public class P2PFullMesh
	{
		private var _rendezVousService : RendezVousService;
		
		private var _sendStream : NetStream;
		private var _friendStreams : Vector.<NetStream>;
		
		private var _appUserId : String;
		
		public var dataReceived : Signal;
		
		// assume the rendez vous service is already initialized and connected
		public function P2PFullMesh(rendezVousService : RendezVousService, appUserId : String)
		{
			dataReceived = new Signal(String, String, String);
			_appUserId = appUserId;
			_rendezVousService = rendezVousService;
			_friendStreams = new Vector.<NetStream>;
		}
		
		public function initialize() : void
		{
			_sendStream = new NetStream(_rendezVousService.connection, NetStream.DIRECT_CONNECTIONS);
			_sendStream.client = this; 
			_sendStream.publish("p2p");
			
			PetsCirrusService.activatePlayer(_appUserId, _rendezVousService.myPeerId);
			PetsCirrusService.getActiveFriends(_appUserId, onFriendsList);
			
			setInterval(updateFriends, 9000);
		}
		
		private function onFriendsList(result : Array) : void
		{
			for each (var friendArray : Array in result)
			{
				// shoudl only connect on currently connected friend, is there a way to check whether a group is empty ?
				var friendAppId : String = friendArray[0];
				var friendPeerId : String = friendArray[1];
				
				var recvStream : NetStream = createFriendStream(friendPeerId);
				_friendStreams.push(recvStream);
			}
		}
		
		private function createFriendStream(peerId : String) : NetStream
		{
			var recvStream : NetStream = new NetStream(_rendezVousService.connection, peerId);
			recvStream.client = this; 
			recvStream.play("p2p");
			return recvStream;
		}
		
		private function updateFriends() : void
		{
			PetsCirrusService.activatePlayer(_appUserId, _rendezVousService.myPeerId);
			PetsCirrusService.getActiveFriends(_appUserId, onFriendsListUpdated);
			
		}
		
		private function onFriendsListUpdated(result : Array) : void
		{
			var friendArray : Array;
			var friendStream : NetStream;
			
			var streamsToRemove : Array = new Array;
			
			for each (friendStream in _friendStreams)
			{
				var found : Boolean = false;
				for each (friendArray in result)
				{
					if (friendStream.farID == friendArray[1])
					{
						found = true;
						break;
					}
				}
				if(!found)
				{
					streamsToRemove.push(friendStream);	
				}
			}
			
			for each (friendStream in streamsToRemove)
			{
				removeFriendStream(friendStream);
			}
			
			for each (friendArray in result)
			{
				var friendAppId : String = friendArray[0];
				var friendPeerId : String = friendArray[1];
				
				if (getFriendStreamByPeerId(friendPeerId) == null)
				{
					friendStream = createFriendStream(friendPeerId);		
					addFriendStream(friendStream);
				}
			}
		}
		
		public function getFriendStreamByPeerId(peerId : String) : NetStream
		{
			for each (var friendStream : NetStream in _friendStreams)
			{
				if (friendStream.farID == peerId)
				{
					return friendStream;
				}
			}
			return null;
		}
		
		private function addFriendStream(stream : NetStream) : void
		{
			_friendStreams.push(stream);
		}
		
		private function removeFriendStream(stream : NetStream) : void
		{
			stream.close();
			_friendStreams.splice(_friendStreams.indexOf(stream),1);
		}

		public function onReceive(data : Object) : void
		{
			trace(data.message + " from " + data.appUserId + "(" + data.peerId +  ")");
			dataReceived.dispatch(data.message, data.appUserId, data.peerId);
		}
		
		
		// one onPeerConnect for all ?
		public function onPeerConnect(caller : NetStream) : Boolean {
			//dataReceived.dispatch("peerConnect", "new", caller.farID);
			return true; // accept all (should only accept friends)
		}

		
		public function broadcast(message : Object) : void
		{
			var data : Object = new Object;
			data.uniqueId = StringUtils.generateRandomString(64);
			data.message = message;
			data.appUserId = _appUserId;
			data.peerId = _rendezVousService.myPeerId;
			_sendStream.send("onReceive",  data);
		}
	}
}