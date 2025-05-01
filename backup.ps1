# Variables
$resourceGroup = "RezumiiV_group"
$serverName = "rezumii"
$databaseName = "rezumii-database"
$storageAccountName = "iposdatabackup"
$storageContainer = "assests"
$bacpacFileName = "$databaseName-$(Get-Date -Format yyyyMMdd).bacpac"
$localDownloadPath = "C:\Users\Ifeanyi\Documents\database-backup\$bacpacFileName"
$adminLogin = "rezumiis"
$adminPassword = "Rezumii1245"

# Get storage context
$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -Name $storageAccountName)[0].Value
$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey

# Export to Azure Storage
$exportStatus = New-AzSqlDatabaseExport `
    -ResourceGroupName $resourceGroup `
    -ServerName $serverName `
    -DatabaseName $databaseName `
    -StorageKeytype "StorageAccessKey" `
    -StorageKey $storageKey `
    -StorageUri "https://$storageAccountName.blob.core.windows.net/$storageContainer/$bacpacFileName" `
    -AdministratorLogin $adminLogin `
    -AdministratorLoginPassword (ConvertTo-SecureString -String $adminPassword -AsPlainText -Force)

Write-Output "Export operation started. Status link: $($exportStatus.OperationStatusLink)"
Write-Output "Waiting 5 minutes for export to complete..."
Start-Sleep -Seconds 300

# Download the .bacpac file to local machine
Get-AzStorageBlobContent `
    -Container $storageContainer `
    -Blob $bacpacFileName `
    -Destination $localDownloadPath `
    -Context $storageContext

Write-Output "Backup completed: $localDownloadPath"
