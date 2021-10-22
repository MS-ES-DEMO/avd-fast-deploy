
function randomPassword {

    $charlist = [char]94..[char]126 + [char]65..[char]90 + [char]47..[char]57
    # All uppercase and lowercase letters, all numbers and some special characters. 
   
    # Built in parameters from a native PowerShell cmdlet.
    $PwdLength = Get-Random -Minimum 20 -Maximum 32

    #Create a new empty array to store the list of random characters 
    $pwdList = @()
    
    # Use a FOR loop to pick a character from the list one time for each count of the password length
    For ($i = 0; $i -lt $pwlength; $i++) {
    $pwdList += $charList | Get-Random
    }
    
    # Join all the individual characters together into one string using the -JOIN operator
    $pass = -join $pwdList

    $charlist = [char]94..[char]126 + [char]65..[char]90 +  [char]47..[char]57
    $pwLength = (1..10 | Get-Random) + 24  
    $pwdList = @()
    For ($i = 0; $i -lt $pwlength; $i++) {
    $pwdList += $charList | Get-Random
    }
    $pass = -join $pwdList
    return $pass
}
 
$myPassword = randomPassword
$myPassword
