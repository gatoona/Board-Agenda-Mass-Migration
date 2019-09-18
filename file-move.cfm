<!--- Check if File Exists --->
<cfset oldLocation="#ExpandPath("/BOC/Meetings/upload/_Board-Agenda-12-18-18.pdf")#">
<cfset newLocation="#ExpandPath("/BOC/Meetings/Agendas/upload/")#">

<cfoutput>
	<!--- If File Exists: --->
	<cfif FileExists(oldLocation)>
		<!--- Display File Info: --->
        <cfset fileInfo=GetfileInfo(oldLocation)>
        Path: #fileInfo.Path#
        <br />
        Size: #fileInfo.Size#
        <br />
        Last Modified: #fileInfo.LastModified#

        <!--- Move File Start --->

        <cffile action = "copy" destination = "#newLocation#" source = "#oldLocation#">

    <!--- If File Does Not Exist --->
    <cfelse>
        Error: File Not Found
    </cfif>
</cfoutput>