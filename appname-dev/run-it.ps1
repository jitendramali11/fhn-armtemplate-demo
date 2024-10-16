#Login-AzureRmAccount
#$PSVersionTable.PSVersion
[CmdletBinding(SupportsShouldProcess = $true)]
param(

    # The name of resource group
    [Parameter(Mandatory = $false)]
    [string]$resourcegroup = "lr-digitalplatform-sandpit-rg",
    # The name of sql server deployment
    [Parameter(Mandatory = $false)]
    [string]$sqldeploymentname = "sql_deployment",
    # The name of file for ARM template for sql server deployment
    [Parameter(Mandatory = $false)]
    [string]$lrTemplatefile_sqlserver = "..\arm_templates\sql_server_audit\azuredeploy.json",
    # The name of file for ARM template parameter for sql server deployment
    [Parameter(Mandatory = $false)]
    [string]$lrTemplateparameterfile_sqlserver = "sql_server\azuredeploy.parameters.json",
    # The name of file for ARM template for web/api app server deployment
    [Parameter(Mandatory = $false)]
    [string]$lrTemplatefile_apiapps = "..\arm_templates\webapps_noslots\azuredeploy.json",
    
    # The true/false value for validate the templates
    [Parameter(Mandatory = $false)]
    [switch] $ValidateOnly
)


$lrTemplatefile_sqlserver = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $lrTemplatefile_sqlserver))
$lrTemplateparameterfile_sqlserver = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $lrTemplateparameterfile_sqlserver))


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
            -TemplateFile $lrTemplatefile_sqlserver `
            -TemplateParameterFile $lrTemplateparameterfile_sqlserver )

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
        -TemplateFile $lrTemplatefile_sqlserver `
        -TemplateParameterFile $lrTemplateparameterfile_sqlserver `
        -Force -Verbose


}