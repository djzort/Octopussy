<% my %arg = @_; %>
<AAT:Box width="$arg{width}">
<AAT:BoxRow>
	<AAT:BoxCol cspan="6"><AAT:Label value="_EXPORT_SCP" style="B"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="R"><AAT:Button name="device" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_HOST" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="scp_host" size="32" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Button name="user" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_USER" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="scp_user" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="R"><AAT:Button name="directory" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_DIRECTORY" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="scp_dir" size="32" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Button name="locked" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2">
	<AAT:Label value="_MSG_SSH_PUBKEY_REQUIRED" color="red"/></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
