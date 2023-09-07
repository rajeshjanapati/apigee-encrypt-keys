# write-output Apigee Artifacts
$token = $env:TOKEN
$org = $env:ORG
$baseURL = "https://apigee.googleapis.com/v1/organizations/"
$headers = @{Authorization = "Bearer $token"}

# Set your GitHub repository information
$repositoryOwner = "rajeshjanapati@gmail.com"
$repositoryName = "apigee-encrypt-keys"
$branchName = "main"  # Change this to the branch you want to access
$githubToken = "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"

# Import the cryptographic module
Import-Module Microsoft.PowerShell.Security

# # Define the encryption key and initialization vector (IV)
# $encryptionKey = [System.Text.Encoding]::UTF8.GetBytes("YourEncryptionKey")
# $iv = [System.Text.Encoding]::UTF8.GetBytes("YourInitializationVector")

$encryptionKey = New-Object byte[] 32  # 256 bits
$rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
$rng.GetBytes($encryptionKey)

$iv = New-Object byte[] 16  # 128 bits
$rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
$rng.GetBytes($iv)

# Make the API call to get the data
$appdetailget = Invoke-RestMethod -Uri "https://apigee.googleapis.com/v1/organizations/esi-apigee-x-394004/developers/veenakumari226@gmail.com/apps/app" -Method 'GET' -Headers $headers

# Define an array of field names to encode in Base64
$fieldsToEncode = @("consumerKey", "consumerSecret")

# Custom function to encode and replace property value with Base64
function Encode-PropertyValue {
    param (
        [Object]$object,
        [String]$property
    )
    $originalValue = $object.$property
    $base64Value = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($originalValue))
    $object | Add-Member -MemberType NoteProperty -Name $property -Value $base64Value -Force
}

# Encode and replace the fields in the JSON data with Base64
foreach ($field in $fieldsToEncode) {
    Encode-PropertyValue -object $appdetailget.credentials[0] -property $field
}

# Clone the repository
git clone https://github.com/rajeshjanapati/apigee-encrypt-keys.git
# cd apigee-encrypt-keys

# Save the modified JSON data to a JSON file
Write-host "Encrypted data: ($appdetailget | ConvertTo-Json)"
$appdetailget | ConvertTo-Json | Set-Content -Path "jsonfiles/base64_encoded_app.json"


# # # Create a crypto stream for encryption
# $encryptor = $aes.CreateEncryptor()

# # Loop through the JSON object and encrypt specified fields
# foreach ($field in $fieldsToEncrypt) {
#     Write-Host "Entered into FOREACH..."
#     $valueToEncrypt = $field

#     # Convert the string to bytes
#     $bytesToEncrypt = [System.Text.Encoding]::UTF8.GetBytes($valueToEncrypt)

#     # Encrypt the bytes
#     $encryptedBytes = $encryptor.TransformFinalBlock($bytesToEncrypt, 0, $bytesToEncrypt.Length)

#     # Convert the encrypted bytes to Base64 or any other format as needed
#     $encryptedValue = [System.Convert]::ToBase64String($encryptedBytes)

#     # Replace the original value with the encrypted value
#     $jsonObject.$field = $encryptedValue
# }

# # Convert the modified JSON object back to a JSON string
# $encryptedJsonData = $jsonObject | ConvertTo-Json

# # Write the encrypted JSON data back to the same JSON file
# $encryptedJsonData | Set-Content -Path "your_output.json" -Force

# # Output the encrypted JSON data
# Write-Host "Encrypted JSON Data:"
# Write-Host $encryptedJsonData
