package agkanaatha.p2p.meshes
{
	import agkanaatha.p2p.rendezvous.RendezVousService;
	import agkanaatha.socialnetwork.PetsCirrusService;
	import agkanaatha.utils.StringUtils;
	import agkanaatha.utils.Utils;
	
	import flash.net.NetStream;
	import flash.utils.setInterval;
	
	import org.osflash.signals.Signal;
	
	public class FullMesh
	{
		private var _rendezVousService : RendezVousService;
		
		private var _sendStream : NetStream;
		private var _peerStreams : Vector.<NetStream>;

		public var dataReceived : Signal;
		
		// assume the rendez vous service is already initialized and connected
		public function FullMesh(rendezVousService : RendezVousService, appUserId : String)
		{
			dataReceived = new Signal(String, Object);
			_rendezVousService = rendezVousService;
			_friendStreams = new Vector.<NetStream>;
		}
		
		public function initialize(peerIds : Vector.<String> = null) : void
		{
			_sendStream = new NetStream(_rendezVousService.connection, NetStream.DIRECT_CONNECTIONS);
			_sendStream.client = this; 
			_sendStream.publish("p2p");
			
			if (peerIds != null)
			{
				update(peerIds);
			}		
		}
		
		
		private function update(peerIds : Vector.<String>) : void
		{
			var peerStream : NetStream;
			var streamsToRemove : Array = new Array;
			
			for each (peerStream in _peerStreams)
			{
				var found : Boolean = false;
				for each (peerId in peerIds)
				{
					if (peerStream.farID == peerId)
					{
						found = true;
						break;
					}
				}
				if(!found)
				{
					streamsToRemove.push(peerStream);	
				}
			}
			
			for each (peerStream in streamsToRemove)
			{
				removePeerStream(peerStream);
			}
			
			for each (peerId in peerIds)
			{	
				if (getPeerStream(peerId) == null)
				{
					peerStream = createFriendStream(peerId);		
					addFriendStream(friendStream);
				}
			}
		}
		
		private function createPeerStream(peerId : String) : NetStream
		{
			var recvStream : NetStream = new NetStream(_rendezVousService.connection, peerId);
			recvStream.client = this; 
			recvStream.play("p2p");
			return recvStream;
		}
		
		public function getPeerStream(peerId : String) : NetStream
		{
			for each (var peerStream : NetStream in _peerStreams)
			{
				if (peerStream.farID == peerId)
				{
					return peerStream;
				}
			}
			return null;
		}
		
		private function addPeerStream(stream : NetStream) : void
		{
			_peerStreams.push(stream);
		}
		
		private function removePeerStream(stream : NetStream) : void
		{
			stream.close();
			_friendStreams.splice(_peerStreams.indexOf(stream),1);
		}
		
		public function onReceive(data : Object) : void
		{
			dataReceived.dispatch(data.peerId, data.message);
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
			data.peerId = _rendezVousService.myPeerId;
			_sendStream.send("onReceive",  data);
		}
	}
}