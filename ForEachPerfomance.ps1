#Requires -Version 7.2
###################################
# FANCY CODE ######################
###################################
# ForEach Perfomance Testing ######
###################################
# Author :  VCUDACHI              #
# License:  MIT                   #
# Created:  2022-1024@2101        #
# Version:  0.1                   #
###################################

$BatchOrder = 6
$BatchSize = [int32]('9' * $BatchOrder)
$arr = [int32[]](0..$BatchSize)

$code = [System.Collections.ArrayList]::New()
#0
$null = $code.add(
    [pscustomobject]@{
        Name        = 'ForEach-Object'
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
        Name        = 'ForEach-Object -Parallel'
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
        Name        = '.ForEach'
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
        Name        = 'ForEach'
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
        Name        = 'For'
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
        Name        = 'While'
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
        Name        = 'Enumerator'
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
    $ScriptBlock = $_.ScriptBlock
    $Measures = 0..9 | ForEach-Object { Measure-Command $ScriptBlock }
    $_ | Add-Member -MemberType NoteProperty -Name Milliseconds -Value ([int]([math]::Round(($Measures.TotalMilliseconds | Measure-Object -Average).Average)))
}

$code | Out-GridView