<cfinclude template="grab.cfm">

<cfparam name="url.step" default="search" type="any">
<cfparam name="url.category" default="" type="any">
<cfparam name="url.subsite" default="" type="any">
<cfparam name="url.year" default="" type="any">

<!--- Step One --->
<cfif url.step eq "search">
	<cfoutput>
		<h1>PDF Mover</h1>
		<p><b>Step 1:</b> Use the form below to search for PDFs.</p>
		<form action="#cgi.SCRIPT_NAME#" method="GET" id="form" name="form">
			<table border="0" cellpadding="5">
				<tr>
					<td><b>Category:</b></td>
					<td>
						<input name="category" type="text" id="category" size="20" placeholder="Agendas, Minutes, etc">
					</td>
				</tr>
				<tr>
					<td><b>Date Added</b> (Year):</td>
					<td>
						<input name="year" type="number" id="year" size="20" placeholder="2009">
					</td>
				</tr>
				<tr>
					<td><b>Subsite</b> (url must end with /):</td>
					<td>
						<input name="subsite" type="text" id="subsite" size="20" placeholder="/BOC/Meetings/" required>
					</td>
				</tr>
			</table>
			<input name="step" type="text" id="step" value="result" hidden/>
			<br>
			<input type="submit" value="Search">
		</form>
	</cfoutput>
</cfif>

