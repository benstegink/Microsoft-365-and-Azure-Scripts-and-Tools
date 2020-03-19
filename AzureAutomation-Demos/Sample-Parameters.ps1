Param(
    [Parameter (Mandatory=$false)]
    [Int] $variableA,
    [Parameter (Mandatory=$false)]
    [String] $variableB
)

$variableB = [int]$variableB
$variableSum = $variableA + $variableB
Write-Output $variableSum