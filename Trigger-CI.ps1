#!/usr/bin/pwsh
param(
    # Version
    [Parameter(Mandatory = $true)]
    [string]
    $Version,
    # Production
    [Parameter(Mandatory = $false)]
    [switch]
    $Prod
)

$ENV:LANGUAGE = "en_US.UTF-8"
$ENV:LC_ALL = "en_US.UTF-8"
$ENV:LANG = "en_US.UTF-8"

$Status = git status -uno -u
$Branch = git rev-parse --abbrev-ref HEAD

if ($Status[1] -eq "Your branch is up to date with 'origin/$Branch'." `
        -and $Status[3] -eq "nothing to commit, working tree clean") {
    if ($Prod) {
        git tag $Version
    }
    else {
        $ShortHash = git rev-parse --short HEAD
        git tag "$Version-$ShortHash"
    }
    git push --tags
}
else {
    Write-Output $Status
}
