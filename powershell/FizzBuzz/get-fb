function get-fb {
    param (
  [Parameter(Mandatory = $false, Position = 0)]
  $Min = 1,

  [Parameter(Mandatory = $false, Position = 1)]
  $Max = 100
)
    for ($i=$Min; $i -le $Max; $i++){
        $output = ""
        if ($i % 3 -eq 0){$output += "Fizz"}
        if ($i % 5 -eq 0){$output += "Buzz"}
        if ($Output -eq "") { $Output = $i }
        Write-Output $output
    }
    
}