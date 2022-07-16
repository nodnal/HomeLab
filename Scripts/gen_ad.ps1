# Haven't powershell'd in a while, sorry for the mess.
param( [Parameter(Mandatory=$true)] $JSONFile)

function CreateADGroup($group){
    $existing = Get-ADGroup -Filter ('Name -eq "{0}"' -f ($group.name))
    if($existing.length -eq 0){
        try{
            New-ADGroup -name $group.name -GroupScope Global
        }
        catch{
            Write-Error "Error Adding group"
            Write-Error $group
        }
    } else {
        Write-Host ("Skipping Group: {0}, group already exists." -f $group.name)
    }
}
function CreateADUser($user){

    $username = ("{0}.{1}" -f ($user.first_name, $user.last_name)).ToLower();
    $name = "{0} {1}" -f ($user.first_name, $user.last_name)
    $samAccountName = $username;
    $principalName = "{0}.{1}" -f ($user.first_name, $user.last_name);
    $password = $user.password;
    $existing = Get-ADUser -Filter ('SamAccountName -eq "{0}"' -f $samAccountName)
    if ($existing.length) {
        try {
        New-ADUser -Name $name -GivenName $user.first_name -Surname $user.last_name -SamAccountName $samAccountName -UserPrincipalName $principalName@$Global:Domain  -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount
        } Catch{
            Write-Error "Error Creating Account"
            Write-Error $user
        }

        foreach($group in $user.groups){
            try {
                Add-ADGroupMember -Identity $group -Members $username
            }catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
                Write-Error "Error Adding User to Group, Group Doesn't Exist"
                Write-Error $group
            } catch {
                Write-Error "Unknown Error Adding User to Group"
                Write-Error $group
            }
        }
    } else{
        Write-Host ("Skipping User: {0}, user already exists." -f $name)
    }
}


$schema = ( Get-Content $JSONFile | ConvertFrom-Json)
$Global:Domain = $schema.domain

foreach ($group in $schema.groups){
    CreateADGroup($group)
}

foreach ( $user in $schema.users){
    CreateADUser($user)
}
