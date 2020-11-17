# Sample Azure DevOps Analytics OData Queries 

These queries can be used within PowerBI to display advance reporting details 

## Query #1 - Simple Qeury to pull Work Items
let
   Source = OData.Feed("https://analytics.dev.azure.com/{Org}/{Project}/_odata/v3.0-preview/WorkItems",
      null, [Implementation="2.0", OmitValues=ODataOmitValues.Nulls, ODataVersion=4])
in
    Source


## Query #2 - Simple Query to pull All Work Item Tags
let
   Source = OData.Feed("https://analytics.dev.azure.com/{Org}/{Project}/_odata/v3.0-preview/tags",
      null, [Implementation="2.0", OmitValues=ODataOmitValues.Nulls, ODataVersion=4])
in
    Source

## Query #3 - Query to pull Cycle Lead Time
let
   Source = OData.Feed ("https://analytics.dev.azure.com/{Org}/{Project}/_odata/v3.0-preview/WorkItems?"
        &"$filter=WorkItemType eq 'User Story' "
            &"and StateCategory eq 'Completed' "
            &"and CompletedDate ge 2020-01-01Z "
            &"and startswith(Area/AreaPath,'{Project}') "
        &"&$select=WorkItemId,Title,WorkItemType,State,Priority,Severity,TagNames,AreaSK,CycleTimeDays,LeadTimeDays,CompletedDateSK "
        &"&$expand=AssignedTo($select=UserName),Iteration($select=IterationPath),Area($select=AreaPath) "
    ,null, [Implementation="2.0",OmitValues = ODataOmitValues.Nulls,ODataVersion = 4]) 
in
    Source

## Query #4 - Query to create 1:1 mapping of Tag Name and Work Item
let
   Source = OData.Feed("https://analytics.dev.azure.com/{Org}/{Project}/_odata/v3.0-preview/WorkItems?$select=Title,WorkItemType,TagNames",
      null, [Implementation="2.0", OmitValues=ODataOmitValues.Nulls, ODataVersion=4]),
    #"Split Column by Delimiter" = Table.ExpandListColumn(Table.TransformColumns(Source, {{"TagNames", Splitter.SplitTextByDelimiter(";", QuoteStyle.None), let itemType = (type nullable text) meta [Serialized.Text = true] in type {itemType}}}), "TagNames"),
    #"Changed Type" = Table.TransformColumnTypes(#"Split Column by Delimiter",{{"TagNames", type text}}),
    #"Trimmed Text" = Table.TransformColumns(#"Changed Type",{{"TagNames", Text.Trim, type text}})
in
    #"Trimmed Text"


