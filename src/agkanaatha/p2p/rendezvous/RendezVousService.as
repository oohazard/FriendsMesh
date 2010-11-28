package agkanaatha.p2p.rendezvous
{
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	//import lib.event.ConnectionEvent;
	//import lib.event.IncomingConnectionEvent;
	
	public class RendezVousService extends EventDispatcher
	{
		public var connected : Signal;
		public var error : Signal;
		
		private var _rendezVousAddress : String;
		private var _developerKey : String;
			
		private var _connection : NetConnection;
		public function get connection() : NetConnection { return _connection;	}
		
		private var _myPeerId : String;
		public function get myPeerId() : String { return _myPeerId;	}
		
		public function RendezVousService(rendezVousAddress : String = "rtmfp://p2p.rtmfp.net", developerKey : String = "")
		{
			connected = new Signal(String);
			error = new Signal(String);
			_rendezVousAddress = rendezVousAddress;
			_developerKey = developerKey;
		}
		
		public function connect() : void
		{
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, netConnectionHandler);
			_connection.connect(_rendezVousAddress + "/" + _developerKey);
		}
		
		private function netConnectionHandler(event : NetStatusEvent) : void
		{
			trace("rendezVous netConnectionHandler : " + event.info.code);
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					_myPeerId = connection.nearID;
					connected.dispatch(_myPeerId);
					break;
				case "NetConnection.Connect.Failed":
					error.dispatch("You failed to connect to the Rendez vous service (" + _rendezVousAddress + ").");
					break;
				case "NetStream.Connect.Closed":
					event.info.stream.dispatchEvent(event);//event redirection
					break;
				case "NetStream.Connect.Success":
					event.info.stream.dispatchEvent(event);//event redirection
					break;
			}		
		}
		
	}
}