param (
    [Parameter(Mandatory = $true)]
    [string]$SourceCollectorAPI,

    [Parameter(Mandatory = $true)]
    [string]$TenantKey,

    [Parameter(Mandatory = $true)]
    [string]$SourceCollectorKey,

    [Parameter(Mandatory = $true)]
    [string]$SourceCollectorSecret,

    [Parameter(Mandatory = $false)]
    [string]$SourceCollectorPath,

    [Parameter(Mandatory = $true)]
    [int]$RowCount,

    [switch]$VerboseOutput
)

$ErrorActionPreference = "Stop"

if ($VerboseOutput) {
    $VerbosePreference = "Continue"
} else {
    $VerbosePreference = "SilentlyContinue"
}

Install-Module -Name Varibill.SourceCollector.Core -Force -Scope CurrentUser

# Cache the timestamp rather than calling Get-Date repeatedly
$now = Get-Date

Write-Verbose "Creating UnratedSourceData..."
$unrated = New-UnratedSourceData `
    -SourceCollectorAPI $SourceCollectorAPI `
    -TenantKey $TenantKey `
    -SourceCollectorKey $SourceCollectorKey `
    -SourceCollectorSecret $SourceCollectorSecret `
    -SourceCollectorPath $SourceCollectorPath

Write-Verbose "Adding $RowCount unrated rows..."
for ($i = 1; $i -le $RowCount; $i++) {
    $client = "Client" + $i
    $prod   = "Prod" + $i
    $rec    = "Rec" + $i
    $uid    = "UID" + $i
    $tag    = "Tag" + $i

    $unrated.AddUnratedSourceData($client, $prod, $rec, $uid, $now, $i, $tag)
}

Write-Verbose "Saving and posting unrated data..."
$unrated.SaveData()
$unrated.PostSourceData()


Write-Verbose "Creating RatedSourceData..."
$rated = New-RatedSourceData `
    -SourceCollectorAPI $SourceCollectorAPI `
    -TenantKey $TenantKey `
    -SourceCollectorKey $SourceCollectorKey `
    -SourceCollectorSecret $SourceCollectorSecret `
    -SourceCollectorPath $SourceCollectorPath

Write-Verbose "Adding $RowCount rated rows..."
for ($i = 1; $i -le $RowCount; $i++) {
    $client = "Client" + $i
    $prod   = "Prod" + $i
    $rec    = "Rec" + $i
    $uid    = "UID" + $i
    $tag    = "Tag" + $i

    $rated.AddRatedSourceData($client, $prod, $rec, $uid, $now, $i, $i * 2, $i * 1.5, $tag)
}

Write-Verbose "Saving and posting rated data..."
$rated.SaveData()
$rated.PostSourceData()

Write-Host "[1.1.0] Completed sending $RowCount unrated + $RowCount rated records."

