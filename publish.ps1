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
    $IsLatest
)

$tagReg = '(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)-[a-zA-Z0-9-\.]+-(?<hash>.{7})'

Write-Output "Git tag is $Tag"

if ($Tag -match $tagReg) {
    $major = $Matches['major']
    $minor = $Matches['minor']
    $patch = $Matches['patch']
    $hash = $Matches['hash']
    Write-Output $ENV:DOCKER_PASSWORD | docker login -u $ENV:DOCKER_USERNAME --password-stdin
    docker tag "${ImageName}:tmp" "${ImageName}:$major.$minor.$patch"
    docker tag "${ImageName}:tmp" "${ImageName}:$major.$minor"
    Write-Output "Pushing: ${ImageName}:$manjor.$minor.$patch"
    docker push "${ImageName}:$manjor.$minor.$patch"
    Write-Output "Pushing: ${ImageName}:$manjor.$minor"
    docker push "${ImageName}:$manjor.$minor"
    if ($IsLatest) {
        docker tag "${ImageName}:tmp" "${ImageName}:latest"
        Write-Output "Pushing: ${ImageName}:$manjor.$minor"
        docker push "${ImageName}:latest"
    }

}
else {
    Write-Error "Invalid git tag"
    exit 1
}
