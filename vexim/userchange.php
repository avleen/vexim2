<?php
include_once dirname(__FILE__) . "/config/variables.php";
include_once dirname(__FILE__) . "/config/authuser.php";
include_once dirname(__FILE__) . "/config/functions.php";
include_once dirname(__FILE__) . "/config/httpheaders.php";

$domquery = "SELECT avscan,spamassassin FROM domains WHERE domain_id=:domain_id";
$domsth = $dbh->prepare($domquery);
$success = $domsth->execute(array(':domain_id' => $_SESSION['domain_id']));
if ($success) {
    $domrow = $domsth->fetch();
}
$query = "SELECT * FROM users WHERE user_id=:user_id";
$sth = $dbh->prepare($query);
$success = $sth->execute(array(':user_id' => $_SESSION['user_id']));
if ($success) {
    $row = $sth->fetch();
}
$blockquery = "SELECT block_id,blockhdr,blockval FROM blocklists,users
    WHERE blocklists.user_id=:user_id
    AND users.user_id=blocklists.user_id";
$blocksth = $dbh->prepare($blockquery);
$blocksuccess = $blocksth->execute(array(':user_id' => $_SESSION['user_id']));
?>
<html>
<head>
    <title><?php echo _("Virtual Exim") . ": " . _("Manage Users"); ?></title>
    <link rel="stylesheet" href="style.css" type="text/css">
</head>
<body onLoad="document.userchange.realname.focus()">
<?php include dirname(__FILE__) . "/config/header.php"; ?>
<div id="menu">
    <a href="logout.php"><?php echo _("Logout"); ?></a><br>
