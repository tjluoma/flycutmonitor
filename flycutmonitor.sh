#!/bin/zsh -f
# This shell script is meant to be called via launchd whenever the file
# "$HOME/Library/Application Support/Flycut/com.generalarcade.flycut.plist"
# changes. See <https://github.com/tjluoma/flycutmonitor> for details.
#
#
# From:  Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2012-11-01

	# Leave this alone
NAME="$0:t"


	# set
	# GROWL=no
	# if you don't want to use Growl notifications
GROWL=yes

	# FOLDER where text files will be saved (this will be created if it does not exist)
DIR="$HOME/Dropbox/TEMP/$NAME"



####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#	You should not need to edit anything below this line
#


	# Get the contents of the pasteboard
PB=$(LANG=en_US.UTF-8 pbpaste -Prefer txt)

	# if PB is empty, quit immediately (this likely happens when you copy an image or something else to the pasteboard
[[ "$PB" == "" ]] && exit 0


####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
# 	If we do want to use Growl, setup 'msg' as a function
#

if [ "$GROWL" = "yes" ]
then

	# Use Growl if growlnotify exists in path
msg () {
	if (( $+commands[growlnotify] ))
	then

		growlnotify \
		--appIcon 'Flycut'  \
		--identifier "$NAME"  \
		--message "$@"  \
		--title "$NAME"

	else

		return

	fi
}

else
# if GROWL is NOT set to yes


msg () {

	return
}

fi
#
#	end Growl / msg
#
####|####|####|####|####|####|####|####|####|####|####|####|####|####|####




####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#
#	If we get here, then we DID find something on the pasteboard
#	And now we're going to do something with it
#
#
####|####|####|####|####|####|####|####|####|####|####|####|####|####|####


	# if it doesn't exist, create it
[[ -d "$DIR" ]] || mkdir -p "$DIR"

	# we'll use this for unique filename
zmodload zsh/datetime	# required for 'strftime'

timestamp () {
	strftime %F--%H.%M.%S "$EPOCHSECONDS"
}

	# Save the pasteboard to the named directory.
	# it is assumed that $DIR will include $NAME so
	# we don't include it here
echo "${PB}" >>| "$DIR/$HOST.`timestamp`.txt"

	# there may be times when we want to notify the user that something happened successfully using an audible sound
success () { afplay /System/Library/Sounds/Glass.aiff }


case "$PB" in


		##### I have used this in the past and might want it again in the future, so I'm keeping it as a reference
		##### for when you might want to do something extra when certain matching text is found on the pasteboard

		# 	*managemylife.com*)
		# 			MML="$HOME/Dropbox/txt/MML.txt"
		# 			echo "${PB}" >>| "$MML" && success
		# 			msg "Saved pasteboard to $MML"
		# 			exit 0
		#
		# 	;;


		*)
			NAME="Current Pasteboard"
			PB=$(echo "$PB" | tr -s '[:cntrl:][:blank:]' ' ')
			msg "$PB"
			exit 0
		;;

esac


exit 0

#
#EOF
