# write-output Apigee Artifacts
$token = $env:TOKEN
$org = $env:ORG
$baseURL = "https://apigee.googleapis.com/v1/organizations/"
$headers = @{Authorization = "Bearer $token"}

# # Set your GitHub repository information
# $repositoryOwner = "rajeshjanapati@gmail.com"
# $repositoryName = "apigee-encrypt-keys"
# $branchName = "main"  # Change this to the branch you want to access
# $githubToken = "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"

# # Import the cryptographic module
# Import-Module Microsoft.PowerShell.Security

$encryptionKey = New-Object byte[] 32  # 256 bits
$rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
$rng.GetBytes($encryptionKey)

$iv = New-Object byte[] 16  # 128 bits
$rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
$rng.GetBytes($iv)

# Make the API call to get the data
$appdetailget = Invoke-RestMethod -Uri "https://apigee.googleapis.com/v1/organizations/esi-apigee-x-394004/developers/testexample1@gmail.com/apps/app" -Method 'GET' -Headers $headers

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

# Save the modified JSON data to a JSON file
Write-host "Encrypted data: ($appdetailget | ConvertTo-Json)"
$appdetailget | ConvertTo-Json | Set-Content -Path "jsonfiles/base64_encoded_app.json"
