#To check your UPN suffixes registered on your On-Premises AD:
Get-adforest | select UPNSuffixes
#If you have many that cannot be printed:
Get-adforest | select -ExpandProperty UPNSuffixes

$oldSuffix = "@Contoso.ca"
$NewSuffix = "@Company.ca"

#NOTE: on an On-Premises Exchange environment, you might have lots of "HealthMailbox" accounts, juste filtering these out from the Get-ADUser request
$adusers = Get-AdUser -filter * | ? {$_.Enabled -eq $True -and -not ($_.Name -match "health" -or [string]::IsNullOrEmpty($_.UserPrincipalNAme))}
#NOTE2: you can also load the AD Usrers from a Text file using $ADUsers = Get-Content .\ADUsersList.txt 

$ADUsers | FT Name, UserPrincipalName

ForEach ($usr in $ADUsers){
    #$usr = get-aduser $usr.loginid |Select userprincipalname, samaccountname
    #This will then replace the old upn with the new upn and set the attribute on each user. one by one looping through the AD users populated in the $ADUsers variable.
    $newUpn = $usr.UserPrincipalName.Replace($oldSuffix,$newSuffix)
    Set-ADUser -identity $usr.samaccountname -UserPrincipalName $newUpn -Verbose -Debug -Confirm:$false
}

$ADusers | ft Name,SAmAccountName,UserPrincipalName,*email*
