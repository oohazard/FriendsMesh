package agkanaatha.socialnetwork
{
	public class Friend
	{
		
		public var appUserId : String;
		public var peerId : String;
		
		public function Friend(appUserId : String, peerId : String)
		{
			this.appUserId = appUserId;
			this.peerId = peerId;
		}
	}
}