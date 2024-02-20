#This script will attempt to copy all records between two PrivateLink DNS zones in different subscriptions

param(
    [string]$sourceSubscriptionId,
    [string]$destinationSubscriptionId,
    [string]$zoneName,
    [string]$sourceResourceGroupName,
    [string]$destinationResourceGroupName
)


# Define source and destination subscriptions
#$sourceSubscriptionId = "68240cd6-27b6-4706-807f-be8271824764"
#$destinationSubscriptionId = "66a2e49c-f575-4674-980e-4ac60d31f490"

# Define the Azure Private DNS zone details
#$zoneName = "privatelink.afs.azure.net"
#$sourceresourceGroupName = "rg-cfsorage-dev1"
#$destinationresourceGroupName ="rg-privatelinkdnszones-cacen-01"

# Set the context to the source subscription
Set-AzContext -SubscriptionId $sourceSubscriptionId

# Get all DNS records from the source zone
$records = Get-AzPrivateDnsRecordSet -ZoneName $zoneName -ResourceGroupName $sourceresourceGroupName

# Set the context to the destination subscription
Set-AzContext -SubscriptionId $destinationSubscriptionId

foreach ($record in $records) {
    $recordName = $record.Name
    $recordType = $record.RecordType
    $ttl = $record.Ttl

    $recordConfigs = @()
    foreach ($r in $record.Records) {
        $recordConfigs += New-AzPrivateDnsRecordConfig -Ipv4Address $r.Ipv4Address
    }

    $recordSetParams = @{
        "Name"            = $recordName
        "ZoneName"        = $zoneName
        "ResourceGroupName" = $destinationresourceGroupName
        "RecordType"      = $recordType
        "Ttl"             = $ttl
        "PrivateDNsRecords"    = $recordConfigs
    }

    New-AzPrivateDnsRecordSet @recordSetParams
}

Write-Output "DNS records copied successfully from source to destination."
