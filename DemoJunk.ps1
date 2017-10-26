$var1 = Read-Host "Movie Name"

$array= @("Blade Runner 2049","John Wick Chapter 2", "Thor: Ragnarok")

foreach ($element in $array) {        
        if($var1){
            $speclist = ($element -eq $var1)
        }
        else{
            $speclist = $True
        }
        if($speclist -eq $True){
	        Write-Host "Winner is " $element
        }

}