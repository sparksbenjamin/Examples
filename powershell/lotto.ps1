

function Get-Lotto-data{
    $numbers =  Import-Csv -Path "C:\Users\Spark\Downloads\Results.csv"
    return $numbers

}
function Get-Lotto-Number{
    return Get-Random -Maximum 69 -Minimum 1
}

function Get-Pick-Score{
    param (
        [int]$Pick,
        [int]$Pick_Value,
        [array]$Pick_wieght
    )
    
}
function Get-Ran-seq{
    param (
        [string]$ravg,
        [int]$pos
    )
    switch ($pos){
        1 {

        }
    }
    $p1 = Get-Lotto-Number
    $p2 = Get-Lotto-Number
    $p3 = Get-Lotto-Number
    $p4 = Get-Lotto-Number
    $p5 = Get-Lotto-Number
    $p6 = Get-Lotto-Number
    $navg = $p1+$p2+$p3+$p4+$p5+$p6
    $navg = [math]::Round($navg/6)

    $seq = "$p1-$p2-$p3-$p4-$p5-$p6"
    if ($old_seq -contains $seq ){
        Get-Ran-seq -ravg $navg
    }else{
        if($navg -eq $ravg){
            return $seq
        }else{
            $old_seq += $seq
            Get-Ran-seq -ravg $navg
        }
        
    }

}

function Get-Pick{
    param(
        [int]$Number,
        [array]$data,
        [int]$points,
        $badNum=@{}
    )
    $num = Get-Lotto-Number
    $num_count = $data[$num].Count
    if($badNum -contains $num){ Get-Pick -data $data -points $points}
    $d_avg = $data.Count | Measure-Object -Average | Select-Object Average
    $d_avg = [math]::Round($d_avg.Average)
    $score = [math]::Round($data[$num].count/$points)*100
    $score = 100 - $score
    Write-Host "$num has been drawn $num_count in a possition that has an average draw of $d_avg score of $score"
    if($num_count -le $d_avg){
        return $num
    }else{
        Write-host "$num is above avg draw rate"
        $badNum[$num]="BAD"
        Get-Pick -data $data -badNum $badNum -points $points
    }
    #Write-Host $data
}
function Get-lottery-numbers{
    param(
        $badSeq=@()
    )
    $data = Get-Lotto-data
    $points = $data.Count
    $avg_val = $data.Val | Measure-Object -Average 
    $avg_val = [math]::Round($avg_val.Average)
    #$avg_val_dev = [math]::Round($avg_val.StandardDeviation)
    $avg_val_min = $avg_val - 42
    $avg_val_max = $avg_val + 42
    $picks = @{}
    foreach($i in 1..6){
        Write-Host "Working on Pick $i"
        switch ($i) {
            1 { 
                
                $weight = $data.Pick1 |  Group-Object -NoElement | Select-Object Name,Count | Sort-Object Count -Descending
            }
            2 { 
                
                $weight = $data.Pick2 |  Group-Object -NoElement | Select-Object Name,Count | Sort-Object Count -Descending 
            }
            3 { 
                
                $weight = $data.Pick3 |  Group-Object -NoElement | Select-Object Name,Count | Sort-Object Count -Descending 
            }
            4 { 
                
                $weight = $data.Pick4 |  Group-Object -NoElement | Select-Object Name,Count | Sort-Object Count -Descending 
            }
            5 { 
                
                $weight = $data.Pick5 |  Group-Object -NoElement | Select-Object Name,Count | Sort-Object Count -Descending 
            }
            6 { 
                
                $weight = $data.Powerball |  Group-Object -NoElement | Select-Object Name,Count | Sort-Object Count -Descending 
            }
            Default {}
        }
        
        $picks[$i] = Get-Pick -data $weight -points $points
        #Write-Host $picks
    }

    $p1 = $picks[1]
    $p2 = $picks[2]
    $p3 = $picks[3]
    $p4 = $picks[4]
    $p5 = $picks[5]
    $p6 = $picks[6]
    $pv = $p1 + $p2 + $p3 + $p4 + $p5 + $p6
    $pv = $pv
    $seq = "$p1-$p2-$p3-$p4-$p5-$p6"
    Write-Host $seq
    if($badSeq -contains $seq){Get-lottery-numbers -badSeq $badSeq}
    if($data.Seq -contains $seq){
        Write-Host "Skipping $seq as it has already won!"
        $badSeq += $seq
        Get-lottery-numbers -badSeq $badSeq       
    }elseif($pv -in $avg_val_min..$avg_val_max){
        return $picks
    }else{
        $badSeq += $seq
        Get-lottery-numbers -badSeq $badSeq 
    }
    #Write-Host $seq
}

Get-lottery-numbers
#Get-Ran-seq -ravg $avg


