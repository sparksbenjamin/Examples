function Get-Reverse-string {
    param (
        [string]$string
    )
    $str_array = $string.ToCharArray()
    [array]::Reverse($str_array)
    #$value = join
    return -join($str_array)
}