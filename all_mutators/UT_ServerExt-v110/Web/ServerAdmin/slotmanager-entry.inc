<form method="post" action="<%PostAction%>">
<tr>	
	<input type="hidden" name="sid" value="<%sid%>">
	<td><input class="textbox" type="text" name="data" style="width: 95%;" value="<%data%>"></td>
	<td><select name="type"><%type%>
	</select></td>
	<td><input type="checkbox" name="speconly" <%speconly%> value="true"></td>
	<td><select name="method"><%method%>
	</select></td>
	<td nowrap><input class="button" type="submit" name="submit" value="update"><input class="button" type="submit" name="submit" value="delete"></td>	
</tr>
<tr>
	<td colspan="4" nowrap><small>Comment:&nbsp;<input class="textbox" type="text" name="comment" value="<%comment%>" style="width: 90%;"></small></td>
	<td></td>
</tr>
</form>