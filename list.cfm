<cfquery name="category" datasource="commonspot-site-countysite">
	SELECT SubSites.ID, SubSites.ParentID, SubSites.SubSiteURL  FROM SubSites WHERE (SubSites.ParentID = '141')
</cfquery>

<cffunction name="grabYears">

	<cfargument name="categoryid"> 
    <cfif not isdefined("categoryid")>
       <cfreturn "">
    </cfif>

    <cfquery name="years" datasource="commonspot-site-countysite">
		SELECT SubSites.ID, SubSites.ParentID, SubSites.SubSiteURL  FROM SubSites WHERE (SubSites.ParentID = '#categoryid#') ORDER BY SubSites.ID DESC
	</cfquery>

    <cfif not isdefined("years")>
        <cfset years = queryNew("activity")>
    </cfif>

    <cfreturn years>

</cffunction>



<cfif category.RecordCount GT 0>

	<cfoutput query="category">
		<cfset item = SubSiteURL>
		<cfset items = item.Split("/")>
		<h1>#items[4]#</h1>

		<cfset years = grabYears('#ID#')>
		<cfif years.RecordCount GT 0>
			<cfloop query="years">
	
					<cfset item = SubSiteURL>
					<cfset items = item.Split("/")>
					<a href="/BOC/Meetings/Agendas/#items[5]#">#items[5]#</a> | 

			</cfloop>

		</cfif>
	</cfoutput>


</cfif>

