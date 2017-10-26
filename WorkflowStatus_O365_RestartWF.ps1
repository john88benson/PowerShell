cls
#Import SharePoint Online Management Shell
Import-Module Microsoft.Online.SharePoint.Powershell -ErrorAction SilentlyContinue

Add-PSSnapIn Microsoft.SharePoint.PowerShell  -ErrorAction SilentlyContinue

#region Input Variables 

#$SiteUrl = "https://onewri.sharepoint.com/sites/subagreements" #Replace the URL
$SiteUrl = Read-Host -Prompt "Site Url"

$UserName = Read-Host -Prompt "Enter User Name"
#portal_admin@onewri.onmicrosoft.com
$SecurePassword = Read-Host -Prompt "Enter password" -AsSecureString
#@Portal002

$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $UserName, $SecurePassword

$listTitle = Read-Host -Prompt "For List Title"
$listName = Read-Host -Prompt "For Specific Workflow Name"

#endregion

#region Connect to SharePoint Online tenant and Create Context using CSOM

Try
{
    #region Load SharePoint Client Assemblies

	Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
    Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.WorkflowServices.dll"

    #endregion

     
    #region connect/authenticate to SharePoint Online and get ClientContext object.. 	

    $clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl) 
    $credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword) 
    $clientContext.Credentials = $credentials

    Write-Host "Connected to SharePoint Online site: " $SiteUrl -ForegroundColor Green
    Write-Host ""

    #endregion


}
Catch
{
    $SPOConnectionException = $_.Exception.Message
    Write-Host ""
    Write-Host "Error:" $SPOConnectionException -ForegroundColor Red
    Write-Host ""
    Break
}

#endregion


if (!$clientContext.ServerObjectIsNull.Value) 
{ 
        $web = $clientContext.Web
        $lists = $web.Lists
	    $clientContext.Load($lists);
	    $clientContext.ExecuteQuery();

        $workflowServicesManager = New-Object Microsoft.SharePoint.Client.WorkflowServices.WorkflowServicesManager($clientContext, $web);
        $workflowSubscriptionService = $workflowServicesManager.GetWorkflowSubscriptionService();
        $workflowInstanceSevice = $workflowServicesManager.GetWorkflowInstanceService();



        foreach ($list in $lists)       
        {  
			#Remove this if statement for all lists
			if ($list.Title -eq $listTitle){
				$workflowSubscriptions = $workflowSubscriptionService.EnumerateSubscriptionsByList($list.Id);
				$clientContext.Load($workflowSubscriptions);                
				$clientContext.ExecuteQuery();                
				foreach($workflowSubscription in $workflowSubscriptions)
				{   
				#Run for a particular Workflow Name
				if($workflowSubscription.Name -eq $listName){	
						$count = 0
						
						$wfSub = @()
						$wfSub += New-object -TypeName PSCustomObject -Property @{
							SubscriptionId = $workflowSubscription.Id
							Name = $workflowSubscription.Name
						}
				}
						
						$camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
						$camlQuery.ViewXml = "<View> <ViewFields><FieldRef Name='Title' /></ViewFields></View>";
						$listItems = $list.GetItems($camlQuery);
						$clientContext.Load($listItems);
						$clientContext.ExecuteQuery();

						foreach($listItem in $listItems)
						{
							$itNum = $listItem.ID
							if($itNum -eq 912){
								#if($itNum -lt 3664){							
								$workflowInstanceCollection = $workflowInstanceSevice.EnumerateInstancesForListItem($list.Id, $itNum);
								$clientContext.Load($workflowInstanceCollection);
								$clientContext.ExecuteQuery();
								foreach ($workflowInstance in $workflowInstanceCollection)
								{	
									$itemSubID = $workflowInstance.WorkflowSubscriptionId
									$itemWFName = $wfSub.Name | Where-Object {$_.SubscriptionId -eq $itemSubID}}
									$itemStatus = $workflowInstance.Status
									$itemProps = $workflowInstance.Properties
									$itemUStatus = $workflowInstance.UserStatus
									$itemError = $workflowInstance.FaultInfo
									$itemCreated = $workflowInstance.InstanceCreated
									$itemMod = $workflowInstance.LastUpdated
									Write-Host "Logging: "$itemWFName " on item ID: " $itNum " ; Status: " $itemStatus "; User Status: " $itemUStatus, 							
									# For a particular Workflow Status
									if($itemStatus -eq "Suspended"){
										  $workflowInstanceService.TerminateWorkflow($workflowInstance);
										  $object = New-Object 'system.collections.generic.dictionary[string,object]'
										  $object.Add("WorkflowStart", "StartWorkflow");
										  $workflowInstanceService.StartWorkflowOnListItem($workflowSubscription, $itNum, $object);
										  Write-Host "Workflow "$wfName " Terminated on item ID: " $itNum " ; Status: " $itemStatus "; User Status: " $itemUStatus " with ID: " $wfId
										  }
																																																																		Write-Host "Logging: "$wfName " on item ID: " $itNum " ; Status: " $itemStatus "; User Status: " $itemUStatus " with ID: " $wfId
									#}							
								}
								
							}
								
						}
							
				
					
				}
        }		
    }                         
   
   
    
    
    
    
