<?PHP
date_default_timezone_set("Europe/London");

// 134009 134071

$number = 134009;

$time = strtotime("2005-02-01 00:00");
while ($time < time()){
	$until = strtotime("+ 1 month", $time);

	#echo $data['start']." -> ".$data['end']."\n";

	// set URL and other appropriate options
	// grab URL and pass it to the browser

	#mv graph_$number.svgz date("Y-m", $time);
	echo "mv graph_$number.svgz ".date("Y-m", $time).".svgz\n";
	rename("graph_$number.svgz", date("Y-m", $time).".svgz");


	$time = $until;
	$number++;
}


