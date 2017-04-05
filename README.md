MediaWatcher
===============


The Mediawatcher is watching for any changes in the mounted drives and informs the user if a mounted drive is not encrypted.

The following components need to be distributed to the Mac and executed accordingly.

- Binary -> The Binary needs to be available in /Library/Application Support/Intellec/
- launchdaemon com.intellec.mediawatcher.plist -> The launchdaemon will run the Binary every time a change in the mounted drives is recognized 

Prerequisites:
None

Troubleshooting:
In case that the script doesn't work anymore verify the following:
- Check that the Binary is available at the desired location.
- Check wether the launchdaemon is loaded or not

There may be specific issues depending on the removable device that is being attached to the Mac. It is very hard to remotely assist in any issues as the output of the DiskArbitrary output for the specific drives. 
