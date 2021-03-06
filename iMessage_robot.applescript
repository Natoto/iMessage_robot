
using terms from application "Messages"
	on message received theMessage from theBuddy for theChat
		
		-- id (text, r/o) : The buddy's service and handle. For example: AIM:JohnDoe007
		-- name (text, r/o) : The buddy's name as it appears in the buddy list.
		-- handle (text, r/o) : The buddy's online account name.
		set userid to id of theBuddy
		set senderName to name of theBuddy
		set senderNumber to handle of theBuddy
		set theMessage to theMessage as string
		
		-- 判断是不是自己
		if (senderNumber contains "definemyself") then
			-- 针对自己给自己发短信，取消循环发送
			if (isAlreadySendToMyself()) then
				return
			end if
			-- 锁屏命令
			setScreenCommands(theMessage)
		end if
		
		-- 对于未备注的手机号，其senderName含有非法字符，这是用senderNumber作为majorKey
		-- 对于备注的手机号，其senderName就是 备注名，可以作为majorKey
		set majorKey to senderNumber
		if (length of split(senderName, space) = 1) then
			set majorKey to senderName
		end if
		
		-- 得到返回信息
		set replyInfo to handleReplyMessage(majorKey, theMessage)
		if (length of replyInfo > 0) then
			send replyInfo to theChat
		end if
		
		-- log一下
		createLog(userid, majorKey, theMessage, replyInfo)
	end message received
	
	on createLog(userid, majorKey, theMessage, replyInfo)
		
		set logFile to "~/message/log/log_" & majorKey & ".txt"
		set currentDate to currentDateFomat() as string
		try
			do shell script "echo " & currentDate & "':'" & theMessage & " >>  " & logFile & ""
			do shell script "echo " & currentDate & "':'" & replyInfo & " >>  " & logFile & ""
			
		on error
			--do nothing
		end try
	end createLog
	
	on handleReplyMessage(senderName, senderMessage)
		-- 判断是否为脏话
		set fuckContent to readFileByShell("messageFilter")
		set fuckList to split(fuckContent, "、")
		repeat with anItem in fuckList
			if (senderMessage contains anItem) then
				return " shut up！"
				exit repeat
			end if
		end repeat
		
		-- 判断senderName曾经是否被sayHi
		if (readFileByShell("sayHiUserList") does not contain senderName) then
			--  写入sayHiUserListFile 并 sayHi
			do shell script "echo " & senderName & "';' >> ~/message/sayHiUserList.txt"
			return sayHi()
		end if
		
		-- 判断senderMessage 是不是 SpecialCommands?：menu shell TD...
		set commandInfo to checkSpecialCommand(senderName, senderMessage)
		if (length of commandInfo > 0) then
			return commandInfo
		end if
		
		-- 判断命令是否超时
		if (readFileByShell("menuUserList") contains senderName or readFileByShell("shellUserList") contains senderName) then
			set timeoutInfo to checkoutConnectTimeout(senderName)
			if (length of timeoutInfo > 0) then
				return timeoutInfo
			end if
		end if
		
		-- 判断senderName是否在menuUserList中，是 则进行menu相关操作
		if (readFileByShell("menuUserList") contains senderName) then
			return handleMenuCommand(senderName, senderMessage)
		end if
		
		--⚠️这里危险，以后关闭⚠️
		-- 判断senderName是否在shellUserList中，是 则进行shell相关操作
		if (readFileByShell("shellUserList") contains senderName) then
			return handleShellCommand(senderName, senderMessage)
		end if
		
		return ""
	end handleReplyMessage
	
	
	-- 判断sender 使用的 当前指令 类型令
	-- clean 所有信息
	-- 记录sender 使用的 当前指令 类型
	on checkSpecialCommand(senderName, senderMessage)
		
		-- menu
		if ((length of senderMessage < 6) and (senderMessage contains "menu")) then
			TD(senderName)
			do shell script "echo " & senderName & "';' >> ~/message/menuUserList.txt"
			saveLastConnectTime(senderName)
			return replyToSenderMenu()
		end if
		
		-- shell
		if ((length of senderMessage < 7) and (senderMessage contains "shell")) then
			TD(senderName)
			do shell script "echo " & senderName & "';' >> ~/message/shellUserList.txt"
			saveLastConnectTime(senderName)
			return replyToSenderShell()
		end if
		
		-- about
		if ((length of senderMessage < 7) and (senderMessage contains "about")) then
			saveLastConnectTime(senderName)
			return replyToSenderAboutMe()
		end if
		
		-- TD
		if ((length of senderMessage < 4) and (senderMessage contains "TD")) then
			TD(senderName)
			return readFileByShell("sayBye")
		end if
		
		return ""
	end checkSpecialCommand
	
	
	
	
	# first time say hi
	on sayHi()
		return readFileByShell("sayHi")
	end sayHi
	
	# TD controller
	on TD(senderName)
		-- remove user info from menuUserList
		set originalText to readFileByShell("menuUserList")
		set newText to findAndReplaceInText(originalText, senderName & ";", "")
		do shell script "echo " & newText & " > ~/message/menuUserList.txt"
		
		-- remove user info from shellUserList
		set originalText to readFileByShell("shellUserList")
		set newText to findAndReplaceInText(originalText, senderName & ";", "")
		do shell script "echo " & newText & " > ~/message/shellUserList.txt"
		
		-- removeFile
		removeFile("time/time_" & senderName)
		
	end TD
	
	# shell controller
	on handleShellCommand(senderName, senderMessage)
		-- 拒绝 危险操作
		if (senderMessage contains "halt" or senderMessage contains "poweroff" or senderMessage contains "reboot" or senderMessage contains "shutdown" or senderMessage contains "rm" or senderMessage contains "mv" or senderMessage contains "sudo" or senderMessage contains "osascript" or senderMessage contains "dialog" or senderMessage contains "display") then
			return "我的主人不希望你进行这样的操作"
		else
			try
				return do shell script senderMessage
			on error
				return "我无法识别这样的shell命令"
			end try
			
		end if
	end handleShellCommand
	
	# menu controller
	on handleMenuCommand(senderName, senderMessage)
		
		-- 执行当前指令
		try
			set num to senderMessage as number
			if (num > 0 and num < 6) then
				set filePath to "menu_content/" & num
				set fileContent to readFileByShell(filePath)
				set myList to split(fileContent, "...")
				set randomItem to some item of myList
				return randomItem
			else
				return "请输入正确的指令(比如 3)，发送menu查看指令"
			end if
		on error
			return "请输入正确的指令(比如 3)，发送menu查看指令"
		end try
	end handleMenuCommand
	
	# 替换方法
	on findAndReplaceInText(theText, theSearchString, theReplacementString)
		set AppleScript's text item delimiters to theSearchString
		set theTextItems to every text item of theText
		set AppleScript's text item delimiters to theReplacementString
		set theText to theTextItems as string
		set AppleScript's text item delimiters to ""
		return theText
	end findAndReplaceInText
	
	on checkoutConnectTimeout(senderName)
		set replyMessage to ""
		if (connectTimeout(senderName)) then
			TD(senderName)
			set replyMessage to "连接超时，重新连接需要发送:menu、shell、about 等指令"
		end if
		saveLastConnectTime(senderName)
		return replyMessage
	end checkoutConnectTimeout
	
	
	# sub function
	
	on split(someText, delimiter)
		set AppleScript's text item delimiters to delimiter
		set someText to someText's text items
		set AppleScript's text item delimiters to {""} --> restore delimiters to default value
		return someText
	end split
	
	on saveLastConnectTime(senderName)
		set stampString to currentDateStamp() as string
		do shell script "echo " & stampString & " > ~/message/time/time_" & senderName & ".txt"
	end saveLastConnectTime
	
	on connectTimeout(senderName)
		set isConnectTimeout to false
		try
			set stampString to readFileByShell("time/time_" & senderName & "")
			set stampNum to stampString as number
			if (currentDateStamp() - stampNum > 120) then
				set isConnectTimeout to true
			else
				set isConnectTimeout to false
			end if
		on error
			set isConnectTimeout to true
		end try
		return isConnectTimeout
	end connectTimeout
	
	on replyToSenderAboutMe()
		return readFileByShell("cmd_about_me")
	end replyToSenderAboutMe
	
	on replyToSenderShell()
		return readFileByShell("cmd_shell")
	end replyToSenderShell
	
	on replyToSenderMenu()
		return readFileByShell("cmd_menu")
	end replyToSenderMenu
	
	on setScreenCommands(senderMessageString)
		set separator to ";"
		if (senderMessageString contains separator) then
			set commandString to text 1 thru ((offset of separator in senderMessageString) - 1) of senderMessageString
			if (commandString contains "CloseScreen") then
				do shell script "pmset displaysleepnow"
			else if (commandString contains "LockScreen") then
				do shell script "/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -suspend"
			else if (commandString contains "ShutDown") then
				tell application "System Events" to shut down
			end if
		end if
	end setScreenCommands
	
	
	on isAlreadySendToMyself()
		-- do only once
		set theFileContent to readFileByShell("doOnce")
		if (length of theFileContent > 0 and theFileContent contains "already") then
			do shell script "echo ' ''' > ~/message/doOnce.txt"
			return true
		else
			do shell script "echo 'already' > ~/message/doOnce.txt"
			return false
		end if
	end isAlreadySendToMyself
	
	
	# Tools function 
	
	on currentDateStamp()
		return do shell script "send=`date +%s`;echo $send"
	end currentDateStamp
	
	on currentDateFomat()
		do shell script "send=`date '+%Y-%m-%d %H:%M:%S'`;echo $send"
	end currentDateFomat
	
	
	
	on createFile(fileName)
		do shell script "touch ~/message/" & fileName & ".txt"
		return "~/message/" & fileName & ".txt"
	end createFile
	
	-- readFileByShell 默认目录 是 message,使用时 注意
	on readFileByShell(theFile)
		try
			return do shell script "value=`cat ~/message/" & theFile & ".txt `;echo $value"
		on error
			return ""
		end try
	end readFileByShell
	
	-- removeFile 默认目录 是 message,使用时 注意
	on removeFile(fileName)
		try
			do shell script "rm ~/message/" & fileName & ".txt"
		on error
			--文件不存在／删除出现异常：do nothing
		end try
		
	end removeFile
	
	
	# unused tool functoin
	
	on readFile(theFile)
		
		-- if theFile is nil will throw error ,catch and return ""
		try
			-- Convert the file to a string
			set theFile to theFile as string
			
			-- Read the file and return its contents			
			return read file theFile
		on error
			return ""
		end try
	end readFile
	
	on writeTextToFile(theText, theFile, overwriteExistingContent)
		try
			
			-- Convert the file to a string
			set theFile to theFile as string
			
			-- Open the file for writing
			set theOpenedFile to open for access file theFile with write permission
			
			-- Clear the file if content should be overwritten
			if overwriteExistingContent is true then set eof of theOpenedFile to 0
			
			-- Write the new content to the file
			write theText to theOpenedFile starting at eof
			
			-- Close the file
			close access theOpenedFile
			
			-- Return a boolean indicating that writing was successful
			return true
			
			-- Handle a write error
		on error
			
			-- Close the file
			try
				close access file theFile
			end try
			
			-- Return a boolean indicating that writing failed
			return false
		end try
	end writeTextToFile
	
	on convertPathToAlias(thePath)
		tell application "System Events"
			try
				return (path of disk item (thePath as string)) as alias
			on error
				return (path of disk item (path of thePath) as string) as alias
			end try
		end tell
	end convertPathToAlias
	
	
	
	# The following are unused but need to be defined to avoid an error
	
	on received audio invitation theText from theBuddy for theChat
		
	end received audio invitation
	
	on received video invitation theText from theBuddy for theChat
		
	end received video invitation
	
	on received file transfer invitation theFileTransfer
		
	end received file transfer invitation
	
	on buddy authorization requested theRequest
		
	end buddy authorization requested
	
	on message sent theMessage for theChat
		
	end message sent
	
	on chat room message received theMessage from theBuddy for theChat
		
	end chat room message received
	
	on active chat message received theMessage
		
	end active chat message received
	
	on addressed chat room message received theMessage from theBuddy for theChat
		
	end addressed chat room message received
	
	on addressed message received theMessage from theBuddy for theChat
		
	end addressed message received
	
	on av chat started
		
	end av chat started
	
	on av chat ended
		
	end av chat ended
	
	on login finished for theService
		
	end login finished
	
	on logout finished for theService
		
	end logout finished
	
	on buddy became available theBuddy
		
	end buddy became available
	
	on buddy became unavailable theBuddy
		
	end buddy became unavailable
	
	on completed file transfer
		
	end completed file transfer
	
end using terms from

