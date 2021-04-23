<?php

$apikey         = '00000000000000000000000000000000-us00' // How get your Mailchimp API KEY - http://kb.mailchimp.com/article/where-can-i-find-my-api-key
$auth = base64_encode( 'user:'.$apikey );

$listId 	= '000000000a';  // How to get your Mailchimp LIST ID - http://kb.mailchimp.com/article/how-can-i-find-my-list-id
$submit_url	= "http://us11.api.mailchimp.com//3.0/lists/$listId/members/";  // us11 MUST match the apiKey

$double_optin = false;
$send_welcome = false;
$email_type = 'html';
#$email = 'petlr@pan.com';
$email = $_POST['email'];

#$merge_vars = array( 'YNAME' => $_POST['yname'] );

$data = array(
    'apikey' => $apikey,
    'email_address' => $email,
    'double_optin' => $double_optin,
    'status'       => 'subscribed',
    'send_welcome' => $send_welcome
    #'merge_fields' => $merge_vars # We do not have them
);

$json_data = json_encode($data);

$ch = curl_init();

# On January'15 I discovered that Mailchimp API required the apikey authentification from outside the JSON
# Thus, the previous code from Okler themes did not work
# It took me the whole morning to figure out a solution
# http://stackoverflow.com/questions/30481979/adding-subscribers-to-a-list-using-mailchimps-api-v3

#curl_setopt($ch, CURLOPT_USERPWD, "user:" . $apikey); # Did not work :-(
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json','Authorization: Basic '.$auth));
curl_setopt($ch, CURLOPT_URL, $submit_url);
curl_setopt($ch, CURLOPT_USERAGENT, 'PHP-MCAPI/2.0');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_POSTFIELDS, $json_data);

$result = curl_exec($ch);
curl_close ($ch);

#print $result;
$new_data = json_decode($result);

# detail is a key from the JSON, now transformed to object
if (isset($new_data->detail)) {
    $data_result = array ('response'=>'error','message'=>$new_data->detail);
    $data_result = str_replace('  Use PUT to insert or update list members.', '', $data_result);
} else {
    $data_result = array ('response'=>'success');
}

echo json_encode($data_result);
