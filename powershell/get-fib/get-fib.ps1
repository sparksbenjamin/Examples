function Get-fibonacci{
        param(
    [Parameter(Position=0,mandatory=$true)]
    [int]$Requested_possition,
    $mem=@{}
    )
    switch ($Requested_possition){
        0 { return 0}
        1 { return 1}
        default { 
            if ($mem.$Requested_possition){ return $mem.$Requested_possition}
            else{
                $n1 = $Requested_possition - 1
                $n2 = $Requested_possition - 2
                $n1_value = Get-fibonacci -Requested_possition $n1 -mem $mem
                $n2_value = Get-fibonacci -Requested_possition $n2 -mem $mem
                [double]$tvalue = $n1_value + $n2_value
                $mem.$Requested_possition=$tvalue
                return $tvalue
            }
            
        }

    }

}