</div>
<div id="forms">
    <form name="userchange" method="post" action="userchangesubmit.php">
        <table align="center">
            <tr>
                <td><?php echo _("Name"); ?>:</td>
                <td><input name="realname" type="text" value="<?php print $row['realname']; ?>" class="textfield"></td>
            </tr>
            <tr>
                <td><?php echo _("Email Address"); ?>:</td>
                <td><?php print $row['localpart'] . "@" . $_SESSION['domain']; ?></td>
            <tr>
                <td><?php echo _("Password"); ?>:</td>
                <td><input name="clear" type="password" class="textfield"></td>
            </tr>
            <tr>
                <td><?php echo _("Verify Password"); ?>:</td>
                <td><input name="vclear" type="password" class="textfield"></td>
            </tr>
            <tr>
                <td colspan="2" style="padding-top:1em;">
                    <b><?php echo _("Note:"); ?></b> <?php echo _("Attempting to set blank passwords does not work!"); ?>
                <td>
            </tr>
            <tr>
                <td></td>
                <td class="button"><input name="submit" type="submit" value="<?php echo _("Submit Password"); ?>"></td>
            </tr>
    </form>
    <form name="userchange" method="post" action="userchangesubmit.php">
        </table>
        <table align="center">
            <tr>
                <td colspan="2"><?php
                    if ($row['quota'] != "0") {
                        printf(_("Your mailbox quota is currently: %s Mb"), $row['quota']);
                    } else {
                        print _("Your mailbox quota is currently: Unlimited");
                    }
                    ?>
                </td>
            </tr>
            <?php
            if ($domrow['avscan'] == "1") {
                ?>
                <tr>
                    <td><?php echo _('Anti-Virus'); ?>:</td>
                    <td><input name="on_avscan" type="checkbox"
                            <?php if ($row['on_avscan'] == "1") {
                                print " checked";
                            } ?>>
                    </td>
                </tr>
                <?php
            }
            if ($domrow['spamassassin'] == "1") {
                ?>
                <tr>
                    <td><?php echo _('Spamassassin'); ?>:</td>
                    <td><input name="on_spamassassin" type="checkbox"
                            <?php if ($row['on_spamassassin'] == "1") {
                                print " checked";
                            } ?>>
                    </td>
                </tr>
                <tr>
                    <td><?php echo _('Spamassassin tag score'); ?>:</td>
                    <td>
                        <input type="text" size="5" name="sa_tag"
                               value="<?php echo $row['sa_tag']; ?>" class="textfield">
                    </td>
                </tr>
                <tr>
                    <td><?php echo _('Spamassassin refuse score'); ?>:</td>
                    <td>
                        <input type="text" size="5" name="sa_refuse"
                               value="<?php echo $row['sa_refuse']; ?>" class="textfield">
                    </td>
                </tr>
                <tr>
                    <td><?php echo _('How to handle mail above the SA refuse score'); ?>:</td>
                    <td>
                        <input type="radio" id="off" name="spam_drop" value="0"<?php if ($row['spam_drop'] == "0") {
                            print " checked";
                        } ?>>
                        <label for="off"> <?PHP echo _('move to Spam-folder'); ?></label><br>
                        <input type="radio" id="on" name="spam_drop" value="1"<?php if ($row['spam_drop'] == "1") {
                            print " checked";
                        } ?>>
                        <label for="on"><?PHP echo _('delete - you cannot restore these mails'); ?></label><br>
                    </td>
                </tr>
                <?php
            }
            ?>
            <tr>
                <td><?php echo _('Maximum message size'); ?>:</td>
                <td>
                    <input type="text" size="5" name="maxmsgsize"
                           value="<?php echo $row['maxmsgsize']; ?>" class="textfield">Kb
                </td>
            </tr>
            <tr>
                <td><?php echo _('Vacation on'); ?>:</td>
                <td><input name="on_vacation" type="checkbox" <?php
                    if ($row['on_vacation'] == "1") {
                        print " checked ";
                    } ?>>
                </td>
            </tr>
            <tr>
                <?php if (function_exists('imap_qprint')) { ?>
                    <td><?php echo _('Vacation message'); ?>:</td>
                    <td>
                        <textarea name="vacation" cols="40" rows="5"
                                  class="textfield"><?php print imap_qprint($row['vacation']); ?></textarea>
                    </td>
                <?php } else { ?>
                    <td><?php echo _('Vacation message (ASCII only!)'); ?>:</td>
                    <td>
                        <textarea name="vacation" cols="40" rows="5"
                                  class="textfield"><?php print $row['vacation']; ?></textarea>
                    </td>
                <?php } ?>
            </tr>
            <tr>
                <td><?php echo _("Forwarding enabled"); ?>:</td>
                <td><input name="on_forward" type="checkbox"
                        <?php if ($row['on_forward'] == "1") {
                            print " checked ";
                        } ?>>
                </td>
            </tr>
            <tr>
                <td><?php echo _("Forward mail to"); ?>:</td>
                <td><input type="text" name="forward" value="<?php print $row['forward']; ?>" class="textfield"><br>
                    <?php echo _("Must be a full e-mail address"); ?>
                </td>
            </tr>
            <tr>
                <td><?php echo _("Store Forwarded Mail Locally"); ?>:</td>
                <td><input name="unseen" type="checkbox"
                    <?php if ($row['unseen'] == "1") {
                        print " checked ";
                    } ?>
                </td>
            </tr>
            <tr>
                <td></td>
                <td class="button"><input name="submit" type="submit" value="<?php echo _("Submit Profile"); ?>"></td>
            </tr>
        </table>
    </form>
    <form name="blocklist" method="post" action="userblocksubmit.php">
        <table align="center">
            <tr>
                <td><?php echo _("Add a new header blocking filter"); ?>:</td>
            </tr>
            <tr>
                <td><select name="blockhdr" class="textfield">
                        <option value="From"><?php echo _("From"); ?>:</option>
                        <option value="To"><?php echo _("To"); ?>:</option>
                        <option value="Subject"><?php echo _("Subject"); ?>:</option>
                        <option value="X-Mailer"><?php echo _("X-Mailer"); ?>:</option>
                    </select></td>
                <td><input name="blockval" type="text" size="25" class="textfield">
                    <input name="color" type="hidden" value="black"></td>
            </tr>
            <tr>
                <td><input name="submit" type="submit" value="Submit"></td>
            </tr>
        </table>
    </form>
    <table align="center">
        <tr>
            <th><?php echo _("Delete"); ?></th>
            <th><?php echo _("Blocked Header"); ?></th>
            <th><?php echo _("Content"); ?></th>
        </tr>
        <?php if ($blocksuccess) {
            while ($blockrow = $blocksth->fetch()) {
                print "<tr><td><a href=\"userblocksubmit.php?action=delete&block_id={$blockrow['block_id']}\"><img style=\"border:0;width:10px;height:16px\" title=\"Delete\" src=\"images/trashcan.gif\" alt=\"trashcan\"></a></td>";
                print "<td>{$blockrow['blockhdr']}</td><td>{$blockrow['blockval']}</td></tr>\n";
            }
        }
        ?>
    </table>
</div>
</body>
</html>
<!-- Layout and CSS tricks obtained from http://www.bluerobot.com/web/layouts/ -->
