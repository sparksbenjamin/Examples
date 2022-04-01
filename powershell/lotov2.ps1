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
        $data=@{},
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
        Get-Pick -badNum $badNum -WeightedData $WeightedData -Powerball $Powerball -points $points -data $data
    }
    $bouncePick = $false
    #Write-Debug $data
    $w = $WeightedData
    $c = $w | Where-Object -Property Name -Value $num -EQ
    $c = $c.Count
    $wc = 0
    $WeightedData | Select-Object Count | ForEach-Object {
        $wc += $_.Count
    }
    $d_avg = $wc / $points
    $score = ($c/$points)*100
    $score = 100 - $score
    #$score = 100 - $score
    <#
    Write-host "++++[View]+++"
    Write-Host "Number: $num"
    Write-Host "Count: $c"
    Write-Host "Score: $score"
    Write-Host "  Avg: $d_avg"
    Write-host "+++++++++++++"
    
    Write-Host "$num with count of $c vs an average of $d_avg score: $score"
    #>
    if($score -lt 90){ $bouncePick = $true}
    if($IsPowerball){

    }else{
        
    }
    if($bouncePick){
        $badNum += $num
        Get-Pick -badNum $badNum -WeightedData $WeightedData -Powerball $Powerball -points $points -data $data
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
    #Write-Host $points
    $avg_val = $data.DVal | Measure-Object -Average 
    #Write-Host $avg_val
    $avg_val = [math]::Round($avg_val.Average)
    #$avg_val_dev = [math]::Round($avg_val.StandardDeviation)
    $avg_val_min = $avg_val - 42
    $avg_val_max = $avg_val + 42
    $picks = @{}
    foreach($i in 1..6){
        #Write-Host "Working on Pick $i"
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
    $upicks = $picks | Select-Object -Property Name,Values -Unique
    if($upicks.length -ne $picks.length){
        $bounceSeq = $true
    }
    $p1 = $picks[1]
    $p2 = $picks[2]
    $p3 = $picks[3]
    $p4 = $picks[4]
    $p5 = $picks[5]
    $p6 = $picks[6]
    $pv = $p1 + $p2 + $p3 + $p4 + $p5 + $p6
    $pv = $pv
    $seq = "$p1,$p2,$p3,$p4,$p5,$p6"
    #Write-Host $seq
    if($badSeq -contains $seq){$bounceSeq = $true}
    if($data.field_winning_numbers -contains $seq){
        Write-Host "Skipping $seq as it has already won!"
        $bounceSeq = $true      
    }elseif($pv -in $avg_val_min..$avg_val_max){
        return $seq
    }else{
        $bounceSeq = $true
    }
    if($bounceSeq){
        $badSeq += $seq
        Get-lottery-numbers -badSeq $badSeq -data $data
    }
    #Write-Host $seq
}
function Get-Seq-Val{
    param(
        $seq
    )
    $array = $seq.Split(",")
    $total=0
    foreach($i in $array){
        $total += $i
    }
    return $total
}
function Get-Seq-Score{
    param(
        [string]$seq,
        $data
    )
    $p = $array = $seq.Split(",")
    $score = 100
    $s_val = Get-Seq-Val -seq $seq
    $avg_ticket_value = $data.DVal | Measure-Object -Average | Select-Object Average
    $avg_ticket_value = [math]::Round($avg_ticket_value.Average)
    if($s_val -ge $avg_ticket_value){
        $val_score = $s_val - $avg_ticket_value
    }else{
        $val_score = $avg_ticket_value - $s_val
    }
    #write-host $val_score
    $score = $score - $val_score


    <# Top and Bottom Subtractors #>
    $TOPNUMBERS=@()
    $BOTTOMENUMBERS=@()
    $P1_Bottom = $data.P1 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -Last 8 
    $BOTTOMENUMBERS += $P1_Bottom.Name
    $P1_Top = $data.P1 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -First 8
    $TOPNUMBERS += $P1_Top.Name 
    $P2_Bottom = $data.P2 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -Last 8 
    $BOTTOMENUMBERS += $P2_Bottom.Name
    $P2_Top = $data.P2 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -First 8 
    $TOPNUMBERS += $P2_Top.Name
    $P3_Bottom = $data.P3 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -Last 8 
    $BOTTOMENUMBERS += $P3_Bottom.Name
    $P3_Top = $data.P3 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -First 8 
    $TOPNUMBERS += $P3_Top.Name
    $P4_Bottom = $data.P4 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -Last 8 
    $BOTTOMENUMBERS += $P4_Bottom.Name
    $P4_Top = $data.P4 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -First 8 
    $TOPNUMBERS += $P4_Top.Name
    $P5_Bottom = $data.P5 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -Last 8
    $BOTTOMENUMBERS += $P5_Bottom.Name 
    $P5_Top = $data.P5 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -First 8 
    $TOPNUMBERS += $P5_Top.Name
    $P6_Bottom = $data.P6 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -Last 8 
    $BOTTOMENUMBERS += $P6_Bottom.Name
    $P6_Top = $data.P6 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -First 8 
    $TOPNUMBERS += $P6_Top.Name
    $BOTTOMENUMBERS = $BOTTOMENUMBERS | Select-Object -Unique
    $TOPNUMBERS = $TOPNUMBERS | Select-Object -Unique
    if($BOTTOMENUMBERS -in $p){$score + 5}
    if($TOPNUMBERS -in $p){$score + 5}
    if ($P1_Bottom.Name -contains $p.1){$score = $score - 2}
    if ($P1_Top.Name -contains $p.1){$score = $score - 1}
    if ($P2_Bottom.Name -contains $p.2){$score = $score - 2}
    if ($P2_Top.Name -contains $p.2){$score = $score - 1}
    if ($P3_Bottom.Name -contains $p.3){$score = $score - 2}
    if ($P3_Top.Name -contains $p.3){$score = $score - 1}
    if ($P4_Bottom.Name -contains $p.4){$score = $score - 2}
    if ($P4_Top.Name -contains $p.4){$score = $score - 1}
    if ($P5_Bottom.Name -contains $p.5){$score = $score - 2}
    if ($P5_Top.Name -contains $p.5){$score = $score - 1}
    if ($P6_Bottom.Name -contains $p.6){$score = $score - 2}
    if ($P6_Top.Name -contains $p.6){$score = $score - 1}

    <# END SECTION #>

    return $score
}
$data_file_path = "C:\Users\Spark\Downloads\results.csv"
#Get-Lotto-data -Path $data_file_path
$data = Import-Csv -Path $data_file_path
#$data.P1 |  Group-Object -NoElement | Select-Object Name,Count | Sort-Object Count -Descending
#$P1_Bottom = $data.P1 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -Last 8 
#$P1_Top = $data.P1 | Group-Object -NoElement | Sort-Object Count -Descending | Select-Object -First 8 
#$P1_Top.Name
#break
#Get-Average -array $wc
#Get-Average -array $weight.Count
$winners=@()
$i = 1
#foreach($i in 1..100)
while($winners.Length -lt 5)
{
    $score = 0
    $seq = Get-lottery-numbers -data $data -badSeq $winners
    $score = Get-Seq-Score -seq $seq -data $data
    $ticket = 
    @([PSCustomObject]@{SEQ=$seq;SCORE=$score})
    #$ticket
    if($score -ge 97){
        $winners += $ticket 
    }
}
#$seq, $score
$winners 

