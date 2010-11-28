package agkanaatha.p2p.test
{
	import agkanaatha.p2p.meshes.P2PFullMesh;
	import agkanaatha.p2p.rendezvous.RendezVousService;
	
	import flash.events.FullScreenEvent;
	import flash.events.NetStatusEvent;
	
	import org.osflash.signals.Signal;

	public class FriendsMeshTest 
	{
		private var _rendezVousService : RendezVousService;
		private var _fullMesh : P2PFullMesh;
		
		public var dataReceived : Signal;
		
		public function FriendsMeshTest()
		{
			dataReceived = new Signal(String, String, String);
			_rendezVousService = new RendezVousService("rtmfp://p2p.rtmfp.net", "a6b44c10cf73bdb3f90e80c0-1d11f1ce71b5");		
		}
		
		public function initialize(appUserId : String) : void
		{
			trace("logged in : " + appUserId);
			
			_rendezVousService.connected.addOnce(rendezVousEstablished);
			_rendezVousService.connect();
			_fullMesh = new P2PFullMesh(_rendezVousService, appUserId);
		}
		
		public function rendezVousEstablished(peerId : String) : void
		{
			_fullMesh.initialize();
			_fullMesh.dataReceived.add(onDataReceived);
		}
		
		public function broadcast(message : String) : void
		{
			_fullMesh.broadcast(message);
		}
		
		public function onDataReceived(message : String, appUserId : String, peerId : String) : void
		{
			dataReceived.dispatch(message, appUserId, peerId);
		}
	}
}