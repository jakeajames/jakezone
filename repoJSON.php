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
        "User-Agent: Telesphoreo APT-HTTP/1.0.592",
        "Accept-Language: en-us",
        "X-Unique-ID: 1234567890123456789012345678901234567890",
        "Accept-Encoding: gzip, deflate"
    );
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    $result = curl_exec($ch);
    curl_close($ch);
    return $result;
}

header("Content-Type: text/plain");
$repoURL = $_GET["repo"];
$packs = explode("\n\n", curlIT($repoURL, "Packages"));
$infos = explode("\n", curlIT($repoURL, "Release"));
echo "{\n";

foreach($infos as $info)
{
    $keyvalue = explode(": ", $info);
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
                if (!ctype_alpha($packsinfokv[$j + 1]))
                {
                    $i--;
                    echo $packsinfokv[$j] . ": ";
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
