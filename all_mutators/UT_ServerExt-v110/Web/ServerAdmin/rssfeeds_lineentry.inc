<form method="post" action="<%PostAction%>">
<input type="hidden" name="submit" value="edit-entry" />
<input type="hidden" name="feedid" value="<%feedid%>" />
<input type="hidden" name="entry_id" value="<%entry_id%>" />
<tr>
	<td class="<%altbg%>">Title</td><td class="<%altbg%>"><input class="textbox" type="text" name="entry_title" value="<%entry_title%>" title="Title" size="70" maxlength="256" /></td>
	<td class="<%altbg%>" rowspan="3"><input class="button" type="submit" name="action" value="update" /><br />
	<input class="button" type="submit" name="action" value="delete" /><br />
	<br />
	<input class="button" type="submit" name="action" value="up" /><input class="button" type="submit" name="action" value="down" /></td>
</tr>
<tr>
	<td class="<%altbg%>">Link</td><td class="<%altbg%>"><input class="textbox" type="text" name="entry_link" value="<%entry_link%>" title="Link" size="70" maxlength="128" /></td>
</tr>
	<td class="<%altbg%>">Description</td><td class="<%altbg%>"><input class="textbox" type="text" name="entry_description" value="<%entry_description%>" title="Description" size="70" maxlength="512" /></td>
</tr>
</form>
