<?
  include_once dirname(__FILE__) . "/config/variables.php";
  include_once dirname(__FILE__) . "/config/authsite.php";
?>
<html>
  <head>
    <title>Virtual Exim: Manage Domains</title>
    <link rel="stylesheet" href="style.css" type="text/css">
  </head>
  <body onLoad="document.domainchange.password.focus()">
    <? include dirname(__FILE__) . "/config/header.php"; ?>
    <div id="menu">
      <a href="site.php">Manage Domains</a><br>
      <a href="sitepassword.php" title="Change site password">Site Password</a><br>
      <br><a href="logout.php">Logout</a><br>
    </div>
    <div id="Forms">
      <table align="center">
	<tr><td colspan="2"><h4>Modify Domain Admin:</h4></td></tr>
        <form name="passwordchange" method="post" action="sitechangesubmit.php">
          <tr><td>Admin:</td><td><select name="localpart" class="textfield">
            <?
              $query = "SELECT localpart,domain_id FROM users
			WHERE domain_id='" . $_GET[domain_id] . "'
			AND admin='1'";
	      $result = $db->query($query);
              while ($row = $result->fetchRow()) {
                print '<option value="' . $row[localpart] . '">' . $row[localpart] . '</option>' . "\n\t";
              }
            ?>
            </select>@<? print $_GET[domain]; ?></td>
	  <td><input name="domain" type="hidden" value="<? print $_GET[domain]; ?>"></td>
	  <td><input name="domain_id" type="hidden" value="<? print $_GET[domain_id]; ?>"></td></tr>
          <tr><td>Password:</td><td><input name="clear" size="25" type="password" class="textfield"></td></tr>
          <tr><td>Verify Password:</td><td><input name="vclear" size="25" type="password" class="textfield"></td></tr>
	  <tr><td></td><td><input name="submit" size="25" type="submit" value="Submit Password"></td></tr>
        </form>
	<tr></tr><tr></tr>
	<tr><td colspan="2"><h4>Modify Domain Properties:</h4></td></tr>
        <form name="domainchange" method="post" action="sitechangesubmit.php">
          <?
	  $query = "SELECT uid, gid, quotas, spamassassin, avscan, enabled FROM domains WHERE
	  		domain_id='$_GET[domain_id]'";
	  $result = $db->query($query);
	  $row = $result->fetchRow();
	  ?>
	  <tr><td>System UID:</td><td><input type="text" size="25" name="uid" value="<? print $row[uid]; ?>" class="textfield"></td></tr>
	  <tr><td>System GID:</td><td><input type="text" size="25" name="gid" value="<? print $row[gid]; ?>" class="textfield"></td></tr>
	  <tr><td>Max mailbox quota in Mb<br>(0 for disabled):</td><td><input type="text" size="25" name="quotas" value="<? print $row[quotas]; ?>" class="textfield"></td></tr>
	  <tr><td>Spamassassin:</td><td><input type="checkbox" size="25" name="spamassassin" <? if ($row[spamassassin] == 1) {print "checked";} ?>></td></tr>
	  <tr><td>Anti-virus:</td><td><input type="checkbox" size="25" name="avscan" <? if ($row[avscan] == 1) {print "checked";} ?>></td></tr>
	  <tr><td>Enabled:</td><td><input type="checkbox" size="25" name="enabled" <? if ($row[enabled] == 1) {print "checked";} ?>></td>
	  <td><input name="domain" type="hidden" value="<? print $_GET[domain]; ?>"></td></tr>
	  <tr><td></td><td><input name="submit" size="25" type="submit" value="Submit Changes"></td></tr>
        </form>
      </table>
    </div>
  </body>
</html>
<!-- Layout and CSS tricks obtained from http://www.bluerobot.com/web/layouts/ -->