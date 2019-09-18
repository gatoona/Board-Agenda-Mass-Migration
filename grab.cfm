<!--- Grab Category ID --->
<cffunction name="grabCategoryID">

	<cfargument name="category"> 
    <cfif not isdefined("category")>
       <cfreturn "">
    </cfif>

    <cfquery name="categoryid" datasource="commonspot-site-countysite">
    	SELECT DocCategories.ID FROM DocCategories WHERE (DocCategories.Category = '#category#')
    </cfquery>

    <cfif not isdefined("categoryid")>
        <cfset id = queryNew("activity")>
    <cfelse>
    	<cfset id = #categoryid.id#>
    </cfif>

    <cfreturn id>

</cffunction>

<!--- Grab Subsite ID --->
<cffunction name="grabSubsiteID">

	<cfargument name="subsite"> 
    <cfif not isdefined("subsite")>
       <cfreturn "">
    </cfif>

    <cfquery name="subsiteid" datasource="commonspot-site-countysite">
    	SELECT SubSites.ID FROM SubSites WHERE (SubSiteURL = '#subsite#')
    </cfquery>

    <cfif not isdefined("subsiteid")>
        <cfset id = queryNew("activity")>
    <cfelse>
    	<cfset id = #subsiteid.id#>
    </cfif>

    <cfreturn id>
    
</cffunction>