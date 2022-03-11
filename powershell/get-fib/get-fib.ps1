function Get-fibonacci{
        param(
    [Parameter(Position=0,mandatory=$true)]
    [int]$Requested_possition,
    $seed=@{}
    )
    switch ($Requested_possition){
        0 { return 0}
        1 { return 1}
        default { 
            if ($seed.$Requested_possition){ return $seed.$Requested_possition}
            else{
                
                $n1 = $Requested_possition - 1
                $n2 = $Requested_possition - 2
                if($seed.$n1){$n1_value = $seed.$n1}else{
                    $n1_value = Get-fibonacci -Requested_possition $n1 -seed $seed
                }
                if($seed.$n2){$n2_value = $seed.$n2}else{
                    $n2_value = Get-fibonacci -Requested_possition $n2 -seed $seed
                }
                [bigint]$tvalue = $n1_value + $n2_value
                $seed.$Requested_possition=$tvalue
                return $tvalue
            }   
        }
    }
}
function Get-Fib-Seq{
    param(
        [int]$Starting_Num,
        [int]$Count
    )
    $output=@{}
    $max = $Starting_Num + $Count
    $bseed = @{}
    for($i=$Starting_Num; $i -le $max;$i++){
        $c = $i - $Starting_Num
        if($c -ge 3){
            #buld Seed
            $bseed = $output
        }
        $value = Get-fibonacci -Requested_possition $i -seed $bseed
        $output.$i = $value
    }
    return $output.GetEnumerator() | sort-object -Property Name
    $i=0
    $output=''
}
