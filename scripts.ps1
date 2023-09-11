$token = $env:TOKEN
$headers = @{Authorization = "Bearer $token"}

# $encryptionKey = New-Object byte[] 32  # 256 bits
# $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
# $rng.GetBytes($encryptionKey)

# $iv = New-Object byte[] 16  # 128 bits
# $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
# $rng.GetBytes($iv)

# # Make the API call to get the data
# $appdetailget = Invoke-RestMethod -Uri "https://apigee.googleapis.com/v1/organizations/esi-apigee-x-394004/developers/testexample1@gmail.com/apps/app" -Method 'GET' -Headers $headers

# # Define an array of field names to encode in Base64
# $fieldsToEncode = @("consumerKey", "consumerSecret")

# # Custom function to encode and replace property value with Base64
# function Encode-PropertyValue {
#     param (
#         [Object]$object,
#         [String]$property
#     )
#     $originalValue = $object.$property
#     $base64Value = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($originalValue))
#     $object | Add-Member -MemberType NoteProperty -Name $property -Value $base64Value -Force
# }

# # Encode and replace the fields in the JSON data with Base64
# foreach ($field in $fieldsToEncode) {
#     Encode-PropertyValue -object $appdetailget.credentials[0] -property $field
# }

# # Save the modified JSON data to a JSON file
# $appdetailget | ConvertTo-Json | Set-Content -Path "jsonfiles/base64_encoded_app.json"





# Make the API call to get the data
$appdetailget = Invoke-RestMethod -Uri "https://apigee.googleapis.com/v1/organizations/esi-apigee-x-394004/developers/testexample1@gmail.com/apps/app" -Method 'GET' -Headers $headers

# Specify the fields you want to encrypt
$fieldsToEncrypt = @("consumerKey", "consumerSecret")

# Encryption key
$keyHex = $env:key  # Replace with your encryption key

# Create a new AES object with the specified key and AES mode
$AES = New-Object System.Security.Cryptography.AesCryptoServiceProvider
$AES.KeySize = 256  # Set the key size to 256 bits for AES-256
$AES.Key = [System.Text.Encoding]::UTF8.GetBytes($keyHex.PadRight(32))
$AES.Mode = [System.Security.Cryptography.CipherMode]::CBC

# Loop through the specified fields and encrypt their values
foreach ($field in $fieldsToEncrypt) {
    $plaintext = $appdetailget.credentials[0].$field

    # Convert plaintext to bytes (UTF-8 encoding)
    $plaintextBytes = [System.Text.Encoding]::UTF8.GetBytes($plaintext)

    # Generate a random initialization vector (IV)
    $AES.GenerateIV()
    $IVBase64 = [System.Convert]::ToBase64String($AES.IV)

    # Encrypt the data
    $encryptor = $AES.CreateEncryptor()
    $encryptedBytes = $encryptor.TransformFinalBlock($plaintextBytes, 0, $plaintextBytes.Length)
    $encryptedBase64 = [System.Convert]::ToBase64String($encryptedBytes)

    # Store the encrypted value back in the JSON data
    $appdetailget.credentials[0].$field = @{
        "EncryptedValue" = $encryptedBase64
        "IV" = $IVBase64
    }
}

# Convert the modified JSON data back to JSON format
$encryptedJsonData = $appdetailget | ConvertTo-Json

# Display the modified JSON data
Write-Host $encryptedJsonData

# To save the modified JSON data to a file, uncomment and customize the following line
# $encryptedJsonData | Set-Content -Path $outputFilePath

# Decryption key (should be the same as the encryption key)
# $keyHex = $env:key  # Replace with your encryption key

# Create a new AES object with the specified key and AES mode
$AES = New-Object System.Security.Cryptography.AesCryptoServiceProvider
$AES.KeySize = 256  # Set the key size to 256 bits for AES-256
$AES.Key = [System.Text.Encoding]::UTF8.GetBytes($keyHex.PadRight(32))
$AES.Mode = [System.Security.Cryptography.CipherMode]::CBC

# Loop through the specified fields and decrypt their values
foreach ($field in $fieldsToEncrypt) {
    $encryptedData = $appdetailget.credentials[0].$field

    # Split the stored data into IV and encrypted value
    $parts = $encryptedData -split ","
    $IVBase64 = $parts[0]
    $encryptedBase64 = $parts[1]

    # Convert IV and encrypted value from Base64
    $IV = [System.Convert]::FromBase64String($IVBase64)
    $encryptedBytes = [System.Convert]::FromBase64String($encryptedBase64)

    # Create a decryptor with the same IV and key
    $decryptor = $AES.CreateDecryptor($AES.Key, $IV)

    # Decrypt the data
    $decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
    $decryptedText = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)

    # Store the decrypted value back in the JSON data
    $appdetailget.credentials[0].$field = $decryptedText
}

# Convert the modified JSON data back to JSON format
$decryptedJsonData = $appdetailget | ConvertTo-Json

# Display the modified JSON data
Write-Host $decryptedJsonData

