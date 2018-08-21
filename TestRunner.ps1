#!/usr/bin/pwsh

param(
    # job
    [Parameter(Mandatory = $true)]
    [string]
    $Job
)
$specConfigFile = Get-Content ./spec.json -Raw

$specConfig = ConvertFrom-Json $specConfigFile

$spec = $spec."$Job"

Test.ps1 $spec.testImage -Dotnet $spec.dotnet -Node $spec.node -Yarn $spec.yarn -Sdk:$spec.sdk