<!--- Step Two --->
<cfif url.step eq "result">
	<!--- Grab Variables --->
	<cfset category = (len(trim(grabCategoryID('#url.category#'))) GT 0) ? grabCategoryID('#url.category#') : ''>
	<cfset subsite = (len(trim(grabSubsiteID('#url.subsite#'))) GT 0) ? grabSubsiteID('#url.subsite#') : '-1'>
	<cfset year = (len(trim('#url.year#')) GT 0) ? url.year : ''>

	<!--- Grab Documents --->
	<cfquery name="pdf" datasource="commonspot-site-countysite">
		SELECT SitePages.ID, SitePages.Title, SitePages.SubSiteID, SubSites.SubSiteURL, UploadedDocs.PublicFileName  FROM SitePages LEFT JOIN UploadedDocs ON SitePages.ID = UploadedDocs.PageID AND UploadedDocs.VersionState = 2 LEFT JOIN SubSites ON SitePages.SubSiteID = SubSites.ID WHERE (SitePages.DocType = 'pdf' AND SitePages.SubSiteID = '#subsite#'
			<cfif year NEQ ''>
				AND SitePages.DateAdded LIKE '%#year#%' 
			</cfif>
			<cfif category NEQ ''>
				AND SitePages.CategoryID = '#category#'
			</cfif>
			)
	</cfquery>
	<cfoutput>
		<h1>Found PDFs (#pdf.RecordCount#)</h1>
	</cfoutput>
	<cfif pdf.RecordCount GT 0>
		<cfoutput>
			<p><b>Step 2:</b> Use the form below to specify the new subsite you would like to copy the selected PDF files to.</p>
			<p><a href="?">Go Back</a></p>
			<hr>
			<form action="#cgi.SCRIPT_NAME#" method="GET" id="form" name="form">
				<table border="0" cellpadding="5">
					<tr>
						<td><b>Copy to subsite</b> (url must end with /):</td>
						<td>
							<input name="subsite" type="text" id="subsite" size="20" placeholder="/BOC/Meetings/Agendas/" required>
						</td>
					</tr>
				</table>
				<p><b>Files to copy:</b></p>
		</cfoutput>
		<cfoutput query="pdf">
			<input type="checkbox" name="id" value="#ID#" checked>
			<a title="#Title#" href="//www.co.washington.or.us#LCase(SubSiteURL)#upload/#LCase(PublicFileName)#">(#ID#) #Title#</a><br>
		</cfoutput>
		<cfoutput>
			<input name="step" type="text" id="step" value="move" hidden/>
				<br>
				<input type="submit" value="Update Subsite and Copy">
			</form>
		</cfoutput>
	<cfelse>
		<cfoutput>
			<p>No PDFs found. <a href="?">Search Again.</a></p>
		</cfoutput>
	</cfif>
	
</cfif>

<!--- Step Three --->

<cfif url.step eq "move">
	<!--- Grab Variables --->
	<cfset subsite = (len(trim(grabSubsiteID('#url.subsite#'))) GT 0) ? grabSubsiteID('#url.subsite#') : '-1'>
	<!--- If Subsite Exists: --->
	<cfif subsite NEQ '-1'>
		<cfset ids = isdefined("url.id") ? url.id.Split(",") : []>


		

		<cfif ArrayLen(ids) GT 0>

			<!--- Grab Public File Names --->
			<cftry>

			    <cfquery name="boc" datasource="commonspot-site-countysite">
			    	SELECT SitePages.Title, SitePages.SubSiteID, SubSites.SubSiteURL, UploadedDocs.PublicFileName FROM SitePages LEFT JOIN UploadedDocs ON SitePages.ID = UploadedDocs.PageID AND UploadedDocs.VersionState = 2 LEFT JOIN SubSites ON SitePages.SubSiteID = SubSites.ID WHERE (SitePages.ID in (#url.id#))
			    </cfquery>
			    <cfcatch>
			        <cfoutput>
        				<h1>Error.</h1>
        				<p>Subsite update failed.</p>
        			</cfoutput>
        			<cfexit>
			    </cfcatch>

			</cftry>

		

			<!--- Update Subsite ID --->
			<cftry>

			    <cfquery name="bocupdate" datasource="commonspot-site-countysite">
			    	UPDATE SitePages SET SitePages.SubSiteID = '#subsite#' WHERE (SitePages.ID in (#url.id#))
			    </cfquery>
			    <cfcatch>
			        <cfoutput>
        				<h1>Error.</h1>
        				<p>Subsite update failed.</p>
        			</cfoutput>
        			<cfexit>
			    </cfcatch>
			</cftry>

			<cfoutput>
				<h1>Subsites Updated!</h1>
			</cfoutput>

			<!--- File Copy Start --->
			<cfoutput query="boc">

				<cfset oldLocation="#ExpandPath("#SubSiteURL#/upload/#PublicFileName#")#">
				<cfset newLocation="#ExpandPath("#url.subsite#/upload/")#">

				<a title="#Title#" href="#LCase(url.subsite)#upload/#LCase(PublicFileName)#">#Title#</a>

				<!--- If File Exists --->
				<cfif FileExists(oldLocation)>

					<cftry>
						<!--- Move File Start --->
					    <cffile action = "copy" destination = "#newLocation#" source = "#oldLocation#">
					    <div style="background-color: green; padding: 5px; color: white; display: inline-block;">Success</div>
					    <br>
					    <ul>
					    	<li><b>File Location:</b> #oldLocation#</li>
					    	<li><b>Copied To:</b> #newLocation#</li>
					    	<li><b>Old Subsite:</b> #SubSiteURL#</li>
					    	<li><b>Set To:</b> #url.subsite#</li>
					    </ul>
					    <cfcatch>
					        <cfoutput>
		        				<div style="background-color: red; padding: 10px; color: white; display: inline-block;">Failed</div>
		        			</cfoutput>
					    </cfcatch>
					</cftry>

			    <!--- If File Does Not Exist --->
			    <cfelse>
			        <div style="background-color: red; padding: 10px; color: white; display: inline-block;">Failed</div>
					<br>
					<p>File does not exist.</p>
			    </cfif>

				
	
				<hr>
			</cfoutput>

		<cfelse>
			<cfoutput>
				<h1>Error</h1>
				<p>No PDFs selected. <a href="#CGI.HTTP_REFERER#">Go Back.</a></p>
			</cfoutput>
		</cfif>

		<!--- 
		<cfloop array="#ids#" item="id">
		   <cfoutput>
		   		<p>#id#</p>
		    </cfoutput>
		</cfloop> --->
		
	<!--- If Subsite Doesn't Exist --->
	<cfelse>
		<cfoutput>
			<h1>Error</h1>
			<p>The subsite you wish to move the files to does not exist. <a href="#CGI.HTTP_REFERER#">Go Back.</a></p>
		</cfoutput>
	</cfif>

	

</cfif>