package
{
	import com.sticksports.nativeExtensions.gameCenter.GCLeaderboard;
	import com.sticksports.nativeExtensions.gameCenter.GCPlayer;
	import com.sticksports.nativeExtensions.gameCenter.GameCenter;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	
	[SWF(width='320', height='480', frameRate='30', backgroundColor='#000000')]
	
	public class GameCenterExtensionTest extends Sprite
	{
		private var direction : int = 1;
		private var shape : Shape;
		private var feedback : TextField;
		
		private var buttonFormat : TextFormat;
		
		public function GameCenterExtensionTest()
		{
			shape = new Shape();
			shape.graphics.beginFill( 0x666666 );
			shape.graphics.drawCircle( 0, 0, 100 );
			shape.graphics.endFill();
			shape.x = 0;
			shape.y = 240;
			addChild( shape );
			
			feedback = new TextField();
			var format : TextFormat = new TextFormat();
			format.font = "_sans";
			format.size = 16;
			format.color = 0xFFFFFF;
			feedback.defaultTextFormat = format;
			feedback.width = 320;
			feedback.height = 260;
			feedback.x = 10;
			feedback.y = 210;
			feedback.multiline = true;
			feedback.wordWrap = true;
			feedback.text = "Hello";
			addChild( feedback );
			
			addEventListener( Event.ENTER_FRAME, animate );

			GameCenter.init();
			createButtons();
		}
		
		private function createButtons() : void
		{
			var tf : TextField = createButton( "isSupported" );
			tf.x = 10;
			tf.y = 10;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, checkSupported );
			addChild( tf );
			
			tf = createButton( "authenticate" );
			tf.x = 170;
			tf.y = 10;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, authenticateLocalPlayer );
			addChild( tf );
			
			tf = createButton( "localPlayer" );
			tf.x = 10;
			tf.y = 50;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, getLocalPlayer );
			addChild( tf );
			
			tf = createButton( "playerScore" );
			tf.x = 170;
			tf.y = 50;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, getPlayerScore );
			addChild( tf );
			
			tf = createButton( "submitScore" );
			tf.x = 10;
			tf.y = 90;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, submitScore );
			addChild( tf );
			
			tf = createButton( "submitAchievement" );
			tf.x = 170;
			tf.y = 90;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, submitAchievement );
			addChild( tf );
			
			tf = createButton( "showLeaderboard" );
			tf.x = 10;
			tf.y = 130;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, showLeaderboard );
			addChild( tf );
			
			tf = createButton( "showAchievements" );
			tf.x = 170;
			tf.y = 130;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, showAchievements );
			addChild( tf );
			
			tf = createButton( "getFriends" );
			tf.x = 10;
			tf.y = 170;
			tf.addEventListener( MouseEvent.MOUSE_DOWN, getFriends );
			addChild( tf );
		}
		
		private function createButton( label : String ) : TextField
		{
			if( !buttonFormat )
			{
				buttonFormat = new TextFormat();
				buttonFormat.font = "_sans";
				buttonFormat.size = 14;
				buttonFormat.bold = true;
				buttonFormat.color = 0xFFFFFF;
				buttonFormat.align = TextFormatAlign.CENTER;
			}
			
			var textField : TextField = new TextField();
			textField.defaultTextFormat = buttonFormat;
			textField.width = 140;
			textField.height = 30;
			textField.text = label;
			textField.backgroundColor = 0xCC0000;
			textField.background = true;
			textField.selectable = false;
			textField.multiline = false;
			textField.wordWrap = false;
			return textField;
		}
		
		private function checkSupported( event : MouseEvent ) : void
		{
			feedback.text = "GameCenter.isSupported:\n  " + GameCenter.isSupported;
		}
		
		private function authenticateLocalPlayer( event : MouseEvent ) : void
		{
			feedback.text = "GameCenter.authenticateLocalPlayer():";
			try
			{
				GameCenter.localPlayerAuthenticated.add( localPlayerAuthenticated );
				GameCenter.localPlayerNotAuthenticated.add( localPlayerNotAuthenticated );
				GameCenter.authenticateLocalPlayer();
			}
			catch( error : Error )
			{
				GameCenter.localPlayerAuthenticated.remove( localPlayerAuthenticated );
				GameCenter.localPlayerNotAuthenticated.remove( localPlayerNotAuthenticated );
				feedback.appendText( "\n  " + error.message );
			}
		}

		private function localPlayerAuthenticated() : void
		{
			GameCenter.localPlayerAuthenticated.remove( localPlayerAuthenticated );
			GameCenter.localPlayerNotAuthenticated.remove( localPlayerNotAuthenticated );
			feedback.appendText( "\n  localPlayerAuthenticated" );
		}
		
		private function localPlayerNotAuthenticated() : void
		{
			GameCenter.localPlayerAuthenticated.remove( localPlayerAuthenticated );
			GameCenter.localPlayerNotAuthenticated.remove( localPlayerNotAuthenticated );
			feedback.appendText( "\n  localPlayerNotAuthenticated" );
		}

		private function getLocalPlayer( event : MouseEvent ) : void
		{
			feedback.text = "GameCenter.localPlayer:";
			try
			{
				if( GameCenter.localPlayer )
				{
					feedback.appendText( "\n  id: " + GameCenter.localPlayer.id + "\n  alias: " + GameCenter.localPlayer.alias );
				}
				else
				{
					feedback.appendText( "\n  null" );
				}
			}
			catch( error : Error )
			{
				feedback.appendText( "\n  " + error.message );
			}
		}
		
		private function getPlayerScore( event : MouseEvent ) : void
		{
			feedback.text = "GameCenter.getLocalPlayerScore()";
			try
			{
				GameCenter.localPlayerScoreLoadComplete.add( localPlayerScoreLoaded );
				GameCenter.localPlayerScoreLoadFailed.add( localPlayerScoreFailed );
				GameCenter.getLocalPlayerScore( "HighScore" );
			}
			catch( error : Error )
			{
				GameCenter.localPlayerScoreLoadComplete.remove( localPlayerScoreLoaded );
				GameCenter.localPlayerScoreLoadFailed.remove( localPlayerScoreFailed );
				feedback.appendText( "\n  " + error.message );
			}
		}
		
		private function localPlayerScoreLoaded( leaderboard : GCLeaderboard ) : void
		{
			GameCenter.localPlayerScoreLoadComplete.remove( localPlayerScoreLoaded );
			GameCenter.localPlayerScoreLoadFailed.remove( localPlayerScoreFailed );
			feedback.appendText( "\n  localPlayerScoreLoadComplete" );
			feedback.appendText( "\n    board category : " + leaderboard.category );
			feedback.appendText( "\n    board title : " + leaderboard.title );
			feedback.appendText( "\n    rankMax : " + leaderboard.rangeMax );
			if( leaderboard.localPlayerScore )
			{
				feedback.appendText( "\n    playerId : " + leaderboard.localPlayerScore.playerId );
				feedback.appendText( "\n    rank : " + leaderboard.localPlayerScore.rank );
				feedback.appendText( "\n    value : " + leaderboard.localPlayerScore.value );
				feedback.appendText( "\n    formattedValue : " + leaderboard.localPlayerScore.formattedValue );
				feedback.appendText( "\n    date : " + leaderboard.localPlayerScore.date );
			}
			else
			{
				feedback.appendText( "\n    no score for local player" );
			}
		}
		
		private function localPlayerScoreFailed() : void
		{
			GameCenter.localPlayerScoreLoadComplete.remove( localPlayerScoreLoaded );
			GameCenter.localPlayerScoreLoadFailed.remove( localPlayerScoreFailed );
			feedback.appendText( "\n  localPlayerScoreLoadFailed" );
		}
		
		private function submitScore( event : MouseEvent ) : void
		{
			feedback.text = "GameCenter.submitScore()";
			try
			{
				GameCenter.localPlayerScoreReported.add( scoreReportSuccess );
				GameCenter.localPlayerScoreReportFailed.add( scoreReportFailed );
				GameCenter.reportScore( "HighScore", 180 );
			}
			catch( error : Error )
			{
				feedback.appendText( "\n  " + error.message );
			}
		}
		
		private function scoreReportFailed() : void
		{
			GameCenter.localPlayerScoreReported.remove( scoreReportSuccess );
			GameCenter.localPlayerScoreReportFailed.remove( scoreReportFailed );
			feedback.appendText( "\n  localPlayerScoreReportFailed" );
		}
		
		private function scoreReportSuccess() : void
		{
			GameCenter.localPlayerScoreReported.remove( scoreReportSuccess );
			GameCenter.localPlayerScoreReportFailed.remove( scoreReportFailed );
			feedback.appendText( "\n  localPlayerScoreReported" );
		}
		
		private function submitAchievement( event : MouseEvent ) : void
		{
			feedback.text = "GameCenter.reportAchievement()";
			try
			{
				GameCenter.localPlayerAchievementReported.add( achievementReportSuccess );
				GameCenter.localPlayerAchievementReportFailed.add( achievementReportFailed );
				GameCenter.reportAchievement( "started", 1 );
			}
			catch( error : Error )
			{
				feedback.appendText( "\n  " + error.message );
			}
		}
		
		private function achievementReportFailed() : void
		{
			GameCenter.localPlayerAchievementReported.remove( achievementReportSuccess );
			GameCenter.localPlayerAchievementReportFailed.remove( achievementReportFailed );
			feedback.appendText( "\n  localPlayerAchievementReportFailed" );
		}
		
		private function achievementReportSuccess() : void
		{
			GameCenter.localPlayerAchievementReported.remove( achievementReportSuccess );
			GameCenter.localPlayerAchievementReportFailed.remove( achievementReportFailed );
			feedback.appendText( "\n  localPlayerAchievementReported" );
		}
		
		private function showLeaderboard( event : MouseEvent ) : void
		{
			feedback.text = "GameCenter.showStandardLeaderboard()";
			try
			{
				GameCenter.showStandardLeaderboard();
			}
			catch( error : Error )
			{
				feedback.appendText( "\n  " + error.message );
			}
		}
		
		private function showAchievements( event : MouseEvent ) : void
		{
			feedback.text = "GameCenter.showStandardAchievements()";
			try
			{
				GameCenter.showStandardAchievements();
			}
			catch( error : Error )
			{
				feedback.appendText( "\n  " + error.message );
			}
		}
		
		private function getFriends( event : MouseEvent ) : void
		{
			feedback.text = "GameCenter.getLocalPlayerFriends()";
			try
			{
				GameCenter.localPlayerFriendsLoadComplete.add( localPlayerFriendsLoaded );
				GameCenter.localPlayerFriendsLoadFailed.add( localPlayerFriendsFailed );
				GameCenter.getLocalPlayerFriends();
			}
			catch( error : Error )
			{
				GameCenter.localPlayerFriendsLoadComplete.remove( localPlayerFriendsLoaded );
				GameCenter.localPlayerFriendsLoadFailed.remove( localPlayerFriendsFailed );
				feedback.appendText( "\n  " + error.message );
			}
		}
		
		private function localPlayerFriendsLoaded( friends : Array ) : void
		{
			GameCenter.localPlayerFriendsLoadComplete.remove( localPlayerFriendsLoaded );
			GameCenter.localPlayerFriendsLoadFailed.remove( localPlayerFriendsFailed );
			feedback.appendText( "\n  localPlayerFriendsLoadComplete" );
			if( friends.length == 0 )
			{
				feedback.appendText( "\n    player has no friends" );
			}
			else
			{
				for each (var friend : GCPlayer in friends )
				{
					feedback.appendText( "\n    id : " + friend.id + ", alias : " + friend.alias );
				}
			}
		}
		
		private function localPlayerFriendsFailed() : void
		{
			GameCenter.localPlayerFriendsLoadComplete.remove( localPlayerFriendsLoaded );
			GameCenter.localPlayerFriendsLoadFailed.remove( localPlayerFriendsFailed );
			feedback.appendText( "\n  localPlayerFriendsLoadFailed" );
		}
		
		private function animate( event : Event ) : void
		{
			shape.x += direction;
			if( shape.x <= 0 )
			{
				direction = 1;
			}
			if( shape.x > 320 )
			{
				direction = -1;
			}
		}
	}
}