$wwyltdt = Read-Host -Prompt "What would you like to do today?
1: Create and move SSH Keys to Linux Hosts
2: Move SSH Keys to Linux Host
"

function GatherLoginData {
    $global:LinuxHost = Read-Host -Prompt "What is your host IP or Hostname?"
    $global:username = Read-Host -Prompt "What is the username for this Linux Server?"
}

function GatherPassPhrase {
    $passphrase = Read-Host -Prompt "What passphrase would you like?" -AsSecureString
    $global:unsecurePassphrase = (New-Object PSCredential 0, $passphrase).GetNetworkCredential().Password
}

function CreateandMove {
    param(
        $LinuxHost,
        $username,
        $unsecurePassphrase
    )

    if (Test-Path $env:USERPROFILE\.ssh\id_rsa.pub) {
        $CAMOptions = Read-Host -Prompt "You already have a key, would you like to overwrite that key? or just copy that key?
        1: Overwrite your current SSH keys and copy
        2: Copy that key without creating a new one"
    }
    elseif (!(Test-Path $env:USERPROFILE\.ssh\id_rsa.pub)) {
        Write-Host "Creating key and moving $global:username $global:LinuxHost $global:unsecurePassphrase"
        ssh-keygen.exe -N "$global:unsecurePassphrase" -t "ecdsa" -q -f $env:USERPROFILE\.ssh\id_rsa
        Get-Content $env:USERPROFILE\.ssh\id_rsa.pub | ssh $username@$LinuxHost "cat >> .ssh/authorized_keys"
    }
    else {
        Write-Output "You did not enter a correct option"
    }
    if ($CAMOptions -eq "1") {
        ssh-keygen.exe -N "$global:unsecurePassphrase" -t "ecdsa" -q -f $env:USERPROFILE\.ssh\id_rsa
        Get-Content $env:USERPROFILE\.ssh\id_rsa.pub | ssh $global:username@$global:LinuxHost "cat >> .ssh/authorized_keys"
    }
    elseif ($CAMOptions -eq "2") {
        Get-Content $env:USERPROFILE\.ssh\id_rsa.pub | ssh $username@$LinuxHost "cat >> .ssh/authorized_keys"
    }

}

function MoveSSHKeys {
    param(
        $LinuxHost,
        $username
    )
    if (!(Test-Path $env:USERPROFILE\.ssh\id_rsa.pub)) {
        Write-Output "You do not have an SSH key, re-run the script and select option 1"
        Break;
    }
    Get-Content $env:USERPROFILE\.ssh\id_rsa.pub | ssh $global:username@$global:LinuxHost "cat >> .ssh/authorized_keys"

}

if ($wwyltdt -eq "1") {
    GatherLoginData
    GatherPassPhrase
    CreateandMove -LinuxHost $LinuxHost -username $username -unsecurePassphrase $UnsecurePassword
}
elseif ($wwyltdt -eq "2") {
    GatherLoginData
    MoveSSHKeys -LinuxHost $LinuxHost -username $username
}
else {
    Write-Output "You did not select a correct option, pick again"
    break;
}

