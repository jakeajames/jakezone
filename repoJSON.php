<?php

function curlIT($url, $file)
{
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url . "/" . $file);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    $headers = array(
        "Accept: */*",
        "X-Machine: iPad5,3",
        "X-Firmware: 11.1.2",
        "User-Agent: Telesphoreo APT-HTTP/1.0.592", /*user agent*/
        "Accept-Language: en-us",
        "X-Unique-ID: 1234567890123456789012345678901234567890", /*dummy udid*/
        "Accept-Encoding: gzip, deflate"
    );
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    $result = curl_exec($ch);
    curl_close($ch);
    return $result;
}

header("Content-Type: text/plain");
$repoURL = $_GET["repo"];
$packs = explode("\n\n", curlIT($repoURL, "Packages")); //get the Packages file
$infos = explode("\n", curlIT($repoURL, "Release")); //repo info
echo "{\n";

foreach($infos as $info)
{
    $keyvalue = explode(": ", $info); //divide the info entries
    $i = 0;
    foreach($keyvalue as $kv)
    {
        if ($i % 2 == 0)
        {
            if ($kv != "" && $kv != " ")
            {
                echo '    "' . $kv . '":"';
            }
        }
        else
        {
            if ($kv != "" && $kv != " ")
            {
                echo $kv . "\",\n";
            }
        }

        $i = $i + 1;
    }
}

echo "    \"packages\":[\n";
$count = count($packs);

//too lazy to explain this, the code is a mess

foreach($packs as $pack)
{
    if (--$count <= 0)
    {
        break;
    }

    $i = 0;
    echo "        {\n";
    $packsinfo = explode("\n", $pack);
    $countpck = count($packsinfo);
    foreach($packsinfo as $packinfo)
    {
        $countpck--;
        $packsinfokv = explode(": ", $packinfo);
        for ($j = 0; $j < count($packsinfokv); $j++)
        {
            if ($i % 2 == 0)
            {
                echo '            "' . $packsinfokv[$j] . '":"';
            }
            elseif ($i % 2 != 0 && $countpck != 0)
            {
               if (strpos($packsinfokv[$j+1], " ") || strpos($packsinfokv[$j+1], ":") || strpos($packsinfokv[$j+1], "-") || strpos($packsinfokv[$j+1], "+") || strpos($packsinfokv[$j+1], "=") || strpos($packsinfokv[$j+1], "'") || strpos($packsinfokv[$j+1], '"')){
                //if the package description contains ": " then it will mess it up
                //we need to fix that by checking if the next value contains any of these characters (and normally it shouldn't)
                //ctype_alpha does not work
                {
                    $i--; //go back
                    echo $packsinfokv[$j] . ": "; //fix
                }
                else
                {
                    if ($packsinfokv[$j - 1] == "Filename")
                    {
                        echo str_replace("//", "/", $repoURL . "/" . $packsinfokv[$j]) . "\",\n";
                    }
                    else
                    {
                        echo $packsinfokv[$j] . "\",\n";
                    }
                }
            }
            else
            {
                echo $packsinfokv[$j] . "\"\n";
            }

            $i = $i + 1;
        }
    }

    if ($count == 1)
    {
        echo "        }\n";
    }
    else
    {
        echo "        },\n";
    }
}

echo "\n    ]";
echo "\n}\n";
?>
