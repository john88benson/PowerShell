$lNameArray = @()
do{
    $inputLN = (Read-Host "Enter Specific Workflow Names(Optional)")
    if($inputLN -ne ''){$lNameArray += $inputLN}
}
until ($inputLN -eq '')

$array= @("Blade Runner 2049","John Wick Chapter 2", "Thor: Ragnarok")

foreach ($element in $array) {        
        if($lNameArray){
            $speclist = ($lNameArray -contains $element)
        }
        else{
            $speclist = $True
        }
        if($speclist -eq $True){
	        Write-Host "Winner is " $element
        }

}