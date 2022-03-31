function Get-Lotto-data{
    param(
        $Path
    )
    #$numbers =  Import-Csv -Path "C:\Users\Spark\Downloads\Results.csv"
    $url_base = "https://www.powerball.com/api/v1/numbers/powerball?_format=json"
    $startDate = Get-Date("11/01/1997")
    $endDate = Get-Date
    $data=@()
    Write-host "Starting...."
    While($startDate -le $endDate)
    {
        
        $min = $startDate.ToString("yyyy/MM/dd")
        $startDate = $startDate.AddDays(15)
        $max = $startDate.ToString("yyyy/MM/dd")
        $url="$url_base&min=$min&max=$max"
        $startDate = $startDate.AddDays(1)
        Write-Host $url
        $webData = Invoke-WebRequest -Uri $url
        $data += ConvertFrom-Json $webData.content
        #return $data
    }
    #$webData = Invoke-WebRequest -Uri $url_base
    
    $data | Export-Csv -Path $Path -NoTypeInformation
    Write-Host "Done!"
    #return $data

}
function Get-Lotto-Number{
    return Get-Random -Maximum 69 -Minimum 1
}
function Get-Powerball-Number{
    return Get-Random -Maximum 26 -Minimum 1
}



function Get-Pick{
    param(
        [int]$Number,
        $WeightedData=@{},
        [int]$points,
        [bool]$Powerball,
        $badNum=@()
    )
    if($Powerball){
        $num = Get-Powerball-Number
    }else{
        $num = Get-Lotto-Number
    }
    if ($badNum -contains $num){
        Get-Pick -badNum $badNum -WeightedData $WeightedData -Powerball $Powerball -points $points
    }
    $bouncePick = $false
    #Write-Debug $data
    $w = $WeightedData
    $c = $w | Where-Object -Property Name -Value $num -EQ
    $c = $c.Count
    $d_avg = $WeightedData.Count | Measure-Object -Average | Select-Object Average
    $d_avg = [math]::Round($d_avg.Average)
    $score = [math]::Round($data[$num].count/$points)*100
    #$score = 100 - $score
    Write-Host "$num with count of $c vs an average of $d_avg score: $score"
    if($IsPowerball){

    }else{
        if($c -gt $d_avg){ $bouncePick = $true}
    }
    if($bouncePick){
        $badNum += $num
        Get-Pick -badNum $badNum -WeightedData $WeightedData -Powerball $Powerball -points $points
    }else{
        return $num
    }
    
    #Write-Host $data
}
function Get-lottery-numbers{
    param(
        $badSeq=@(),
        $data=@{}
    )
    $bounceSeq = $false
    #$data = Get-Lotto-data
    $points = $data.Count
    Write-Host $points
    $avg_val = $data.DVal | Measure-Object -Average 
    #Write-Host $avg_val
    $avg_val = [math]::Round($avg_val.Average)
    #$avg_val_dev = [math]::Round($avg_val.StandardDeviation)
    $avg_val_min = $avg_val - 42
    $avg_val_max = $avg_val + 42
    $picks = @{}
    foreach($i in 1..6){
        Write-Host "Working on Pick $i"
        $weight = @{}
        $pball = $false
        switch ($i) {
            1 { 
                
                $weight = $data.P1 |  Group-Object -NoElement | Select-Object Name,Count | Sort-Object Count -Descending
            }
            2 { 
                
                $weight = $data.P2 |  Group-Object -NoElement | Select-Object Name,Count | Sort-Object Count -Descending 
            }
            3 { 
                
                $weight = $data.P3 |  Group-Object -NoElement | Select-Object Name,Count | Sort-Object Count -Descending 
            }
            4 { 
                
                $weight = $data.P4 |  Group-Object -NoElement | Select-Object Name,Count | Sort-Object Count -Descending 
            }
            5 { 
                
                $weight = $data.P5 |  Group-Object -NoElement | Select-Object Name,Count | Sort-Object Count -Descending 
            }
            6 { 
                
                $weight = $data.Powerball |  Group-Object -NoElement | Select-Object Name,Count | Sort-Object Count -Descending 
                $pball = $true
            }
            Default {}
        }
        #$weight
        
        $picks[$i] = Get-Pick -WeightedData $weight -points $points -Powerball $pball
        #break
        #Write-Host $picks
    }
    $i = 0
    $p1 = $picks[1]
    $p2 = $picks[2]
    $p3 = $picks[3]
    $p4 = $picks[4]
    $p5 = $picks[5]
    $p6 = $picks[6]
    $pv = $p1 + $p2 + $p3 + $p4 + $p5 + $p6
    $pv = $pv
    $seq = "$p1,$p2,$p3,$p4,$p5,$p6"
    Write-Host $seq
    if($badSeq -contains $seq){$bounceSeq = $true}
    if($data.field_winning_numbers -contains $seq){
        Write-Host "Skipping $seq as it has already won!"
        $bounceSeq = $true      
    }elseif($pv -in $avg_val_min..$avg_val_max){
        return $picks
    }else{
        $bounceSeq = $true
    }
    if($bounceSeq){
        $badSeq += $seq
        Get-lottery-numbers -badSeq $badSeq -data $data
    }
    #Write-Host $seq
}
$data_file_path = "C:\Users\Spark\Downloads\results.csv"
#Get-Lotto-data -Path $data_file_path
$data = Import-Csv -Path $data_file_path
Get-lottery-numbers -data $data
#Get-Ran-seq -ravg $avg

