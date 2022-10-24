$BatchOrder = 5
$BatchSize = [int32]('9' * $BatchOrder)
$arr = [int32[]](0..$BatchSize)

$code = [System.Collections.ArrayList]::New()
#0
$null = $code.add(
    [pscustomobject]@{
        ScriptBlock = {
            $sum = [int32]0
            $add = [int32]($BatchSize + 1)
            $arr | ForEach-Object { $sum = $add + $_ }
        }
    }
)
#1
$null = $code.add(
    [pscustomobject]@{
        ScriptBlock = {
            $n = 20
            $ChunkSize = [math]::Truncate($arr.count / $n)
            $ArrN = [array[]]::New($n)
            For ($i = 0; $i -lt $n; $i++) {
                $Begin = $i * $ChunkSize
                $End = If (($n - $i) -ne 1) { ($i + 1) * $ChunkSize - 1 } Else { $arr.Length }
                $ArrN[$i] = $arr[$Begin..$End]
            }
            $ArrN | ForEach-Object -Parallel { 
                $sum = [int32]0
                $add = [int32]($BatchSize + 1)
                $_ | ForEach-Object { $sum = $add + $_ } 
            } -ThrottleLimit $n
        }
    }
)
#2
$null = $code.add(
    [pscustomobject]@{
        ScriptBlock = { 
            $sum = [int32]0
            $add = [int32]($BatchSize + 1)
            $arr.ForEach({ $sum = $add + $_ }) 
        }
    }
)
#3
$null = $code.add(
    [pscustomobject]@{
        ScriptBlock = { 
            $sum = [int32]0
            $add = [int32]($BatchSize + 1)
            ForEach ($a in $arr) { $sum = $add + $a } 
        }
    }
)
#4
$null = $code.add(
    [pscustomobject]@{
        ScriptBlock = { 
            $sum = [int32]0
            $add = [int32]($BatchSize + 1)
            For ($i = 0; $i -le $BatchSize; $i++) { $sum = $add + $arr[$i] } 
        }
    }
)
#5
$null = $code.add(
    [pscustomobject]@{
        ScriptBlock = { 
            $sum = [int32]0
            $add = [int32]($BatchSize + 1)
            $i = 0
            Do { 
                $sum = $add + $arr[($i++)] 
            } While ($i -le $BatchSize) 
        }
    }
)
#6
$null = $code.add(
    [pscustomobject]@{
        ScriptBlock = { 
            $sum = [int32]0
            $add = [int32]($BatchSize + 1)
            $Enumerator = $arr.GetEnumerator()
            While ($Enumerator.MoveNext()) {
                $sum = $add + $Enumerator.Current
            }
        }
    }
)

#INVOKE
$code | ForEach-Object { 
    $Measure1 = Measure-Command $_.ScriptBlock
    $Measure2 = Measure-Command $_.ScriptBlock
    $Measure3 = Measure-Command $_.ScriptBlock
    $Measure4 = Measure-Command $_.ScriptBlock
    $Measure5 = Measure-Command $_.ScriptBlock
    $_ | Add-Member -MemberType NoteProperty -Name Milliseconds -Value ([int][math]::Round((($Measure1 + $Measure2 + $Measure3 + $Measure4 + $Measure5).TotalMilliseconds / 5)))
}

$code | Out-GridView