#!/bin/sh

printf '\033[0;34m%s\033[0m\n' "Upgrading My Shell"
cd "${MYSHELL}"
if git pull --rebase --stat origin master ; then
	printf '\033[0;32m%s\033[0m\n' '                                     #                   ##       ##    '
	printf '\033[0;32m%s\033[0m\n' ' #     #                     #####   #                    #        #    '
	printf '\033[0;32m%s\033[0m\n' ' ##   ##                    #     #  #                    #        #    '
	printf '\033[0;32m%s\033[0m\n' ' # # # #  #    #            #        ######    #####      #        #    '
	printf '\033[0;32m%s\033[0m\n' ' #  #  #  #    #             #####   #     #  #     #     #        #    '
	printf '\033[0;32m%s\033[0m\n' ' #     #  #    #                  #  #     #  #######     #        #    '
	printf '\033[0;32m%s\033[0m\n' ' #     #  #    #            #     #  #     #  #           #        #    '
	printf '\033[0;32m%s\033[0m\n' ' #     #   #####             #####   #     #   #####     ###      ###   '
	printf '\033[0;32m%s\033[0m\n' '               #                                                        '
	printf '\033[0;32m%s\033[0m\n' '           ####                                                         '
	printf '\033[0;34m%s\033[0m\n' 'Hooray! My Shell has been updated and/or is at the current version.'
	bash "${MYSHELL}/tools/install.sh"
else
	printf '\033[0;31m%s\033[0m\n' 'There was an error updating. Try again later?'
fi

