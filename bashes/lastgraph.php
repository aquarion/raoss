<?PHP
date_default_timezone_set("Europe/London");

$data = array(
	"start" => "2010/01/01",
	"end"   => "2010/12/31",
	"style" => "blue",
	"detail"=> 2
);

define("STARTTIME", 1104645600);

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://lastgraph.aeracode.org/user/aquarion/posters/");
curl_setopt($ch, CURLOPT_HEADER, 1);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Expect:'));


$time = strtotime("2010-01-01 00:00");
while ($time < time()){
	$until = strtotime("+ 1 month", $time);

	$data['start'] = date("Y/m/d", $time);
	$data['end'] = date("Y/m/d", $until-1);

	echo $data['start']." -> ".$data['end']."\n";

	// set URL and other appropriate options
	curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
	// grab URL and pass it to the browser
	curl_exec($ch);

	$time = $until;
}


// close cURL resource, and free up system resources
curl_close($ch);
