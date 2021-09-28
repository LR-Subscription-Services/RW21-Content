# 1.  Set the data retrieval.  
# This is an exmample leveraging a CSV document of endangered species as a Proof of Concept
$CSVFile = 'C:\Users\Eric.Hart\OneDrive - LogRhythm, Inc\Team Internal\TAM\Resources\EricH\RW21\EndangeredAnimals.csv'

# 2. Set the Destination URL for OpenCollector's Webhook Beat
$OCEndpoint = "http://10.6.0.66:443/webhook"

# 3. Setting the LogSource Name.  This can be leveraged for Log Source Virtualization.
$FQBN = "Webhook_CSV_ESpecies"

# 4. Map source data to LogRhythm Metadata.
# Note for CSV you can align the column headers to the LogRhythm Metadata fields as an option, or accomplish a similar method as applied in the Invoke-APItoOC.ps1 example.
$CSVContent = Get-Content -Path $CSVFile | Select-Object -Skip 1 | ConvertFrom-Csv -Header serialnumber, policy, result, objecttype, useragent, objectname, object, login, "command", status, session_type, amount, "process", subject

ForEach ($CSVLine in $CSVContent) {
    # 4.2. Required - This value, whsdp, is the magic key that enables the Source Defined Parser augmentation.
    $CSVLine | Add-Member -MemberType NoteProperty -Name 'whsdp' -Value $true -Force

    # 4.3. Optional - If the log source provider does not include a timestamp, you can generate your own. 
    $CSVLine | Add-Member -MemberType NoteProperty -Name 'timestamp.iso8601' -Value $(Get-Date (Get-Date).ToUniversalTime() -UFormat '+%Y-%m-%dT%H:%M:%S.00Z') -Force

    # 4.4. Optional - This line assigns the value we specified on Step #3.
    $CSVLine | Add-Member -MemberType NoteProperty -Name 'fullyqualifiedbeatname' -Value $FQBN -Force    

    # This line is responsible for sending the data mapped log (OCLog) to the defined OpenCollector Endpoint
    Invoke-RestMethod -Method 'post' -Uri $OCEndpoint -Body $($CSVLine | ConvertTo-Json) | Out-Null
}