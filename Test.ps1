#!/usr/bin/pwsh

param(
    # image name
    [Parameter(Mandatory = $true)]
    [string]
    $Image,
    # dotnet version
    [Parameter(Mandatory = $true)]
    [string]
    $Dotnet,
    # Node version
    [Parameter(Mandatory = $true)]
    [string]
    $Node,
    # Yarn Version
    [Parameter(Mandatory = $true)]
    [string]
    $Yarn,
    # is sdk
    [Parameter(Mandatory = $false)]
    [switch]
    $Sdk
)

if ($Sdk) {
    $dotnetResult = docker run --rm $Image dotnet --version
}
else {
    $reg = "^  Version: (?<runtime>.*)$"
    $dotnetResult = docker run --rm $Image dotnet --info
    $dotnetResult[2] -match $reg | Out-Null
    $dotnetResult = $Matches['runtime']
}
$nodeResult = docker run --rm $Image node --version
$yarnResult = docker run --rm $Image yarn --version

Write-Output "dotnet version should be $Dotnet"
if ($dotnetResult -ne $Dotnet) {
    Write-Error "Checking dotnet failed:`n$dotnetResult"
    exit 1
}

Write-Output "node.js version should be $Node"
if ($nodeResult -ne "v$Node") {
    Write-Error "Checking node.js failed:`n$nodeResult"
    exit 1
}

Write-Output "yarn version should be $Yarn"
if ($yarnResult -ne $Yarn) {
    Write-Error "Checking yarn failed:`n$yarnResult"
    exit 1
}


if ($LASTEXITCODE -ne 0) {
    Write-Error 'Test failed'
    exit 1
}
