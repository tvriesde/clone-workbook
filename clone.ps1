$rgdev = 'workbook-test-dev'
$rgprod = 'workbook-test-prod'


#get workbook from dev
$devworkbooks = az monitor app-insights workbook list -g $rgdev --category workbook --can-fetch-content yes | ConvertFrom-Json

#production deployment
foreach($item in $devworkbooks) { 
    $displayNameProduction = $item.displayName + '-prd'
    $nameProduction =  '00000000-0000-0000-0000-000000000003'
    $sourceid = 'azure monitor'
    $serializedDataJSON = $item.serializedData | ConvertTo-Json

    #check if exists
    $exists = $false
    $prdWorkbook =  az monitor app-insights workbook show --name $nameProduction -g $rgprod| ConvertFrom-Json
    if($prdWorkbook -ne $null){
        $exists = $true
    }

    if($exists -eq $false){
        #create workbook
        Write-Host "=> Create Workbook in Production environment"
        az monitor app-insights workbook create --name $nameProduction --source-id $sourceid --display-name $displayNameProduction --serialized-data $serializedDataJSON --resource-group $rgprod --kind $item.kind --version $item.version --category workbook
    } else {
        #update workbook
        Write-Host "=> Update workbook in Production environment"  
        az monitor app-insights workbook update --name $nameProduction --display-name $displayNameProduction --source-id $sourceid --serialized-data $serializedDataJSON --resource-group $rgprod --kind $item.kind --version $item.version --category workbook
    }
}