function get-reverse {
    param (
        [string]$string
    )
    $output = @()
    $output.string = $string
    $ar_str = $string.ToCharArray()
    [array]::Reverse($ar_str)
    #$output = $ar_str
    $reverse_string = -join($ar_str)
    $output = $reverse_string
    return $output

}