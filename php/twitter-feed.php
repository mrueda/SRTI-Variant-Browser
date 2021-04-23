<?php
/*
Name: 			Twitter Feed
Written by: 	Okler Themes - (http://www.okler.net)
*/

session_start();
require_once("twitteroauth/twitteroauth.php");

// Replace the keys below - Go to https://dev.twitter.com/apps to create the Application
$consumerkey = "HHUj4mFjL9RdRntW9aZsjdbCN";
$consumersecret = "OKN91zkyzkWOXNpbI1X2fZ1QpZZBxuVxJSvXwKV1BVnjtPl7ui";
$accesstoken = "139489039-ob1LNMJTFHw9hQQoii4eq2BQJHZLpNmS6XiUTs3s";
$accesssecret = "yaZ9vwkOjdKQe0BvK5dFOfvBQrCQAOe8ZkUFFpvNN7oxh";

/*
$twitteruser = $_GET['username'];
$notweets = $_GET['count'];
*/

$twitteruser = "erictopol";
$notweets = 1;

function getConnectionWithAccessToken($cons_key, $cons_secret, $oauth_token, $oauth_token_secret) {
	$connection = new TwitterOAuth($cons_key, $cons_secret, $oauth_token, $oauth_token_secret);
	return $connection;
}

$connection = getConnectionWithAccessToken($consumerkey, $consumersecret, $accesstoken, $accesssecret);
$tweets = $connection->get("https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=".$twitteruser."&count=".$notweets);

$output  = '';
$output .= '<ul>';

foreach($tweets as $key=>$value) {

	$output .= '	<li>';
	$output .= '		<span class="status"><i class="fa fa-twitter"></i>';
	$output .= '		' . $value->text;
	$output .= '		</span>';
	$output .= '	</li>';

}

$output .= '</ul>';

echo $output;
?>
