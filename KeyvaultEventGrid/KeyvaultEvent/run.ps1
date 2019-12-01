param($eventGridEvent, $TriggerMetadata)


try {
    if ($eventGridEventObject.eventType -eq "Microsoft.KeyVault.SecretExpired") {

        $NewExpirationDate = (Get-Date).AddDays(30)

        $InputArray= ([char[]]([char]33..[char]95) + [char[]]([char]97..[char]126)) 
        
        $GeneratedPassword = ConvertTo-SecureString ((Get-Random -Count 26 -InputObject ([char[]]$InputArray)) -join '') -AsPlainText -Force
        
        Set-AzKeyVaultSecret -VaultName $eventGridEventObject.data.vaultName -name $eventGridEventObject.data.objectName  -SecretValue $GeneratedPassword  -Expires $NewExpirationDate

        $logData = @{ 
            "VaultName" = $eventGridEventObject.data.vaultName
            "partitionKey" = "vaultlog"
            "SecretName" = $eventGridEventObject.data.objectName
            "SecretChangeDate"= Get-Date
            "rowKey" = (new-guid).guid 
        }
        
        Push-OutputBinding -Name keyvaultlogtable -Value $logData
    }
}
catch {
    Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
}

