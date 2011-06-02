<!--  ----------------------------------------------------------------------  -->
<!--  NOTE: Please add the following <META> element to your page <HEAD>.      -->
<!--  If necessary, please modify the charset parameter to specify the        -->
<!--  character set of your HTML page.                                        -->
<!--  ----------------------------------------------------------------------  -->

<META HTTP-EQUIV="Content-type" CONTENT="text/html; charset=UTF-8">

<!--  ----------------------------------------------------------------------  -->
<!--  NOTE: Please add the following <FORM> element to your page.             -->
<!--  ----------------------------------------------------------------------  -->

<form action="https://www.salesforce.com/servlet/servlet.WebToCase?encoding=UTF-8" method="POST">

<input type=hidden name="orgid" value="00D400000007AR2">
<input type=hidden name="retURL" value="http://">

<!--  ----------------------------------------------------------------------  -->
<!--  NOTE: These fields are optional debugging elements.  Please uncomment   -->
<!--  these lines if you wish to test in debug mode.                          -->
<!--  <input type="hidden" name="debug" value=1>                              -->
<!--  <input type="hidden" name="debugEmail"                                  -->
<!--  value="mstewart@cardiacscience.com">                                    -->
<!--  ----------------------------------------------------------------------  -->

<label for="name">Contact Name</label><input  id="name" maxlength="80" name="name" size="20" type="text" /><br>

<label for="email">Email</label><input  id="email" maxlength="80" name="email" size="20" type="text" /><br>

<label for="phone">Phone</label><input  id="phone" maxlength="40" name="phone" size="20" type="text" /><br>

<label for="subject">Subject</label><input  id="subject" maxlength="80" name="subject" size="20" type="text" /><br>

<label for="description">Description</label><textarea name="description"></textarea><br>

<label for="company">Company</label><input  id="company" maxlength="80" name="company" size="20" type="text" /><br>

<label for="type">Type</label><select  id="type" name="type"><option value="">--None--</option><option value="Problem">Problem</option>
<option value="Feature Request">Feature Request</option>
<option value="Question">Question</option>
</select><br>

<label for="status">Status</label><select  id="status" name="status"><option value="">--None--</option><option value="On Hold">On Hold</option>
<option value="Escalated">Escalated</option>
<option value="Closed">Closed</option>
<option value="New">New</option>
<option value="In Progress">In Progress</option>
</select><br>

<label for="reason">Case Reason</label><select  id="reason" name="reason"><option value="">--None--</option><option value="User didn&#39;t attend training">User didn&#39;t attend training</option>
<option value="Complex functionality">Complex functionality</option>
<option value="Existing problem">Existing problem</option>
<option value="Instructions not clear">Instructions not clear</option>
<option value="New problem">New problem</option>
</select><br>

<label for="priority">Priority</label><select  id="priority" name="priority"><option value="">--None--</option><option value="High">High</option>
<option value="Medium">Medium</option>
<option value="Low">Low</option>
</select><br>

<label for="currency"><span class="requiredMark">*</span>Case Currency</label><select  id="currency" name="currency"><option value="CAD">CAD - Canadian Dollar</option>
<option value="CNY">CNY - Chinese Yuan</option>
<option value="EUR">EUR - Euro</option>
<option value="GBP">GBP - British Pound</option>
<option value="USD" selected="selected">USD - U.S. Dollar</option>
</select><br>

Due Date:<span class="dateInput"><input  id="00N400000021F4Q" name="00N400000021F4Q" size="20" type="text" /></span><br>

<input type="submit" name="submit">

</form>
