resource check 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'checkResource'
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: 'latest'
    retentionInterval: 'PT1H'
    scriptContent: '''
      result=$(az webapp vnet-integration list --name web-temp1 --resource-group rg-lg-temp1 --query "contains([].name, 'snet-kv-web-temp1')" -o tsv)
      echo "{\"exists\": $result}" > "$AZ_SCRIPTS_OUTPUT_PATH"
    '''
  }
}

output exists bool = check.properties.outputs.exists
