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

$appdetailget = Invoke-RestMethod -Uri "https://apigee.googleapis.com/v1/organizations/esi-apigee-x-394004/developers/veenakumari226@gmail.com/apps/app" -Method 'GET' -Headers $headers
$appdetailjson = $appdetailget | ConvertTo-Json
Write-Host $appdetailjson

Write-Host $appdetailget.credentials.consumerKey
Write-Host $appdetailget.credentials.consumerSecret

# $consumerkey = $appdetailget.credentials.consumerKey
# $consumersecretkey = $appdetailget.credentials.consumerSecret

# # Define the JSON data
# $jsonData = '{
#     "name": "John Doe",
#     "email": "johndoe@example.com",
#     "phone": "555-123-4567"
# }'
$jsonObject = ConvertFrom-Json $appdetailjson
Write-Host $jsonObject
Write-Host "ConsumerKey: $jsonObject.credentials.consumerkey"
Write-Host "SecretKey: $jsonObject.credentials.consumersecretkey"

# # Define an array of field names to encrypt
$fieldsToEncrypt = @("$appdetailget.credentials.consumerKey", "$appdetailget.credentials.consumerSecret")

# # Create an AES encryption object
$aes = New-Object System.Security.Cryptography.AesCryptoServiceProvider
$aes.Key = $encryptionKey
$aes.IV = $iv

# # Create a crypto stream for encryption
$encryptor = $aes.CreateEncryptor()

# Loop through the JSON object and encrypt specified fields
foreach ($field in $fieldsToEncrypt) {
    Write-Host "Entered into FOREACH..."
    $valueToEncrypt = $field

    # Convert the string to bytes
    $bytesToEncrypt = [System.Text.Encoding]::UTF8.GetBytes($valueToEncrypt)

    # Encrypt the bytes
    $encryptedBytes = $encryptor.TransformFinalBlock($bytesToEncrypt, 0, $bytesToEncrypt.Length)

    # Convert the encrypted bytes to Base64 or any other format as needed
    $encryptedValue = [System.Convert]::ToBase64String($encryptedBytes)

    # Replace the original value with the encrypted value
    $jsonObject.$field = $encryptedValue
}

# Convert the modified JSON object back to a JSON string
$encryptedJsonData = $jsonObject | ConvertTo-Json

# Write the encrypted JSON data back to the same JSON file
$encryptedJsonData | Set-Content -Path "your_output.json" -Force

# Output the encrypted JSON data
Write-Host "Encrypted JSON Data:"
Write-Host $encryptedJsonData
