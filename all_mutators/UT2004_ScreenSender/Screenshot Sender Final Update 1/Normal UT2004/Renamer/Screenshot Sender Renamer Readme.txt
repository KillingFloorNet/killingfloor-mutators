======================================================================================================================

Screenshot Sender Renamer

======================================================================================================================

The purpose of this little program is to allow administrators to hide the fact that the screenshot sender is running on their servers.

Note: The Renamer is only compatible with the normal version of the screenshot sender, that means you can not rename the TO:C version.

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

How to use the program:

- Place the ScreenSenderRenamer.exe and the ScreenSenderF1U.u in the same directory and start the Renamer

- Now you need to specify a new package name. The package is renamed to this name and consequently this new name appears
  on the client while he downloads the package from your server instead of the original "ScreenSenderF1U".
  You need to enter a name with the same length as the original name (15 characters) and it may only contain alpha-numeric characters.
  If the field is green, then the name should be ok.

- Furthermore you need to specify a new mutator name (this one will show up in the serverinfo, if you leave the "MutServerInfoName"-option
   of the screenshot sender configuration empty). Notice again, that the new name has to have the same length as the original name. Just type
   in letters till you can't type in more (the length has to be 15 characters) and the string may only contain alpha-numeric characters.
   If the field is green, then the name should be ok.

- Now hit "Rename" and close the program.

- The next thing to do is to rename the file ScreenSenderF1U.ucl to NewPackageName.ucl, whereas NewPackageName represents the new name
  of the package.

- Open the .ucl-file in a text-editor (like WordPad) and replace all occurrences of "ScreenSenderF1U.MutScreenSender" with
  "NewPackageName.NewMutatorName" (without the "). Again, NewPackageName is the new name of the package and NewMutatorName is the name of
  the mutator class (which you specified in the Renamer in the second textbox).

- Now you are ready to load the mutator on the server. If you want to add the mutator directly (for example in a voteline or in the startup-commandline
  of the server) you need to specify the "path" to the mutator. The old path was "ScreenSenderF1U.MutScreenSender", the new one
  is "NewPackageName.NewMutatorName".
  If you like to add the mutator via a serveractor, the new path is: "NewPackageName.ScreenSenderServerActor".

- The only thing left to do is changing the configuration-headers in your server-configuration-file.
  The old headers are "[ScreenSenderF1U.ScreenSenderMainConfig]" and "[ScreenSenderF1U.ScreenSenderAutoConfig]".
  Change them to "[NewPackageName.ScreenSenderMainConfig]" and "[NewPackageName.ScreenSenderAutoConfig]".

- Oh, and don't forget to change "MutServerInfoName" in the configuration. Enter anything you like or leave it empty to show the "NewMutatorName"
  in the serverinfo.


If the renamed files don't work (i.e. crash the server or similar), try to rename them with a different name.



Credits: Shambler (the original renamer by him helped me doing this one).

Coded by Gugi