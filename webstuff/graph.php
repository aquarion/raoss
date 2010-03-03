<?PHP
/*include("../include/library.php");

*/

#@TITLE=Grapher
#@DESC=Draw graphs of tab-seperated values

#header("Content-type: text/plain");
/* Set up data */
$data = array();
$max = 0;
if ($file = file("../logs/mailbox-spam.log")){
	foreach ($file as $line){
		$row = explode(",",$line);
		$row[1] = rtrim($row[1]);
		if ($row[1] > $max){
			$max = $row[1];
		}
		$data[] = $row;
	}
} else {
	die("Couldn't open file: ".$file);
}

/* Set up image */
$imWidth = 480;
$imHeight = 320;

$border=10;

$graphWidth = $imWidth - $border;
$graphHeight = $imHeight - $border - 30;

$myImage = ImageCreate($imWidth, $imHeight);

$white = ImageColorAllocate($myImage, 255, 255, 255);
$black = ImageColorAllocate($myImage, 0, 0, 0);
$lightgrey = ImageColorAllocate($myImage, 220, 220, 220);
$grey = ImageColorAllocate($myImage, 200, 200, 200);
$blue = ImageColorAllocate($myImage, 0, 0, 255);
$black = ImageColorAllocate($myImage, 0, 0, 0);
$background = ImageColorAllocate($myImage, 240, 240, 240);


ImageFill($myImage, 0, 0, $background);
Imageinterlace($myImage, 1);


$width = (($graphWidth-$border)/count($data)) - 1;
$i = $border;

$base = $border + $graphHeight;
$top = $border;
$left = $border;
$right = $graphWidth;

imageline ($myImage, $left, $base - $unit, $right, $base - $unit, $black);
imagerectangle ($myImage, $left, $top, $right, $base, $black);


$maximum = $max;
#$size = 0-(strlen($max)-1);
#$max = round($max+($max/2),-2);


$max = round(ceil($max/100)) * 100;

$size = $graphHeight/$max;

$currentleft = $left;
$currentup = $base;
$width = ($graphWidth-$border)/(count($data)-1);

/* feed data to image */

$lastdate = "1981-01-26";


#imageline ($myImage, $left, $max, $right, $max, $black);

for ($i = 0; $i <= $max; $i += ($max/10)) {
	#echo $i."<br>";
    imageline ($myImage, $left, $base - ($i*$size), $right, $base - ($i*$size), $grey);
	imagestring ($myImage, 3, $left, $base - ($i*$size), $i, $grey);
}

$even = true;

foreach ($data as $index => $datum){

	if (date("YW",strtotime($datum[0])) >  date("YW",strtotime($lastdate))){
		imageline ($myImage, $currentleft, $base, $currentleft, $top, $lightgrey);
		if ($even){
			$even = false;
			$height = $top+17;
		} else {
			$even = true;
			$height = $top+27;
		}
		imagestring ($myImage, 3, $currentleft, $height, "W".date("W",strtotime($datum[0])), $grey);
	}
	if (date("Ym",strtotime($datum[0])) >  date("Ym",strtotime($lastdate))){
		imagestring ($myImage, 3, $currentleft, $base+10, date("M",strtotime($datum[0])), $blue);	
		imageline ($myImage, $currentleft, $base, $currentleft, $top, $grey);
	}
	if (date("Y",strtotime($datum[0])) >  date("Y",strtotime($lastdate))){
		imagestring ($myImage, 3, $currentleft, $base, date("Y",strtotime($datum[0])), $blue);	
		imageline ($myImage, $currentleft, $base, $currentleft, $top, $grey);
	}
	
	
	if ($index != 0){
		$fromx = $currentleft;
		$fromy = $currentup;
		$tox = $currentleft+$width;
		$toy = $base - $datum[1]*$size;
		imageline ($myImage, $fromx, $fromy, $tox, $toy, $black);
		if ($datum[1] == $maximum){
			imagestring ($myImage, 3, $tox, $toy, $datum[1], $blue);	
		}
		#echo "From ".$fromx."/".$fromy." to ". $tox ."/". $toy."<br>\n";
		$currentleft += $width;
		$currentup = $toy;
	} else {
		$currentup = $base - $datum[1];
	}
	// If current year is greater than year of lastdate, show label
	// if current month is blah blah as above.


	$lastdate = $datum[0];
}

imagestring ($myImage, 3, $left+150, $top - 10, "aq@gkhs.net: Spam over time", $black);	
imagestring ($myImage, 3, $left+100, $top + 3, "(Note, mailserver was offline 04-01 -> 05-15", $black);	
header("Content-type: image/png");
Imagepng($myImage);
Imagedestroy($myImage); 
?>
