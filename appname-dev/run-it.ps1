#Login-AzureRmAccount
#$PSVersionTable.PSVersion
[CmdletBinding(SupportsShouldProcess = $true)]
param(

    # The name of resource group
    [Parameter(Mandatory = $false)]
    [string]$resourcegroup = "dev-fhn-sandpit-rg",
    # The name of sql server deployment
    [Parameter(Mandatory = $false)]
    [string]$sqldeploymentname = "deployment",
    
    # The name of file for ARM template for sql server deployment
    [Parameter(Mandatory = $false)]
    [string]$lrTemplatefile_keyvault = "..\arm_templates\key_vault\azuredeploy.json",
    # The name of file for ARM template parameter for sql server deployment
    [Parameter(Mandatory = $false)]
    [string]$lrTemplateparameterfile_keyvault = "key_vault\azuredeploy.parameters.json",


    # The name of file for ARM template for sql server deployment
    [Parameter(Mandatory = $false)]
    [string]$lrTemplatefile_storage_a_c = "..\arm_templates\storage_a_c\azuredeploy.json",
    # The name of file for ARM template parameter for sql server deployment
    [Parameter(Mandatory = $false)]
    [string]$lrTemplateparameterfile_storage_a_c = "storage_a_c\azuredeploy.parameters.json",


    # The name of file for ARM template for sql server deployment
    [Parameter(Mandatory = $false)]
    [string]$lrTemplatefile_sqlserver = "..\arm_templates\sql_server\azuredeploy.json",
    # The name of file for ARM template parameter for sql server deployment
    [Parameter(Mandatory = $false)]
    [string]$lrTemplateparameterfile_sqlserver = "sql_server\azuredeploy.parameters.json",


    # The name of file for ARM template for sql server deployment
    [Parameter(Mandatory = $false)]
    [string]$lrTemplatefile_sql_server_managed_instance = "..\arm_templates\sql_server_managed_instance\azuredeploy.json",
    # The name of file for ARM template parameter for sql server deployment
    [Parameter(Mandatory = $false)]
    [string]$lrTemplateparameterfile_sql_server_managed_instance = "sql_server_managed_instance\azuredeploy.parameters.json",

   
    
    # The true/false value for validate the templates
    [Parameter(Mandatory = $false)]
    [switch] $ValidateOnly
)


$lrTemplatefile_keyvault = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $lrTemplatefile_keyvault))
$lrTemplateparameterfile_keyvault = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $lrTemplateparameterfile_keyvault))

$lrTemplatefile_storage_a_c = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $lrTemplatefile_storage_a_c))
$lrTemplateparameterfile_storage_a_c = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $lrTemplateparameterfile_storage_a_c))

$lrTemplatefile_sqlserver = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $lrTemplatefile_sqlserver))
$lrTemplateparameterfile_sqlserver = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $lrTemplateparameterfile_sqlserver))

$lrTemplatefile_sql_server_managed_instance = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $lrTemplatefile_sql_server_managed_instance))
$lrTemplateparameterfile_sql_server_managed_instance = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $lrTemplateparameterfile_sql_server_managed_instance))


try {
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(' ', '_'), '3.0.0')
}
catch { }
$ErrorActionPreference = 'Stop'
$ErrorMessages = ''
Set-StrictMode -Version 3
function Format-ValidationOutput {
    param ($ValidationOutput, [int] $Depth = 0)
    Set-StrictMode -Off
    return @($ValidationOutput | Where-Object { $_ -ne $null } | ForEach-Object { @('  ' * $Depth + ': ' + $_.Message) + @(Format-ValidationOutput @($_.Details) ($Depth + 1)) })
}

if ($ValidateOnly) {
    $ErrorMessages = Format-ValidationOutput (Test-AzResourceGroupDeployment -ResourceGroupName $resourcegroup `
            -TemplateFile $lrTemplatefile_keyvault `
            -TemplateParameterFile $lrTemplateparameterfile_keyvault)

    $ErrorMessages = Format-ValidationOutput (Test-AzResourceGroupDeployment -ResourceGroupName $resourcegroup `
            -TemplateFile $lrTemplatefile_storage_a_c `
            -TemplateParameterFile $lrTemplateparameterfile_storage_a_c)

    $ErrorMessages = Format-ValidationOutput (Test-AzResourceGroupDeployment -ResourceGroupName $resourcegroup `
            -TemplateFile $lrTemplatefile_sqlserver `
            -TemplateParameterFile $lrTemplateparameterfile_sqlserver)

    $ErrorMessages = Format-ValidationOutput (Test-AzResourceGroupDeployment -ResourceGroupName $resourcegroup `
            -TemplateFile $lrTemplatefile_sql_server_managed_instance `
            -TemplateParameterFile $lrTemplateparameterfile_sql_server_managed_instance )

    if ($ErrorMessages) {
        Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
    }
    else {
        Write-Output '', 'Template is valid.'
    }
}
else {



    Write-Output 'Start the 1st deployment to create sql server and database instances'
    New-AzResourceGroupDeployment -Name ($sqldeploymentname + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
        -ResourceGroupName $resourcegroup `
        -TemplateFile $lrTemplatefile_keyvault `
        -TemplateParameterFile $lrTemplateparameterfile_keyvault `
        -Force -Verbose

    
    Write-Output 'Start the 1st deployment to create sql server and database instances'
    New-AzResourceGroupDeployment -Name ($sqldeploymentname + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
        -ResourceGroupName $resourcegroup `
        -TemplateFile $lrTemplatefile_storage_a_c `
        -TemplateParameterFile $lrTemplateparameterfile_storage_a_c `
        -Force -Verbose


    Write-Output 'Start the 1st deployment to create sql server and database instances'
    New-AzResourceGroupDeployment -Name ($sqldeploymentname + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
        -ResourceGroupName $resourcegroup `
        -TemplateFile $lrTemplatefile_sqlserver `
        -TemplateParameterFile $lrTemplateparameterfile_sqlserver `
        -Force -Verbose


    Write-Output 'Start the 1st deployment to create sql server and database instances'
    New-AzResourceGroupDeployment -Name ($sqldeploymentname + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
        -ResourceGroupName $resourcegroup `
        -TemplateFile $lrTemplatefile_sql_server_managed_instance `
        -TemplateParameterFile $lrTemplateparameterfile_sql_server_managed_instance `
        -Force -Verbose


}