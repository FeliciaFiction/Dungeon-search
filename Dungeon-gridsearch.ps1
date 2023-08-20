Function Find-Route{
param ($grid)
  $counter = 0
  $timeout = 0

    $cells = [pscustomobject]@{}

    # Convert the cells to an X/Y grid with additional properties
    $cells = foreach ($item in $grid.keys | Sort-Object){
    Foreach($column in $grid[$item].keys | Sort-Object){
        [pscustomobject]@{
            X = $item
            Y = $column
            Properties = [pscustomobject]@{
                Visited   = $false
                Exit      = if ($grid[$column][$item] -eq "Exit"){$true}else{$false}
                Blocked   = if ($grid[$column][$item] -eq " ## "){$true}else{$false}
                } # Einde properties
            } # Einde hashtabel voor cellen
        }# Einde foreach column
    } # Einde foreach Item in grid

    # Output the grid in a nice viewable fashion
    write-grid -cellgrid  $cells

    # Initialize queue with cell x=0 and y=0
    $queue = $cells | where-object {$_.x -eq 0 -and $_.y -eq 0} | ConvertTo-Json | ConvertFrom-Json

    
    While ($exit -ne $true){
      $oldqueue = $queue

      $queue = Get-Neighbors -grid $cells -currentcell $queue  | Sort-Object x, y | 
      ConvertTo-Json | ConvertFrom-Json | Select-Object x,y, properties -Unique

      # Check for exit
      if ($true -in $queue.Properties.exit){Write-grid $cells; Write-Host "Exit gevonden: $($queue | where {$_.Properties.Exit -eq $true})"; return}
              
      # Mark cells visited
        $cells = $cells | foreach-object {
            if ($_ | where-object {$_.x -in $oldqueue.x -and $_.y -in $oldqueue.y}) {
                $_.properties.visited = $true
                $_
            } # Einde if
            Else {$_ }
        } # Einde foreach
        #Write-grid $cells

        if ($queue.count -eq $oldqueue.count){$timeout++}
        if ($timeout -gt 5){Write-grid $cells; Return "Could not find exit"}
        
        if ($counter -gt $cells.count){ Write-grid $cells; Return "Could not find exit"}
        $counter++
    } # Einde while exit not found

}

Function Write-Grid { # Print the grid to the console
    Param([pscustomobject]$cellgrid)

    [int]$xteller = 0

    $tabel = foreach ($row in $cells | Group-Object y) { 
        $output = $row | 
            Select-Object -ExpandProperty group | Sort-Object |
            ForEach-Object { # Foreach cell in rows0
                if ($_.properties.blocked -eq $true){Write-output " ## |"}
                elseif($_.properties.exit -eq $true){Write-output "Exit|"}
                elseif ($_.properties.visited -eq $true){Write-output "Vis.|"}
                else { Write-Output "Open|"}

                } # Einde cell in rows
        
        Write-output "$xteller|$output"
        $xteller++

        } # Einde foreach row in cells


    clear-host

   # X axis, not dynamic :P
    Write-output " |  0 |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  10 |  11 |  12 |  13 |  14 |  15 |  16 |  17 |  18"
    $tabel
} # Einde function Write-Grid



function Get-Neighbors ([pscustomobject]$grid, [pscustomobject]$currentcell) {
    foreach ($cell in $currentcell){
      $cell
      # Get the row and column of the cell.
      $row = $cell.x
      $col = $cell.y

      if ($row -lt $grid.count +1) {
        $cells | where-object {$_.x -eq $row + 1 -and $_.y -eq $col -and $_.Properties.blocked -ne $true}
        }
      if ($row -gt 0) {
        $cells | where-object {$_.x -eq $row - 1 -and $_.y -eq $col -and $_.Properties.blocked -ne $true}
        }
      if ($col -lt $grid.count +1) {
        $cells | where-object {$_.x -eq $row -and $_.y -eq $col + 1 -and $_.Properties.blocked -ne $true}
        }
      if ($col -gt 0) {
        $cells | where-object {$_.x -eq $row -and $_.y -eq $col -1 -and $_.Properties.blocked -ne $true}
        }
  } # Einde foreach cell in currentcell
} # Einde function Get-neighbors


Function New-DungeonGrid{
    Param ([int]$dimensions)

    $y = [int]$dimensions
    $x = [int]$dimensions

    # Create a Hashtable to store the grid
    [pscustomobject]$grid = @{}
    for ($i = 0; $i -lt $x; $i++) {
      $grid[$i] += @{}
      for ($j = 0; $j -lt $y; $j++) {
        $grid[$i][$j] = get-random("Open", " ## ", "Open", " ## ", "Open", "Open")
      }
    }

    # Randomly select one cell as the exit cell
    $exitCell = Get-Random(0..([int]$x*[int]$y))
    $grid[[int]($exitCell / $y)][($exitCell % $y) +1] = "Exit"

    Return $grid
} # Einde Function new-dungeongrid

