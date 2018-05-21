#!/usr/bin/pwsh
param(
    # Git tag
    [Parameter(Mandatory = $true)]
    [string]
    $Tag,
    # image name
    [Parameter(Mandatory = $true)]
    [string]
    $ImageName,
    # Latest
    [Parameter(Mandatory = $false)]
    [switch]
    $IsLatest,
    # TagSuffix
    [Parameter(Mandatory = $false)]
    [string]
    $TagSuffix
)

function Push-Image {
    param(
        # ImageName
        [Parameter(Mandatory = $true)]
        [string]
        $ImageName,
        # Version
        [Parameter(Mandatory = $true)]
        [string]
        $Version,
        # Suffix
        [Parameter(Mandatory = $false)]
        [string]
        $Suffix
    )
    if ($Suffix -ne $null) {
        $Suffix = "-$Suffix"
    }
    $tag = "${ImageName}:$Version$Suffix"
    docker tag "${ImageName}:tmp$Suffix" $tag
    Write-Output "Pushing: $tag"
    docker push $tag

}

$tagReg = '(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)(?<preRelease>-[a-zA-Z0-9.]+)?-(?<hash>.{7})'

Write-Output "Git tag is $Tag"

if ($Tag -match $tagReg) {
    $major = $Matches['major']
    $minor = $Matches['minor']
    $patch = $Matches['patch']
    $preRelease = $Matches['preRelease']
    $hash = $Matches['hash']
    Write-Output "Version is $major.$minor.$patch"
    Write-Output $ENV:DOCKER_PASSWORD | docker login -u $ENV:DOCKER_USERNAME --password-stdin
    Push-Image -ImageName $ImageName -Version "$major.$minor.$patch$preRelease" -Suffix $TagSuffix
    Push-Image -ImageName $ImageName -Version "$major.$minor" -Suffix $TagSuffix
    if ($IsLatest) {
        Push-Image -ImageName $ImageName -Version 'latest'
    }

}
else {
    Write-Error "Invalid git tag"
    exit 1
}
