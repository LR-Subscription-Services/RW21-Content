
# 1.  Set the data retrieval.  
# This is an exmample leveraging a RestAPI endpoint to retrieve a listing of endangered species as a Proof of Concept
$Results = Invoke-RestMethod -Uri 'http://apiv3.iucnredlist.org/api/v3/species/page/0?token='

# 2. Set the Destination URL for OpenCollector's Webhook Beat
$OCEndpoint = "http://10.6.0.66:443/webhook"

# 3. Setting the LogSource Name.  This can be leveraged for Log Source Virtualization.
$FQBN = "Webhook_API_ESpecies"

# 4. Map source data to LogRhythm Metadata
ForEach ($Result in $Results.result) {
    # 4.1. Required - Assign the Results JSON field to the LogRhythm Metadata field mapping.
    $OCLog = [PSCustomObject]@{
        serialnumber = $Result.taxonid
        policy = $Result.kingdom_name 
        result = $Result.phylum_name
        objecttype = $Result.class_name
        useragent = $Result.order_name
        objectname = $Result.family_name
        object = $Result.genus_name
        login = $Result.scientific_name
        command = $Result.taxonomic_authority
        status = $Result.infra_rank
        session_type = $Result.infra_name
        amount = $Result.population
        process = $Result.category
        subject = $Result.main_common_name

        # 4.2. Required - This value, whsdp, is the magic key that enables the Source Defined Parser augmentation.
        whsdp = $true

        # 4.3. Optional - If the log source provider does not include a timestamp, you can generate your own. 
         
        "timestamp.iso8601" = $(Get-Date (Get-Date).ToUniversalTime() -UFormat '+%Y-%m-%dT%H:%M:%S.00Z')
        # 4.4. Optional - This line assigns the value we specified on Step #3.
        fullyqualifiedbeatname = $FQBN
    }

    # This line is responsible for sending the data mapped log (OCLog) to the defined OpenCollector Endpoint
    Invoke-RestMethod -Method 'post' -Uri $OCEndpoint -Body $($OCLog | ConvertTo-Json) | Out-Null
}