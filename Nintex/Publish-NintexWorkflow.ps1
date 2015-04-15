function Publish-NintexWorkflow($url,$listName,$WorkflowFile,$prePendLibrayName){
    #This script needs some updating to be in proper function form.
    #Target SharePoint site URL
    $WebURL=$url
    #Get the Target Site
    $Web=Get-SPWeb $WebURL
    $List = $web.Lists[$listName]
    #Get the Target Lists
    #Nintex Web Service URL
    $WebSrvUrl=$WebURL+"/_vti_bin/nintexworkflow/workflow.asmx"
    $proxy=New-WebServiceProxy -Uri $WebSrvUrl -UseDefaultCredential
    $proxy.URL=$WebSrvUrl
    $WorkflowNameStart = $WorkflowFile.LastIndexOf("\")+1
    $WorkflowNameLength = $WorkflowFile.LastIndexOf(".") - $WorkflowNameStart
    $WorkflowName = $WorkflowFile.Substring($WorkflowNameStart,$WorkflowNameLength)
    #Get the Workflow from file
    $NWFcontent = get-content $WorkflowFile
    #write-host "Workflow is being Published to: "$List
    if($prePendLibrayName -eq $true){
        $WorkflowName = ($List.EntityTypeName+"_"+$WorkflowName)
    }
    $proxy.PublishFromNWFXml($NWFcontent, $listName ,$WorkflowName, $true)
    #write-host "Done!"
    $Web.Dispose()
}