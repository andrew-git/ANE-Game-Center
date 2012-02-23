package com.sticksports.nativeExtensions.gameCenter
{
	import org.osflash.signals.Signal;

	public class GameCenter
	{
		public static var localPlayerAuthenticated : Signal = new Signal();
		public static var localPlayerNotAuthenticated : Signal = new Signal();
		public static var localPlayerFriendsLoadComplete : Signal = new Signal( Array );
		public static var localPlayerFriendsLoadFailed : Signal = new Signal();
		public static var localPlayerScoreLoadComplete : Signal = new Signal( GCScore );
		public static var localPlayerScoreLoadFailed : Signal = new Signal();
		public static var localPlayerScoreReported : Signal = new Signal();
		public static var localPlayerScoreReportFailed : Signal = new Signal();
		public static var localPlayerAchievementReported : Signal = new Signal();
		public static var localPlayerAchievementReportFailed : Signal = new Signal();
		public static var gameCenterViewRemoved : Signal = new Signal();
		
		public static var isAuthenticating : Boolean;
		
		public static function init() : void
		{
		}
		
		/**
		 * Is the extension supported
		 */
		public static function get isSupported() : Boolean
		{
			return false;
		}
		
		private static function throwNotSupportedError() : void
		{
			throw new Error( "Game Kit is not supported on this device." );
		}

		/**
		 * Authenticate the local player
		 */
		public static function authenticateLocalPlayer() : void
		{
			throwNotSupportedError();
		}

		public static function get isAuthenticated() : Boolean
		{
			return false;
		}

		/**
		 * Authenticate the local player
		 */
		public static function get localPlayer() : GCLocalPlayer
		{
			throwNotSupportedError();
			return null;
		}

		/**
		 * Report a score to Game Kit
		 */
		public static function reportScore( category : String, value : int ) : void
		{
			throwNotSupportedError();
		}
		
		/**
		 * Report a achievement to Game Kit
		 */
		public static function reportAchievement( category : String, value : Number ) : void
		{
			throwNotSupportedError();
		}

		public static function showStandardLeaderboard( category : String = "", timeScope : int = -1 ) : void
		{
			throwNotSupportedError();
		}
		
		public static function showStandardAchievements() : void
		{
			throwNotSupportedError();
		}

		public static function getLocalPlayerFriends() : void
		{
			throwNotSupportedError();
		}
		
		public static function getLocalPlayerScore( category : String, playerScope : int = 0, timeScope : int = 2 ) : void
		{
			throwNotSupportedError();
		}
		
		/**
		 * Clean up the extension - only if you no longer need it or want to free memory.
		 */
		public static function dispose() : void
		{
			localPlayerAuthenticated.removeAll();
			localPlayerNotAuthenticated.removeAll();
			localPlayerFriendsLoadComplete.removeAll();
			localPlayerFriendsLoadFailed.removeAll();
			localPlayerScoreLoadComplete.removeAll();
			localPlayerScoreLoadFailed.removeAll();
			localPlayerScoreReported.removeAll();
			localPlayerScoreReportFailed.removeAll();
			localPlayerAchievementReported.removeAll();
			localPlayerAchievementReportFailed.removeAll();
			gameCenterViewRemoved.removeAll();
		}
	}
}
