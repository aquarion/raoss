<?PHP
header("Content-Type: text/xml");
echo '<?xml version="1.0" encoding="UTF-8"?>';
include('.lib/id3/getid3/getid3.lib.php');
include('.lib/id3/getid3/getid3.php');

$getID3 = new getid3;

$title   = 'Your Podcast Title here';
$desc    = 'Your description';
$baseref = 'http://yourhost/yourpath/podcast';  // path where this script is.


$icon    = 'http://yourhost/yourpath/icon.jpg'; // url of icon
$abouturl= 'http://yourhost/yourpath/';         // A page about your podcast 


echo <<<EOW
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
    <channel>
        <!-- begin RSS 2.0 tags -->
        <title>$title</title>
        <link>$abouturl</link>
        <language>en-us</language>

        <description>$desc</description>
        <ttl>720</ttl>
EOW;


if ($icon){
echo <<<EOW
        <image>
            <url>$icon</url>
            <title>$title</title>

            <link>$abouturl</link>
            <width>100</width>
            <height>100</height>
        </image>
        
EOW;
}

$item = <<<EOW
        <item>
            <!-- begin RSS 2.0 tags -->
            <title>%s</title>

            <guid>%s</guid>
            <pubDate>%s</pubDate>
            <author>nicholas@aquarionics.com</author>
            <link>%s</link>
            <enclosure url="%s" length="%s" type="%s" />

            <description>%s</description>
            <!-- end RSS 2.0 tags -->
        </item>
EOW;

$dir  ='./';

if (is_dir($dir)) {
    if ($dh = opendir($dir)) {
        while (($file = readdir($dh)) !== false) {
	    if($file[0] == '.' || $file == "index.php"){
		continue;
	    }
	    $idthree = $getID3->analyze($dir.$file);
            getid3_lib_sigh::CopyTagsToComments($idthree);
	    $url = 'http://cenote.gkhs.net/~aquarion/podcast/'.$file;
            $filesize = filesize($dir.$file);
	    $filetype = mime_content_type($dir.$file);
	    $desc = $title = $idthree['comments']['artist'][0].' '.$idthree['comments']['title'][0];
	    $title = trim($title);	
	    if(empty($title)){
		$title = 'Untitled Thing';
		}
            printf($item, $title, $url, date('r'), $url, $url, $filesize, $filetype, $desc);
        }
        closedir($dh);
    }
}

echo <<<EOW
    </channel>
</rss>
EOW;
